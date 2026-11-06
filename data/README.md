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
  (`100*(ret-Rfree)`, simple monthly total equity return minus realized cash).
- **Row `t` of the predictor matrix `X`** = predictors OBSERVABLE at the END
  of month `t`. This means every lagged variable is shifted so that its row
  index equals the month in which it can be used.
- Forecasts for month `t+h` are made at the end of month `t` using only
  rows `≤ t` of `y` and `X` — no lookahead leakage, ever.
- A model's training row `X[s]` is paired with the future target `y[s+h]`.
  At origin `t`, only pairs with `s+h ≤ t` are eligible. The fixed rolling
  window counts 240 such usable pairs, so the first forecast occurs after the
  full window and horizon are available.

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
| `data/raw/spx_volume_2012_2025.csv` | Yahoo Finance `^GSPC` daily bars, monthly average (yfinance) | 2012-01–2025-12 | extension; the untruncated Yahoo series used to build it has cor 0.9999 with the paper series on the 1985–2011 overlap (independently re-verified; the shipped 2012+ CSV itself starts where the paper series ends, so it contains no overlap months) |
| `data/raw/neely_signals_published_1950_2011.csv` | Neely et al. (2014) published signals | 1950-12–2011-12 | validation reference only — NOT used to build the panel |

The VOL signals are invariant to a global constant rescaling, not necessarily
to rescaling only one side of a splice. The untruncated daily source/overlap
used for the earlier correlation claim is not shipped and was not verified
by the current code audit; the provided monthly extension is the raw input.
`data/03_validate_signals.R` reproduces the published signals
with an overall match of **99.98%** (12/14 signals exactly; MOM_12 and
VOL_2_9 differ in one month each, at 1968-03 and 1980-04; the cause is not
established by signal agreement alone).

## Sample period

The chosen start is **1951-02**, not the earliest possible date: the script
finds complete technical signals already at 1950-12. End date **2025-12**. Panel: 899 months,
100 columns (date + y + 84 macro-lag + 14 technical + ...). Document the
final start/end dates in `Table 1` and in the report.

## Target, economic units and expanded predictors

The forecast target is a **simple** excess return in percentage points.
Portfolio equity and cash inputs are `100*ret` and `100*Rfree`, respectively.
`tbl` is an annual decimal yield used as a predictor, not the realized monthly
cash return. This makes the forecast target and mean-variance allocation coherent.

The optional expanded set adds eight eligible variables (48 lagged columns),
for 146 predictors. Of the other Goyal et al. (2024) variables in the workbook:
`fbm`, `ogap`, `sntm`, `tchi` and `shtint` are excluded because the workbook ReadMe
explicitly warns their supplied values use full-sample information (lagging does
not fix that leakage); `eqis`, `cay`, `i/k`, `pce`, `govik`, `skew`, `crdstd`,
`accrul`, `cfacc`, `gpce`, `gip` and `house` have no monthly data; and `csp`, `vp`,
`impvar`, `vrp`, `ndrbl`, `ygap`, `rsvix` and `disag` start after 1950-08 or end
before 2025-12, so they would shorten the common 1951-02..2025-12 sample. These
latest-vintage data also do not establish historical real-time availability for
every macro release.
