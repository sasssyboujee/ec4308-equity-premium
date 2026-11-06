# EC4308 — Independent Self-Audit Report

> **Historical audit, superseded by the current code corrections.** Cash units,
> target labels, tuning, expanded predictors, ADF and constrained combinations
> required further fixes. Earlier clean-run/results claims are not current
> verification. See [README](../README.md); report/slides are deferred.

**Original audit:** Wed 28 Oct 2026 (~02:00–02:30 SGT), by 4 independent
subagents (data / models / statistics / report+deck) plus coordinating-agent
re-computation and code-review passes. **Rule for all auditors:** read-only,
own throwaway code, no repo edits; findings with file:line evidence. The
original audit's fixes were applied and re-verified at that time. The
2026-11-01 follow-up changes described below are in the working tree and have
not been committed or pushed.

> **Superseding update (2026-11-01):** a follow-up audit found that rolling
> model training paired same-month predictors and returns instead of pairing
> \(X_s\) with \(y_{s+h}\). The original verdict and numerical claim map
> below are historical and must not be used as current results. The harness
> and benchmark were corrected, the full forecasts and dependent outputs
> regenerated, and the current claim map is at the end of this file. The
> final report, presentation, and 38-file submission archive were rebuilt and
> verified. The corrected 158-predictor rerun is complete: all 27 model /
> horizon OOS $R^2$ estimates are negative (−12.265% to −0.228%), with 658,
> 654, and 636 forecasts for h=1,3,12. Its summary was regenerated. No
> clean-directory reproduction has been completed.

## Verdict summary

| Area | Verdict | Critical | Warnings | Notes |
|---|---|---|---|---|
| Data layer | **PASS** | 0 | 0 | 1 (volume-splice wording) |
| Models & ensembles | **PASS** | 0 | 1 (fixed) | 1 (hdm predict quirk, not our bug) |
| Statistics & evaluation | **PASS** | 0 | 0 | 3 (numerical conventions, documented) |
| Report, deck & zip | **PASS** | 0 | 2 (fixed) | 2 (fixed) |
| Coordinating-agent passes | **PASS** | 0 | 0 | — |

## Findings & fixes

### Data layer (auditor: independent subagent)
1. **NOTE — volume-splice correlation claim** (data/README.md:49,
   data/00_fetch_technical.R:18, report/main.tex:123, R1 packet): the
   "cor 0.9999 on the 1985–2011 overlap" claim was not reproducible from the
   shipped 2012+ CSV (it starts where the paper series ends). Auditor
   independently re-fetched Yahoo data and confirmed the claim is TRUE for
   the untruncated series (cor = 0.999895).
   **Fix:** all four locations now state the correlation is verified on the
   untruncated Yahoo series. No data error; zero analysis impact.
2. Everything else PASSED: panel integrity (899×100, 0 NAs, target
   = 100·(ret−Rfree) to machine precision), lag construction, no-lookahead,
   signal validation (99.9805%), volume chain continuity, Table 1 moments.

### Models & ensembles (auditor: independent subagent)
8/8 checks PASS: rlasso manual forecast ≡ hdm's predict (5/5 post=FALSE,
4/5 post=TRUE; the 5th case is the degenerate zero-selection edge below);
glmnet CV strictly in-window, seeded, no leakage paths; PCR/PLS PRESS
indexing verified against an independent manual 10-fold CV (no off-by-one);
ranger settings + seed determinism verified; clean_X drops constant columns
identically from X and X_new; GR combination no-lookahead proven empirically
for h=1/3/12 (future-row perturbation leaves past forecasts unchanged) and
constraints verified on every row (Σw=1 within 1e-9, w≥0); harness indexing
verified call-by-call with a recording model_fn (268 calls).
1. **WARNING (fixed) — post-LASSO zero-selection edge:** when LASSO selects
   zero variables, hdm stores all-zero coefficients but `$intercept =
   mean(y)`; our manual forecast returned 0 instead of the intercept.
   **Fix:** one-line guard in `rlasso_forecast_fn` (R/08_models.R:62-68);
   verified on a forced degenerate case (guard −0.190782 = hdm −0.190782).
   Never triggered in production (0 exact-zero forecasts in any CSV).
2. **NOTE — hdm 0.3.2 quirk:** hdm's own `predict.rlasso` misbehaves on
   1-row matrix newdata (returns a 9×9 matrix); our manual formula avoids
   calling it, so we are unaffected.

