-- 03_quality_checks.sql
-- Purpose: validate the cleaned table after running 02_data_cleaning.sql.
-- Compare the results with your actual run; counts can vary if source data differs.

USE world_layoffs;

-- 1. Raw and cleaned row counts
SELECT 'raw_source' AS table_name, COUNT(*) AS row_count
FROM layoffs
UNION ALL
SELECT 'cleaned_staging', COUNT(*)
FROM layoffs_staging2;

-- 2. Exact duplicate groups should return no rows.
SELECT
    company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions,
    COUNT(*) AS copies
FROM layoffs_staging2
GROUP BY
    company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions
HAVING COUNT(*) > 1;

-- 3. Missing-value profile after cleaning
SELECT
    COUNT(*) AS total_rows,
    SUM(company IS NULL OR TRIM(company) = '') AS missing_company,
    SUM(location IS NULL OR TRIM(location) = '') AS missing_location,
    SUM(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
    SUM(total_laid_off IS NULL) AS missing_total_laid_off,
    SUM(percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '') AS missing_percentage_laid_off,
    SUM(`date` IS NULL) AS missing_date,
    SUM(stage IS NULL OR TRIM(stage) = '') AS missing_stage,
    SUM(country IS NULL OR TRIM(country) = '') AS missing_country,
    SUM(funds_raised_millions IS NULL) AS missing_funds_raised
FROM layoffs_staging2;

-- 4. The cleaning rule should have removed records missing both layoff measures.
SELECT COUNT(*) AS rows_missing_both_layoff_measures
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND (percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '');

-- Expected: 0

-- 5. Date type and date range
DESCRIBE layoffs_staging2;

SELECT
    MIN(`date`) AS earliest_date,
    MAX(`date`) AS latest_date,
    SUM(`date` IS NULL) AS missing_dates
FROM layoffs_staging2;

-- 6. Standardized category values
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY country;

-- 7. Inspect any remaining missing industries; do not guess unsupported values.
SELECT company, location, industry, country
FROM layoffs_staging2
WHERE industry IS NULL OR TRIM(industry) = ''
ORDER BY company;

-- 8. Review possible country formatting issues
SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE '%.' OR country <> TRIM(country)
ORDER BY country;
