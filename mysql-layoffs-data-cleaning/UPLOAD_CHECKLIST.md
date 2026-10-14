# GitHub Upload Checklist

- [ ] Confirm the dataset's redistribution terms before committing `data/layoffs_raw.csv`.
- [ ] Create the `world_layoffs` schema and import the raw CSV as `layoffs`.
- [ ] Run `sql/01_data_profiling.sql`.
- [ ] Run `sql/02_data_cleaning.sql`.
- [ ] Run `sql/03_quality_checks.sql` and update `results/data_quality_summary.md` with the actual results.
- [ ] Add screenshots only if they are readable and show real MySQL Workbench output.
- [ ] Check that no passwords, database credentials, or private files are included.
- [ ] Commit the project files to the separate `mysql-layoffs-data-cleaning` repository.
