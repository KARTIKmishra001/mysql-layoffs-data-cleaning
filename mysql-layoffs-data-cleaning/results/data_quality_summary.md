# Data Quality Summary

## Dataset snapshot

The supplied CSV has **2,361 rows** and **9 columns** before cleaning. Its reported layoff dates cover **2020–2023**.

In the MySQL Workbench run described during project preparation, the raw staging table contained **2,361 rows** and `layoffs_staging2` contained **1,995 rows** after the cleaning workflow. Re-run the included scripts and record the results from `03_quality_checks.sql` before presenting these figures as a reproducible final result.

## Checks and treatment

| Issue | Treatment |
|---|---|
| Exact duplicate records | Used `ROW_NUMBER()` partitioned by all nine fields and retained one row from each identical group. |
| Blank industry | Converted empty strings to `NULL`. |
| Missing industry with a company match | Filled only when another row for the same company contained a non-null industry. |
| Missing industry without a supported match | Left as `NULL`; no unsupported industry was invented. |
| Inconsistent crypto labels | Standardized known variants to `Crypto`. |
| Country trailing period/extra spaces | Trimmed spaces and trailing periods. |
| Date stored as text | Parsed `MM/DD/YYYY` text into a MySQL `DATE` column. |
| Missing layoff count and percentage | Excluded rows where both measures were missing, according to the documented project rule. |
| Other missing values | Kept as `NULL` when no reliable replacement was available. |

## Validation to run

Run `sql/03_quality_checks.sql` after cleaning. Record the actual output for:
- Raw versus cleaned row counts
- Remaining exact duplicate groups
- Missing values by column
- Earliest and latest valid dates
- Remaining missing industry values
- Remaining rows with both layoff measures missing (expected: 0)

## Interpretation notes

- `NULL` does not mean zero.
- Missing funding, stage, date, or industry values should not be guessed without a reliable source.
- The cleaned row count depends on the exact input table and successful execution of the scripts.
- This is historical data dated 2020–2023; dates have not been shifted to 2025.
- The current summary is a transparent project note, not an independent audit or a guarantee that every possible data issue has been resolved.
