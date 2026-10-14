-- 01_data_profiling.sql
-- Purpose: inspect the source dataset before changing any data.
-- Assumption: source table is world_layoffs.layoffs.
-- This file contains read-only profiling queries.

USE world_layoffs;

-- 1. Overall shape
SELECT COUNT(*) AS total_rows
FROM layoffs;

SELECT *
FROM layoffs
LIMIT 20;

-- 2. Column types (review in MySQL Workbench)
DESCRIBE layoffs;

-- 3. Missing/blank values by important field
SELECT
    COUNT(*) AS total_rows,
    SUM(company IS NULL OR TRIM(company) = '') AS missing_company,
    SUM(location IS NULL OR TRIM(location) = '') AS missing_location,
    SUM(industry IS NULL OR TRIM(industry) = '') AS missing_industry,
    SUM(total_laid_off IS NULL) AS missing_total_laid_off,
    SUM(percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '') AS missing_percentage_laid_off,
    SUM(`date` IS NULL OR TRIM(CAST(`date` AS CHAR)) = '') AS missing_date,
    SUM(stage IS NULL OR TRIM(stage) = '') AS missing_stage,
    SUM(country IS NULL OR TRIM(country) = '') AS missing_country,
    SUM(funds_raised_millions IS NULL) AS missing_funds_raised
FROM layoffs;

-- 4. Exact duplicate groups across all nine source columns
SELECT
    company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions,
    COUNT(*) AS copies
FROM layoffs
GROUP BY
    company, location, industry, total_laid_off, percentage_laid_off,
    `date`, stage, country, funds_raised_millions
HAVING COUNT(*) > 1
ORDER BY copies DESC, company;

-- 5. Values that may need standardization
SELECT DISTINCT industry
FROM layoffs
ORDER BY industry;

SELECT DISTINCT country
FROM layoffs
ORDER BY country;

-- 6. Records without either layoff measure
SELECT *
FROM layoffs
WHERE total_laid_off IS NULL
  AND (percentage_laid_off IS NULL OR TRIM(percentage_laid_off) = '');

-- 7. Date values to inspect before conversion
SELECT DISTINCT `date`
FROM layoffs
ORDER BY `date`
LIMIT 100;
