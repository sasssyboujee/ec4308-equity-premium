# Reproduction instructions

Run from the project root. Install R packages once:

```r
install.packages(c("hdm", "glmnet", "pls", "ranger", "readxl", "ggplot2", "limSolve"))
```

Generate the report inputs:

```bash
Rscript data/00_fetch_technical.R
Rscript data/01_build_panel.R
Rscript data/02_table1.R
Rscript data/03_validate_signals.R
Rscript R/09_run_models.R 1
Rscript R/09_run_models.R 1 tech 1
Rscript R/09_run_models.R 1 macro 1
Rscript data/01_build_panel.R expanded data/processed/panel_expanded.csv
Rscript R/09_run_models.R 1 full 1,3,12 data/processed/panel_expanded.csv _expanded
Rscript R/15_neely_bivariate.R
Rscript R/16_neely_replication.R
Rscript R/11_evaluate.R
Rscript R/13_figures.R
Rscript R/14_make_latex_tables.R
```

Install Tectonic, then compile the report:

```bash
cd report
tectonic main.tex
```
