# EC4308 Group Project — Forecasting the Equity Risk Premium Out-of-Sample

**Module**: EC4308 Machine Learning and Economic Forecasting (AY 2026/2027 Sem 1)
**Instructor**: Prof. Denis Tkachenko
**Topic**: Regularized ML, Technical Indicators & Tactical Asset Allocation
**Deadline**: Final report (≤15 pp) + code zip on Canvas **Mon 9 Nov 2026**; 10-min live presentation in Week 13; individual peer review in Reading Week.

## Team & roles

| Member    | Role                       | Owns                                                                 |
| :-------- | :------------------------- | :------------------------------------------------------------------- |
| Leon      | Data / Features            | Goyal (2024) data download, 1–6 macro lags, 14 Neely signals, Table 1 |
| En Shao   | ML Models                  | `rlasso`/post-LASSO (`hdm`), Ridge, PCR, PLS, Random Forest, Granger–Ramanathan ensembles |
| Sasi      | Econometrics / Evaluation  | Rolling-window harness, Prevailing Mean benchmark, Diebold–Mariano tests, Binary Switching Strategy, Mean-Variance utility |
| Vienna    | Motivation / Report        | Literature review, economic discussion, 15-page report, presentation |

> Full plan, deadlines and Prof. Denis's feedback pivots:
> [`PROJECT_TIMELINE_AND_MILESTONES.md`](PROJECT_TIMELINE_AND_MILESTONES.md)

## Project rules (from Prof. Denis — do not break)

- **R only.** The entire project is coded in R (`hdm`, `glmnet`, `pls`, `ranger`, `forecast`, `sandwich`).
- **Prevailing Mean is the only benchmark** — no OLS benchmarks.
- **Fixed 240-month rolling window** (20 years), not expanding.
- **Diebold–Mariano (1995)** on RMSE/MAE; Clark–West only as an appendix check.
- Economic evaluation **net of transaction costs** (10 bps baseline, 5 & 20 bps sensitivity).
- **No lookahead leakage** — see the alignment convention in `data/README.md`.

## Getting started

1. **Install R packages** (once per machine):
   ```r
   install.packages(c("hdm", "glmnet", "pls", "ranger", "forecast",
                      "sandwich", "readxl", "dplyr", "tidyr", "ggplot2",
                      "limSolve", "openxlsx", "lmtest", "zoo", "xts"))
   ```
2. **Get the data** (from the repo root):
   ```bash
   Rscript data/download_goyal_data.R        # -> data/raw/GoyalWelchZafirov_PredictorData.xlsx
   Rscript data/00_fetch_technical.R         # verify technical inputs (volume chain)
   ```
3. **Smoke-test the evaluation module** (synthetic data, no dependencies):
   ```bash
   Rscript R/99_demo_synthetic.R
   Rscript R/98_smoke_models.R               # every model_fn on synthetic data
   ```
4. Open `EC4308_Project.Rproj` in RStudio for a ready-made session.

## Reproducing the full analysis (from raw data)

```bash
Rscript data/01_build_panel.R        # -> data/processed/panel.csv (+ codebook)
Rscript data/02_table1.R             # -> output/tables/table1.csv
Rscript data/03_validate_signals.R   # -> output/tables/signal_validation.csv
Rscript R/09_run_models.R 6          # all models x h in {1,3,12} (~35 min)
                                     # variants: Rscript R/09_run_models.R 2 tech 1
                                     #           Rscript R/09_run_models.R 2 macro 1
Rscript R/15_neely_bivariate.R       # bivariate robustness (fixed window)
Rscript R/16_neely_replication.R     # expanding-window Neely replication/extension
Rscript R/11_evaluate.R              # -> Tables 2-3 (all horizons)
Rscript R/13_figures.R               # -> Figures 1-3
Rscript R/14_make_latex_tables.R     # -> LaTeX table fragments
cd report && latexmk -pdf main.tex   # -> report/main.pdf (12 pages)
python3 deck/make_deck.py            # -> deck/EC4308_Presentation.pptx
Rscript scripts/make_submission_zip.R # -> submission/EC4308_Project_Submission.zip
```

