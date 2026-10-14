-- 02_data_cleaning.sql
-- Purpose: create a clean working table without changing the original source table.
-- Assumption: source table world_layoffs.layoffs has the nine expected columns.
-- IMPORTANT: this script DROPS and recreates only layoffs_staging and layoffs_staging2.
-- Back up any work in those staging tables before running this script.

USE world_layoffs;

-- Rebuild a clean staging copy from the original imported table.
DROP TABLE IF EXISTS layoffs_staging2;
DROP TABLE IF EXISTS layoffs_staging;

CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Create a working table with a row number for exact duplicate detection.
-- Every source column is included in the partition so only fully identical rows
-- are treated as duplicates. Similar-looking rows are not automatically removed.
CREATE TABLE layoffs_staging2 AS
SELECT
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    `date`,
    stage,
    country,
    funds_raised_millions,
    ROW_NUMBER() OVER (
        PARTITION BY
            company, location, industry, total_laid_off, percentage_laid_off,
            `date`, stage, country, funds_raised_millions
        ORDER BY company
    ) AS row_num
FROM layoffs_staging;

-- Keep the first row in each exact-duplicate group.
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- Standardize empty industry strings to NULL.
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry IS NOT NULL
  AND TRIM(industry) = '';

-- Fill missing industry only when another row for the same company has a known value.
-- If no supported match exists, the value remains NULL rather than being guessed.
UPDATE layoffs_staging2 AS target
JOIN layoffs_staging2 AS source
    ON target.company = source.company
SET target.industry = source.industry
WHERE target.industry IS NULL
  AND source.industry IS NOT NULL;

-- Standardize known variants to one label.
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE TRIM(industry) IN ('Crypto Currency', 'CryptoCurrency');

-- Trim spaces and trailing periods from country names.
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM TRIM(country))
WHERE country IS NOT NULL;

-- Convert date text in MM/DD/YYYY format to a proper DATE.
-- Blank values remain NULL. Review unexpected formats in profiling first.
UPDATE layoffs_staging2
SET `date` = CASE
    WHEN NULLIF(TRIM(CAST(`date` AS CHAR)), '') IS NULL THEN NULL
    WHEN TRIM(CAST(`date` AS CHAR)) REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{4}$'
        THEN STR_TO_DATE(TRIM(CAST(`date` AS CHAR)), '%m/%d/%Y')
    WHEN TRIM(CAST(`date` AS CHAR)) REGEXP '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
        THEN STR_TO_DATE(TRIM(CAST(`date` AS CHAR)), '%Y-%m-%d')
    ELSE NULL
END;

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE NULL;

-- Exclusion rule: remove records where neither layoff count nor layoff percentage
-- is available. This is a documented project decision, not a claim that the
-- missing values are zero.
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND (percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '');

-- Remove the temporary duplicate-tracking field.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final preview
SELECT *
FROM layoffs_staging2
LIMIT 50;

SELECT COUNT(*) AS cleaned_row_count
FROM layoffs_staging2;