### Statistics & evaluation (auditor: independent subagent)
All PASS. Notes (documented conventions, immaterial):
- DM vs `forecast::dm.test`: T vs T−1 variance at h=1 (ratio √(659/658)
  exactly); Bartlett weights at h>1; ≤2.5% statistic differences, no
  inference flips. Documented in R/03 header.
- CW: bit-identical to hand computation.
- ADF: ≤0.5% vs `tseries` at equal lags (RSS/n vs RSS/(n−p−3) convention);
  significance bins use asymptotic MacKinnon CVs.
- **Fix applied:** Table 1 note now states skew/kurt are population moments,
  kurtosis is not excess.

### Report, deck & zip (auditor: independent subagent)
1. **WARNING — deck slide 6 "PM 61%"** → actual PM hit rate 0.599/0.598/0.602.
   **Fix:** 60% in `deck/make_deck.py`; pptx rebuilt (verified in-file).
2. **WARNING — figure4_subperiods.png had no generator script** (deck-only).
   **Fix:** generation moved into `R/13_figures.R`; regenerated via pipeline.
3. **NOTE — GWZ "57 predictors"** not confirmable from the paper abstract.
   **Fix:** reworded to "expanded dataset of 57 monthly series" (verifiable
   from our workbook's 57 monthly columns) in deck + speaker script.
4. **NOTE — Appendix A1 renders as "Table 5"** (continuous numbering).
   Accepted; caption explains it.
5. Bibliography: **8/8 references verified correct**, including the GWZ 2024
   entry corrected to *"A Comprehensive 2022 Look…"*, RFS 37(11),
   DOI 10.1093/rfs/hhae044.
6. Subperiod claim −13.5% → **−13.4%** (exact value −13.4478); fix verified
   by auditor's independent recomputation.

### Coordinating-agent passes
- Determinism re-proof: fresh `R/11_evaluate.R` → all 6 tables bit-identical;
  smoke tests + signal validation re-run clean.
- GR no-lookahead: corrupting future candidate forecasts leaves all past
  combined forecasts unchanged (exactly 0); weights sum to 1, non-negative.
- Switching backtest: hand-computed 3-month example matches module to the
  last digit (fees applied on switches only).
- Re-computation of headline claims (R²_OOS all models × horizons, PM RMSE,
  subperiods): all match committed tables.

## How YOU can verify this yourself (3 commands)

```bash
Rscript R/99_demo_synthetic.R              # target-alignment/sample-count checks
Rscript R/11_evaluate.R                    # regenerate evaluation tables
git diff --check                           # verify patch whitespace
Rscript data/03_validate_signals.R         # must print "Overall signal-month
                                           # match: 99.9805 %"
```
The corrected code uses fixed seeds (seed 4308 and single-threaded ranger).
However, a complete clean-directory rerun from the final submission ZIP has
not been performed; bit-for-bit reproducibility should not be claimed yet.

## Claim → evidence map (headline claims)

| Claim (report/deck) | Backing computation |
|---|---|
| All OOS R² estimates negative; range −15.49% to −0.38% | `table2_h{1,3,12}.csv` |
| PM RMSE 4.403 / 4.409 / 4.443 (h=1/3/12) | `table2_h{1,3,12}.csv` |
| No statistically significant DM/CW improvement; minimum one-sided DM p=0.677 and CW p=0.105 | `table2_h{1,3,12}.csv` |
| Corrected Neely VOL(2,9)/VOL(2,12)/VOL(3,12): +0.19/+0.11/+0.53%; no 5% significance | `table5_neely_replication.csv` |
| LASSO switching h=1: wealth $232.7 vs $341.9; max drawdown −44.4% vs −50.2% | `table3_h1.csv` |
| h=1 mean-variance ΔU negative for every forecast model at 10 bps | `table3_h1.csv` |
| Expanded 158-predictor robustness: all 27 OOS R² estimates negative, −12.265% to −0.228% | `data/processed/expanded_variant_summary.csv` |
| LASSO subperiod R² h=1: −0.63/−1.20/−1.94% | recomputed from `forecasts_h1.csv` + `panel.csv` |
| Signals match published 99.98% | `signal_validation.csv` (2/10,262 months) |
| Forecast counts | h=1: 658; h=3: 654; h=12: 636, with no missing forecasts |

The corrected outputs do not support the previous claims of significant
positive Neely replication, model inferiority by DM tests, drawdown halving,
or positive h=1 mean-variance gains.
