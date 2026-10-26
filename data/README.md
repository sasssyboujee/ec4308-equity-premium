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

## Technical indicator inputs (added Phase 1)

The 14 Neely et al. (2014) signals are computed by `R/06_technical_indicators.R`
from two inputs:

| File | Source | Period | Notes |
| :--- | :--- | :--- | :--- |
| `data/raw/GoyalWelchZafirov_PredictorData.xlsx` | Amit Goyal's site | 1871–2025 | S&P index level (`price` column) for MA/MOM |
| `data/raw/spx_volume_1950_2011.csv` | Neely et al. (2014) replication workbook (shipped as `data/raw/neely2014_Returns_econ_tech.xls`, from [github.com/szmnkrisz/EquityReturnPrediction](https://github.com/szmnkrisz/EquityReturnPrediction)) | 1950-01–2011-12 | monthly average daily volume, the paper's own series |
| `data/raw/spx_volume_2012_2025.csv` | Yahoo Finance `^GSPC` daily bars, monthly average (yfinance) | 2012-01–2025-12 | extension; cor 0.9999 with the paper series on the 1985–2011 overlap |
| `data/raw/neely_signals_published_1950_2011.csv` | Neely et al. (2014) published signals | 1950-12–2011-12 | validation reference only — NOT used to build the panel |

The VOL signals compare moving averages of on-balance volume, so they are
invariant to any constant volume rescaling; the 2012+ splice is therefore
immaterial. `data/03_validate_signals.R` reproduces the published signals
with an overall match of **99.98%** (12/14 signals exactly; MOM_12 and
VOL_2_9 differ in one month each — 1968-03 price revision, 1980-04 volume
revision).

## Sample period

Start date is the first month with **zero missing values** across ALL
predictors used: **1951-02** (the VOL signals bind — volume starts 1950-01
plus a 12-month OBV burn-in). End date **2025-12**. Panel: 899 months,
100 columns (date + y + 84 macro-lag + 14 technical + ...). Document the
final start/end dates in `Table 1` and in the report.
