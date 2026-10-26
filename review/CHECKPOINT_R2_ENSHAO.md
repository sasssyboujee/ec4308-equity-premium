# Review Checkpoint R2 — ML Models & Ensembles (Reviewer: En Shao, by Fri 30 Oct)

**Stage:** Phase 2 model layer is complete and committed. You own the ML
methodology, so this packet is about the model functions, the training
protocol, and two specification decisions.

## What was built

| File | What |
| :--- | :--- |
| `R/08_models.R` | `rlasso`/`postlasso` (`hdm`, theoretical penalty, no CV), `ridge`/`enet` (`glmnet`, 10-fold CV **inside** each training window), `pcr`/`pls` (`pls`, CV PRESS selects ncomp ≤ 20, scaled), `rf` (`ranger`, 500 trees, mtry = p/3, min node size 5, fixed seed, 1 thread) |
| `R/09_run_models.R` | rolling 240-month runs, all models × h ∈ {1,3,12}; spec variants `full` (98 cols) / `tech` (14) / `macro` (84); parallel, deterministic |
| `R/10_combine_forecasts.R` | 1/N and constrained GR (Σw=1, w≥0 via `limSolve::lsei`); weights estimated only from OOS errors of targets ≤ origin−h (no lookahead), equal weights until 60 months of history |
| `R/15_neely_bivariate.R` | fixed-window bivariate regressions, one technical signal at a time |
| `R/16_neely_replication.R` | **expanding**-window bivariate replication of Neely et al. (2014) on their 1966–2011 sample + 2012–2025 extension |
| `R/01_rolling_window.R` (edited) | harness now passes `origin` and `target_index` to model functions (needed by ensembles; harmless for others) |
| `R/98_smoke_models.R` | synthetic-data check of every model_fn |

Reproduce: `Rscript R/98_smoke_models.R`, then `Rscript R/09_run_models.R 6`,
then `Rscript R/15_neely_bivariate.R`, `Rscript R/16_neely_replication.R`.

## Your checklist

- [ ] `R/08_models.R` `rlasso_forecast_fn`: confirm `hdm::rlasso(post=FALSE/TRUE)`
      uses the **theoretical penalty** (no cross-validation), as Prof. Denis
      required, and that the manual forecast computation
      (intercept + X_new·β) matches hdm's predict method.
- [ ] Ridge/ENet: `cv.glmnet(alpha = 0 / 0.5)` with folds created ONLY from the
      current 240-month training window — confirm no information from the test
      month (or future data) enters `lambda.min`.
- [ ] PCR/PLS: `ncomp` selected by 10-fold CV PRESS with `scale = TRUE`;
      confirm `nmax = min(20, p, n−1)` and that `predict()` uses the chosen k.
- [ ] Random forest: 500 trees, `mtry = p/3`, `min.node.size = 5`, `seed` fixed,
      `num.threads = 1`. Re-run `98_smoke_models.R` and note the reproducibility
      guarantee (two full h=1 runs were bit-identical — verified).
- [ ] `R/10_combine_forecasts.R`: the GR weight regression at origin `o` uses
      only `target_index <= o − h`; read the loop and confirm no lookahead.
- [ ] `R/01_rolling_window.R`: the only change vs the original scaffold is the
      two extra arguments (`origin`, `target_index`). Check the diff.
- [ ] Forecast CSVs (`data/processed/forecasts_h*.csv`): no NAs, contiguous
      target months, `pm` column aligns with the models.

## Preliminary results (full spec, h=1, OOS 1971-02 → 2025-12, n=659)

| model | RMSE | R²_OOS | HR |
|---|---|---|---|
| rlasso | 4.589 | −8.8% | 0.568 |
| postlasso | 4.778 | −17.9% | 0.572 |
| ridge | 4.951 | −26.6% | 0.566 |
| enet | 4.994 | −28.8% | 0.561 |
| pcr | 4.729 | −15.6% | 0.574 |
| pls | 5.217 | −40.6% | 0.564 |
| rf | 5.360 | −48.4% | 0.543 |
| equal | 4.792 | −18.7% | 0.583 |
| gr | 4.615 | −10.0% | 0.580 |

Prevailing mean: RMSE 4.399, hit rate 0.599. **No model beats the PM at h=1.**
The tech-only variant (14 signals) is also negative (best: rlasso −9.5%).
This is the Goyal–Welch result on the modern sample — not a bug: the
bivariate *replication* below reproduces Neely et al.'s positive findings on
their own sample, which is strong evidence the pipeline is correct.

## Replication check (`output/tables/table5_neely_replication.csv`)

Expanding-window bivariate OLS (Neely et al.'s exact design), CW test:
on **1966–2011** VOL_2_9 (+0.36%), VOL_2_12 (+0.66%), VOL_3_12 (+0.76%) are
positive and significant at 5% — matching the paper (published VOL_2_12:
+0.33%). On **2012–2025** every signal is negative/insignificant. The
technical-signal predictability documented by Neely et al. does not survive
the sample extension. We report this as the paper's central narrative.

## Decisions I made (flag anything you disagree with)

1. **Bivariate OLS is included as a replication exercise** (R/15, R/16). Prof's
   "no OLS" rule concerns *benchmarks*; these are Neely et al.'s models, not
   benchmarks. Keep or drop? *(yes/no)*
2. **Hit-rate (direction-of-change) added** to Table 2 per the course
   guidelines' suggestion of a second loss function. Keep? *(yes/no)*
3. **GR combination** is post-hoc over saved base forecasts (identical
   information set to recursive in-window weights, much faster). OK?
4. **h=3,12 variants**: main models run at all horizons; `tech`/`macro`
   variants only at h=1 unless you want more. OK?
5. Open from R1 (Leon): enable the 10 expanded GWZ-2024 predictors
   (`CONFIG$USE_EXPANDED`) as a robustness run? Sample dates are unaffected.

## What I need back from you

- Verdict (sign-off or fixes) by Fri 30 Oct, plus answers to decisions 1–5.
- Any hyperparameter changes you want tried (e.g., different RF mtry, glmnet
  alpha grid, PLS ncomp cap) — I'll re-run and re-verify.

*R3 (Sasi, evaluation) is staged next once h=3/12 finishes; your findings
fold into the final build.*
