# EC4308 Group Project — Forecasting the Equity Risk Premium Out-of-Sample

**Module**: EC4308 Machine Learning and Economic Forecasting (AY 2026/2027 Sem 1)
**Instructor**: Prof. Denis Tkachenko
**Topic**: Regularized ML, Technical Indicators & Tactical Asset Allocation
**Deliverables**: Final report (≤15 pp) + code zip on Canvas, provisionally Monday of Week 13 (confirm in Canvas); 10-min live presentation in Week 13; individual peer review in Reading Week.

## Code review status and methodological contract

This is **Topic 2: Predictive regressions in finance** in the project guidelines.
The PDF makes Monday provisional; verify the final deadline in Canvas.
The target is **simple monthly excess return**, `100*(ret-Rfree)` in percentage
points. This intentionally corrects the proposal's log-return description:
the existing mean-variance allocation needs an expected simple premium, and
converting predicted log returns would require extra assumptions. Realized
portfolio returns use `100*ret` and `100*Rfree`; annual `tbl` is only a predictor.

At h=1/3/12 the model predicts **one month's return h months ahead**, not an
h-month cumulative return. Models use 240 eligible training pairs; the PM
benchmark uses expanding history. Ridge/ENet/PCR/PLS tune on three deterministic
forward validation blocks, with h-step label availability and fold-local
preprocessing. GR weights use expanding past OOS errors, with equal-weight warmup.
The GR solver is `limSolve::lsei(type=2)`, which adds `1e-8` to the quadratic
diagonal for numerical stability. Feasibility uses an explicit `1e-7` numerical
tolerance; only residuals within that tolerance are clipped and normalized.
Larger constraint violations stop execution rather than producing forecasts.
The chosen common sample remains 1951-02 through 2025-12; historical data are
latest-vintage, not a reconstruction of every historical release calendar.

The 240-month/six-lag/instructor-specific restrictions below are recorded
project decisions; the original instructor feedback was not independently
verified. Main inference uses DM with Bartlett bandwidth h-1. Clark-West is not
used (not in the syllabus, per instructor feedback); the adapted bivariate
exercises also use one-sided squared-error DM.
All portfolios start in cash, pay equity entry/turnover costs, and have no
terminal liquidation. A constant excess-return series has an undefined Sharpe
ratio, reported as NA, not a failed forecast.

**Report and presentation revisions are deferred.** Existing PDFs, slides,
historical handoffs, timelines, checkpoint sign-offs and explanatory maps may
describe pre-correction methods/results and are not current verification.
Regenerate code outputs before interpreting them; no positive result is required.

The guideline's AI policy permits minor assistance, not bulk scripts or
AI-written motivation/interpretation/discussion. The group must review actual
usage with the instructor where necessary and provide genuine chat links/exports
and disclosure. This repository does not establish that human compliance step.

## Team & roles

| Member    | Role                       | Owns                                                                 |
| :-------- | :------------------------- | :------------------------------------------------------------------- |
| Leon      | Data / Features            | Goyal (2024) data download, 1–6 macro lags, 14 Neely signals, Table 1 |
| En Shao   | ML Models                  | `rlasso`/post-LASSO (`hdm`), Ridge, PCR, PLS, Random Forest, Granger–Ramanathan ensembles |
| Sasi      | Econometrics / Evaluation  | Rolling-window harness, Prevailing Mean benchmark, Diebold–Mariano tests, Binary Switching Strategy, Mean-Variance utility |
| Vienna    | Motivation / Report        | Literature review, economic discussion, 15-page report, presentation |

> Full plan, deadlines and Prof. Denis's feedback pivots:
> [`legacy/notes/PROJECT_TIMELINE_AND_MILESTONES.md`](legacy/notes/PROJECT_TIMELINE_AND_MILESTONES.md) (historical)

## Project rules (from Prof. Denis — do not break)

- **Analysis in R.** The forecasting and evaluation pipeline uses R (`hdm`, `glmnet`, `pls`, `ranger`, `limSolve`, `readxl`, `ggplot2`); slides are built from `deck/SLIDE_SPEC.md`.
- **Prevailing Mean is the only benchmark** — no OLS benchmarks.
- **Fixed 240-month rolling window** (20 years) for ML estimation; the PM benchmark and GR combination history expand.
- **Horizon-correct training pairs:** each predictor row at month s is paired
  with the return earned at s+h, and the target must be known by the forecast
  origin.