Everything is deterministic (fixed seeds, `num.threads = 1` for ranger): two
independent full h=1 runs were bit-identical.

## Repository layout

```
R/                      All R scripts (00_config, modules 01-07, 99_demo)
  ├── 00_config.R         shared constants (window, horizons, fees, gamma, paths,
  │                       predictor sets, sample dates)
  ├── 01_rolling_window.R fixed 240-month rolling OOS forecast harness
  ├── 02_prevailing_mean.R Goyal-Welch Prevailing Mean benchmark
  ├── 03_diebold_mariano.R DM (1995) test, Newey-West HAC, RMSE & MAE
  ├── 04_switching_strategy.R binary switching backtester (Sharpe, drawdown, fees)
  ├── 05_mv_utility.R      mean-variance investor, CER gain (Delta U)
  ├── 06_technical_indicators.R Neely et al. (2014) 14 signals (MA/MOM/VOL)
  ├── 07_unitroot.R        ADF test (BIC lags, MacKinnon critical values)
  ├── 08_models.R          ML model functions (rlasso/post-LASSO, ridge, enet,
  │                        PCR, PLS, random forest) for the harness API
  ├── 09_run_models.R      rolling OOS run, all models x h in {1,3,12}
  ├── 10_combine_forecasts.R 1/N and constrained Granger-Ramanathan combiners
  ├── 11_evaluate.R        Tables 2-3: accuracy, DM, Clark-West, economic value
  ├── 12_clark_west.R      Clark-West (2007) appendix test
  ├── 13_figures.R         report figures 1-3
  ├── 98_smoke_models.R    fast synthetic-data check of every model function
  └── 99_demo_synthetic.R  end-to-end smoke test on synthetic data
data/
  ├── 00_fetch_technical.R provenance + fetch of technical inputs
  ├── 01_build_panel.R     aligned panel -> data/processed/panel.csv (+ codebook)
  ├── 02_table1.R          Table 1 summary stats + ADF -> output/tables/
  ├── 03_validate_signals.R our signals vs Neely et al. published (99.98%)
  ├── download_goyal_data.R Goyal-Welch-Zafirov workbook fetcher
  ├── raw/                 source data (GWZ workbook, volume chain, published
  │                        signals reference, Neely replication workbook)
  ├── processed/           cleaned, lagged, model-ready panels
  └── README.md            DATA ALIGNMENT CONVENTION — read before building panels
output/
  ├── figures/             all report figures
  └── tables/              all report tables (Table 1-3, signal validation)
review/                   human review checkpoint packets (R1 Leon, R2 En Shao,
                          R3 Sasi, R4 Vienna)
proposal/                 proposal draft, LaTeX source, submitted PDF
docs/                     EC4308 project guidelines
archive/                  personal/legacy material (NOT shared — gitignored)
```

## Module API (Sasi's evaluation code)

Every model enters the pipeline through **one** interface:

```r
source("R/01_rolling_window.R")
oos <- rolling_oos(y, X, h = 1, w = 240, model_fn = my_model_fn)
```

`my_model_fn` must have the signature `function(y, X, X_new, ...)` and return
**one numeric forecast**. See the toy `ols_forecast_fn()` (plumbing test only,
**not** a benchmark) and `R/99_demo_synthetic.R` for the full pipeline.

## Git workflow

- One branch per person: `leon/data`, `enshao/ml`, `sasi/eval`, `vienna/report`.
- Never commit directly to `main`; merge via pull request so everyone can review.
- Raw data is gitignored by default (use the download script). To commit a data
  file anyway: `git add -f data/raw/<file>`.
- Do not commit `.Rhistory`, `.RData`, or files in `archive/`.

## Final deliverables (Week 13)

1. **Canvas, Mon 9 Nov**: final report PDF (≤15 pages, 11pt, 1.5 spacing) + code zip archive (100% reproducible, fixed seeds, raw data included).
2. **In-class**: 10-minute live presentation — all four members speak.
3. **Reading week**: individual peer review on Canvas (5% of grade).
