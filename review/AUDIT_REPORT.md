# EC4308 — Independent Self-Audit Report

**Audited:** Tue 28 Oct 2026 (~02:00–02:30 SGT), by 4 independent subagents
(data / models / statistics / report+deck) plus coordinating-agent
re-computation and code-review passes. **Rule for all auditors:** read-only,
own throwaway code, no repo edits; findings with file:line evidence.
All fixes below are applied, re-verified, committed and pushed.

## Verdict summary

| Area | Verdict | Critical | Warnings | Notes |
|---|---|---|---|---|
| Data layer | **PASS** | 0 | 0 | 1 (volume-splice wording) |
| Models & ensembles | *(pending — auditor still running)* | — | — | — |
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
cd "/Users/sasi/EC4308 project"           # or wherever you cloned it
Rscript R/11_evaluate.R                    # must reproduce the tables exactly
git status --short                        # must print nothing
Rscript data/03_validate_signals.R        # must print "Overall signal-month
                                          #  match: 99.9805 %"
```
The full pipeline is deterministic (seed 4308, no bootstrapping/MCMC): any
rerun from the same raw data reproduces every number bit-for-bit.

## Claim → evidence map (headline claims)

| Claim (report/deck) | Backing computation |
|---|---|
| No model beats the PM; R²_OOS −8.2% to −50.3% | `table2_h{1,3,12}.csv`, recomputed from `forecasts_h*.csv` |
| PM RMSE 4.399 (h=1) | `table2_h1.csv` |
| Hit rates 53–58% vs PM 60% | `table2_h*.csv` (HR, HR_pm columns) |
| Neely replication +0.36/+0.66/+0.76% (CW p ≤ 0.03) | `table5_neely_replication.csv` |
| Drawdown −50.2% → −23.4%; Sharpe 0.767 vs 0.777 | `table3_h1.csv` (BH/PM reference rows) |
| MV ΔU +1.31/+1.22/+1.06/+0.73% p.a. (10 bps) | `table3_h1.csv` |
| Subperiods −10.5/−1.2/−13.4% (rlasso, h=1) | recomputed from `forecasts_h1.csv` + `panel.csv` |
| Signals match published 99.98% | `signal_validation.csv` (2/10,262 months) |
| Determinism | two independent runs bit-identical; from-scratch zip rerun identical |

*Models-layer section to be appended when the fourth auditor reports.*
