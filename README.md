# MySQL Data Cleaning Project — Layoffs Dataset

A practical SQL project focused on preparing company-layoff records for reliable analysis. The work demonstrates a structured data-cleaning workflow in MySQL: profiling, duplicate detection, standardization, date conversion, missing-value review, and final quality checks.

> **Project scope:** The dataset supplied for this project contains historical records dated from 2020–2023. It is not a dataset of 2025 layoffs.

## Project at a glance

- **Database:** MySQL
- **Main techniques:** `ROW_NUMBER()`, window functions, `UPDATE`, self-joins, `STR_TO_DATE()`, `ALTER TABLE`, `GROUP BY`, `HAVING`, `NULL` checks
- **Workflow:** Profile → Clean a staging copy → Validate → Document
- **Raw data shape:** 2,361 rows and 9 columns in the supplied CSV
- **Working result previously observed in MySQL Workbench:** 1,995 rows in `layoffs_staging2`. Re-run the scripts and quality checks in your own environment before treating this count as a final reproducible result.

## Why data cleaning matters

Business analysis is only as dependable as the data behind it. Duplicate records can inflate totals, inconsistent labels split one category into several, malformed dates break time-based analysis, and missing values can distort calculations if they are silently replaced. This project makes those issues visible and applies documented, repeatable rules before analysis.

## Repository structure

```text
mysql-layoffs-data-cleaning/
├── README.md
├── .gitignore
├── data/
│   ├── README.md
│   └── layoffs_raw.csv
├── sql/
│   ├── 01_data_profiling.sql
│   ├── 02_data_cleaning.sql
│   └── 03_quality_checks.sql
└── results/
    └── data_quality_summary.md
```

## Dataset columns

| Column | Description |
|---|---|
| `company` | Company name |
| `location` | Reported location |
| `industry` | Industry category |
| `total_laid_off` | Reported number of employees laid off |
| `percentage_laid_off` | Reported percentage of workforce laid off |
| `date` | Reported layoff date |
| `stage` | Company funding/business stage |
| `country` | Country |
| `funds_raised_millions` | Reported funds raised, in millions |

The CSV contains 2,361 records and 9 columns. The supplied records span 2020–2023. See `data/README.md` for a note about redistribution and source attribution.

## Cleaning workflow

1. **Profile the raw table** to inspect row counts, distinct values, duplicates, and missing values.
2. **Create a staging copy** so the original imported table remains unchanged.
3. **Detect exact duplicate rows** using `ROW_NUMBER()` partitioned by all nine data fields; keep one row from each identical group.
4. **Standardize industry values** by converting empty strings to `NULL`, filling a missing industry only when another record for the same company supplies a non-null industry, and standardizing known crypto label variants to `Crypto`.
5. **Standardize country text** by trimming whitespace and a trailing period.
6. **Convert dates** from `MM/DD/YYYY` text into the MySQL `DATE` type.
7. **Review missing values** rather than blindly replacing unknown values with zero. The cleaning script excludes rows where both `total_laid_off` and `percentage_laid_off` are `NULL`, because neither layoff measure is available for those rows.
8. **Run quality checks** to inspect remaining duplicates, missing values, date range, and standardized categories.

## Important decisions and limitations

- A missing value is not automatically zero. `NULL` means the value is unknown or not supplied.
- Missing industry is only filled when a matching company record has a non-null industry. Otherwise, it remains `NULL`; the project does not guess the industry.
- Rows with both layoff measures missing are excluded by the cleaning rule. This choice should be considered when using the cleaned data for later analysis.
- The date range remains the one represented by the source records. Dates are not changed to make the dataset appear newer.
- The SQL scripts assume you have imported the CSV into a MySQL schema named `world_layoffs` and a source table named `layoffs`. If your schema/table names differ, update the names in the scripts.
- The cleaning script rebuilds `layoffs_staging` and `layoffs_staging2` from the source table. Do not use a table with important unsaved changes under those names.

## How to run

1. Create a MySQL schema named `world_layoffs`.
2. Import `data/layoffs_raw.csv` into a table named `layoffs` with the nine columns listed above. In MySQL Workbench, use **Table Data Import Wizard** and check the column types after import.
3. Open and run `sql/01_data_profiling.sql` to inspect the source data.
4. Open and run `sql/02_data_cleaning.sql` to create the cleaned staging table.
5. Open and run `sql/03_quality_checks.sql` to validate the result.
6. Review `results/data_quality_summary.md` and update it if your run produces different counts.

Run the scripts in order. The cleaning script drops and recreates only the staging tables named `layoffs_staging` and `layoffs_staging2`; it does not intentionally modify the original `layoffs` table.

## Skills demonstrated

- Data profiling and quality assessment
- Duplicate detection with window functions
- Standardizing inconsistent text values
- Updating missing values only when supported by matching records
- Date parsing and data-type conversion
- Intentional handling of incomplete records
- SQL documentation and repeatable validation

## Possible next steps

- Perform exploratory data analysis on the cleaned table.
- Compare layoffs by year, industry, company stage, and country.
- Build visualizations in Power BI, Tableau, or Python.
- Add automated assertions or a repeatable import workflow.

---
**Learning project:** Built to practice practical MySQL data-cleaning methods and document decisions clearly.