- **Diebold–Mariano (1995)** on squared/absolute forecast errors; no Clark–West test (not in the syllabus).
- Economic evaluation **net of transaction costs** (10 bps baseline, 5 & 20 bps sensitivity),
  charged per switch. Rationale: major US brokers now charge $0 online commission
  on ETFs (e.g. Schwab pricing page, accessed 2026-11-07) and a one-cent SPY spread
  is ~0.14 bps, so 10 bps is a conservative all-in cost; 20 bps stresses earlier,
  costlier decades.
- **No lookahead leakage** — see the alignment convention in `data/README.md`.

## Getting started

1. **Install R packages** (once per machine):
   ```r
   install.packages(c("hdm", "glmnet", "pls", "ranger",
                      "readxl", "ggplot2", "limSolve"))
   ```
   Presentation tooling is optional and deferred; it is not needed for the
   code/data/results reproduction path.
2. **Use the raw data supplied in the code ZIP** (from its root):
   ```bash
   Rscript data/00_fetch_technical.R         # verify technical inputs (volume chain)
   ```
   Do not refresh the source workbook when reproducing a frozen submission.
   `data/download_goyal_data.R` is an optional refresh, not a reproduction step.
3. **Run regression and model smoke tests**:
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
Rscript R/09_run_models.R 1          # all models x h in {1,3,12}
Rscript R/09_run_models.R 1 tech 1   # REQUIRED by Table A1
Rscript R/09_run_models.R 1 macro 1  # REQUIRED by Table A1
Rscript data/01_build_panel.R expanded data/processed/panel_expanded.csv
Rscript R/09_run_models.R 1 full 1,3,12 data/processed/panel_expanded.csv _expanded
                                     # -> expanded_variant_summary.csv
Rscript R/15_neely_bivariate.R       # bivariate robustness (fixed window)
Rscript R/16_neely_replication.R     # adapted expanding-window exercise
Rscript R/11_evaluate.R              # -> Tables 2-3 (all horizons)
Rscript R/17_switching_overlap.R     # alternative timing (different dates)
Rscript R/13_figures.R               # -> Figures 1-4 + h=1 subperiod CSV
Rscript R/14_make_latex_tables.R     # -> LaTeX table fragments
Rscript scripts/make_submission_zip.R # -> submission/EC4308_Project_Submission.zip
```

This is the complete **code/data/results** path. Rendering the deferred report
and slides is separate (`tectonic` and `python-pptx`); do not imply their content
is synchronized merely because numerical output generation succeeded.
The legacy slide generator explicitly stops on the corrected table schema until
its content is reviewed; it must not regenerate slides with unsupported CW claims.
The expanded panel uses 146 predictors (8 extra Goyal et al. 2024 variables).
The rest are excluded because they are full-sample constructions (look-ahead),
have no monthly data, or do not cover 1950-08..2025-12; see `data/README.md`.

The historical report build used Tectonic. Install it separately before
compiling the PDF; historical compilation does not validate current content.

On Windows, the forecast runner uses one core because forked workers are not
supported; full runs will take longer.

Model fitting uses fixed seeds and `num.threads = 1` for ranger. After
changing model code or alignment, regenerate forecasts and all dependent
outputs before treating previously generated tables as current.

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
  ├── 11_evaluate.R        Tables 2-3: accuracy, DM, economic value
  ├── 13_figures.R         report figures 1-4 + h=1 subperiod CSV
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
  └── tables/              report tables, including h=1 subperiod results
review/                   project map (PROJECT_MAP.md / .html)
deck/                     slide build spec + speaker scripts
legacy/                   superseded notes, review packets, old deck (historical only)
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

1. **Canvas, Mon 9 Nov**: final report PDF (≤15 pages, 11pt, 1.5 spacing) + code zip archive (fixed seeds and raw data included; a clean-directory rerun has not been independently verified).
2. **In-class**: 10-minute live presentation — all four members speak.
3. **Reading week**: individual peer review on Canvas (5% of grade).
