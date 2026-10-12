# data/ — Data conventions for the EC4308 project

## Folder layout

| Folder      | Contents                                                                 |
| :---------- | :----------------------------------------------------------------------- |
| `data/raw/` | Untouched source files: the Goyal–Welch–Zafirov workbook, Neely technical indicator inputs. **Never edit by hand.** |
| `data/processed/` | Cleaned, lagged, model-ready panels produced by scripts. One script per artifact; regeneration must be reproducible. |

The raw Goyal–Welch–Zafirov (2024 RFS, continuously updated) workbook can be
(re)downloaded any time with:

```bash
Rscript data/download_goyal_data.R
```

which saves `data/raw/GoyalWelchZafirov_PredictorData.xlsx` (sheets: `ReadMe`,
`Monthly`, `Quarterly`, `Annual`; monthly data runs 1871:01 → latest).

## Alignment convention (CRITICAL — read before building the panel)

All processed panels must follow the convention the evaluation harness expects
(see `R/01_rolling_window.R`):

- **Row `t` of the target `y`** = equity premium EARNED in month `t`
  (S&P 500 log return over the 3-month T-bill rate).
- **Row `t` of the predictor matrix `X`** = predictors OBSERVABLE at the END
  of month `t`. This means every lagged variable is shifted so that its row
  index equals the month in which it can be used.
- Forecasts for month `t+h` are made at the end of month `t` using only
  rows `≤ t` of `y` and `X` — no lookahead leakage, ever.

## Lag construction (Leon)

For every non-technical macro predictor, create columns for lags 1–6
(`x_lag1`, …, `x_lag6`), where `x_lagk[t] = x[t-k]`. Technical indicators
(6 MA, 2 MOM, 6 OBV per Neely et al. 2014) are computed on price/volume
with the same alignment.

## Sample period

Start date is the first month with **zero missing values** across ALL
predictors used (target: ≈1947–1952 post-WWII, per Prof. Denis's directive).
Document the final start/end dates in `Table 1` and in the report.
