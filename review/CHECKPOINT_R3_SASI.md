# Review Checkpoint R3 — Evaluation, Tests & Trading Strategies (Reviewer: Sasi, by Wed 4 Nov)

**Stage:** Phase 3 complete. You own the econometric evaluation, so this
packet covers the tests, the economic strategies, and the numbers you will
present and defend.

## What was built / run

| Artifact | Path |
| :--- | :--- |
| Forecasts, all models × h ∈ {1,3,12} | `data/processed/forecasts_h{1,3,12}.csv` (full spec), `forecasts_h1_tech.csv`, `forecasts_h1_macro.csv`, `forecasts_h1_neely_biv.csv` |
| Table 2 (accuracy, DM, CW, hit rates) | `output/tables/table2_h{1,3,12}.csv` |
| Table 3 (economic value + BH/PM reference rows) | `output/tables/table3_h{1,3,12}.csv` |
| Table 5 (Neely replication/extension) | `output/tables/table5_neely_replication.csv` |
| Figures 1–3 | `output/figures/figure{1,2,3}*.png` |
| Evaluator / tests | `R/11_evaluate.R`, `R/03_diebold_mariano.R`, `R/12_clark_west.R`, `R/04_switching_strategy.R`, `R/05_mv_utility.R` (yours, unchanged) |

Reproduce: `Rscript R/09_run_models.R 6` → `Rscript R/11_evaluate.R` →
`Rscript R/13_figures.R`. Two independent full runs of h=1 were bit-identical
(determinism verified).

## Your checklist

- [ ] **DM implementation**: `R/03_diebold_mariano.R` (your module) — loss
      differential on squared/absolute errors, Newey–West HAC with lag h−1,
      one-sided H1 "model more accurate". Confirm the lag choice for h=3/12
      (11 lags at h=12) and that `hac_var_mean` matches Newey–West.
      *Cross-check done for you:* vs `forecast::dm.test` at h=1 our statistic
      differs only by the T vs T−1 variance denominator (2.97897 vs 2.97671,
      T=659); at h=3 the additional ~2% comes from Bartlett kernel weighting
      (ours) vs raw autocovariance sums (forecast). Both are consistent HAC
      estimators; the note is documented in the module header.
- [ ] **CW appendix**: `R/12_clark_west.R` — adjusted loss differential
      f = e₁² − [e₂² − (f₁−f₂)²] with HAC t-stat. Verify against your lecture
      formula.
- [ ] **Switching strategy**: `R/04_switching_strategy.R` (yours) — position
      for month t uses the most recent h-month-ahead forecast of y[t] (made at
      origin t−h); fees 5/10/20 bps; wealth, Sharpe, maxDD, switches,
      exposure. Check the h>1 timing note in `R/11_evaluate.R` (header comment).
- [ ] **MV utility**: `R/05_mv_utility.R` (yours) — γ=3, w ∈ [0,1.5],
      realized-variance window 60, CER ΔU vs PM-driven benchmark.
- [ ] **Reproducibility**: re-run `Rscript R/11_evaluate.R` yourself; it must
      reproduce `table2_h1.csv` exactly.
- [ ] **Alignment of economic inputs**: equity return = 100·GWZ `ret`
      (incl. dividends), T-bill = `tbl/12` % per month — sanity-check one month.

## The results you will defend

**Statistical (Table 2):** no model beats the prevailing mean at any horizon.
h=1: PM RMSE 4.399; best model rlasso R²_OOS = −8.8% (DM p = 0.999 in the
"worse" direction), GR −10.0%; hit rates 54–58% vs PM 60%. h=3: rlasso −8.2%.
h=12: rlasso −11.5%. Macro-only variant: rlasso −0.9% (closest to PM).

**Replication (Table 5):** expanding-window bivariate design of Neely et al.
(2014): VOL(2,9)/VOL(2,12)/VOL(3,12) positive and significant on 1966–2011
(+0.36/+0.66/+0.76%, CW p ≤ 0.03); all negative and insignificant on
2012–2025. Our pipeline reproduces the published finding on their sample —
the extension is what kills it.

**Economic (Table 3):** switching (post-LASSO, 10 bps): wealth $67.7 vs
buy-and-hold $346.5, but maxDD −23.4% vs −50.2% and Sharpe 0.767 vs 0.777.
MV investor: ΔU = +1.31% p.a. (post-LASSO), +1.22% (rlasso), +1.06% (GR),
+0.73% (equal) at 10 bps; ranking stable at 5/20 bps.

## Decisions I made (flag any you disagree with)

1. **h>1 economic timing**: position/weights for month t use the forecast of
   y[t] made h months earlier (most recent available h-ahead forecast of that
   month). Alternative would be overlapping positions held h months — say if
   you prefer that and I'll implement it.
2. **Hit rate added** to Table 2 (direction-of-change loss, per guidelines).
3. **Reference rows** (Buy-and-Hold, PM-driven) added to Table 3.
4. **CW reported in Table 2**, appendix section discusses it (no separate table).
5. **Transaction-cost sensitivity** at 5/20 bps reported in Table 3.

## What I need back from you

- Verdict (sign-off or fixes) by Wed 4 Nov; answers to decisions 1–5.
- You will do the **Canvas upload Mon 9 Nov** — files will be staged in
  `submission/` by Sun 8 Nov (report PDF + code/data zip).

*R4 (Vienna, report & deck) is being staged in parallel; your findings fold
into the final build before submission.*
