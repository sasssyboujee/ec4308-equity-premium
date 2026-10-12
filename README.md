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
                      "sandwich", "readxl", "dplyr", "tidyr", "ggplot2"))
   ```
2. **Get the data** (from the repo root):
   ```bash
   Rscript data/download_goyal_data.R     # -> data/raw/GoyalWelchZafirov_PredictorData.xlsx
   ```
3. **Smoke-test the evaluation module** (synthetic data, no dependencies):
   ```bash
   Rscript R/99_demo_synthetic.R
   ```
4. Open `EC4308_Project.Rproj` in RStudio for a ready-made session.

## Repository layout

```
R/                      All R scripts (00_config, modules 01-05, 99_demo)
  ├── 00_config.R         shared constants (window, horizons, fees, gamma, paths)
  ├── 01_rolling_window.R fixed 240-month rolling OOS forecast harness
  ├── 02_prevailing_mean.R Goyal-Welch Prevailing Mean benchmark
  ├── 03_diebold_mariano.R DM (1995) test, Newey-West HAC, RMSE & MAE
  ├── 04_switching_strategy.R binary switching backtester (Sharpe, drawdown, fees)
  ├── 05_mv_utility.R      mean-variance investor, CER gain (Delta U)
  └── 99_demo_synthetic.R  end-to-end smoke test on synthetic data
data/
  ├── raw/                 source data (download via data/download_goyal_data.R)
  ├── processed/           cleaned, lagged, model-ready panels
  └── README.md            DATA ALIGNMENT CONVENTION — read before building panels
output/
  ├── figures/             all report figures
  └── tables/              all report tables (Table 1-3)
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
