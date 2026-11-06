# AGENT HANDOFF — EC4308 Equity-Premium Project

> **Superseded technical snapshot.** The current code audit corrected cash
> units, simple-return labels, tuning, expanded predictors and constrained
> combinations. Results/sign-offs below are historical, not current validation.
> Use [README](README.md) for the current contract and run instructions.
> Report and presentation synchronization is deferred.

> **For AI agents working on behalf of the EC4308 group members.**
> Preserve this document as historical context, not a current source of results.
> **State captured:** Sun 1 Nov 2026 · **Deadline:** Mon 9 Nov 2026.

---

## 1. What this project is

EC4308 (NUS, Prof. Denis Tkachenko): forecast the **monthly US equity risk
premium** (S&P 500 return over the risk-free rate) out-of-sample using
regularized machine learning + the 14 technical indicators of Neely, Rapach,
Tu & Zhou (2014), benchmarked against the **prevailing (historical) mean**.
Deliverables: report PDF (≤15 pp, 11pt, 1.5 spacing) + code/data zip on
Canvas by Mon 9 Nov; 10-min live talk Week 13; individual peer review in
Reading Week. The proposal was already submitted and Prof. Denis's feedback
is baked into the design.

## 2. Current state — READ THIS FIRST

The forecast-alignment correction and main full-spec analysis have been
regenerated. The report PDF and presentation have been rebuilt and checked.
The corrected expanded-predictor robustness run is complete; its 27 model /
horizon OOS $R^2$ values are all negative (−12.265% to −0.228%), and the
summary was regenerated. The working tree contains uncommitted changes and
has not been pushed. A clean-directory rerun from the submission ZIP has not
been performed. Remaining work: obtain the human reviews below and upload the
report and code/data archive to Canvas.

If you are an agent for one of the four members: your job is **review and
sign-off**, not re-doing the project. Your owner's review packet (Section 9)
already contains the exact checks, and most cross-checks were pre-computed.

## 3. Repository map

```
R/                      analysis code (00-17, 98, 99) — see pipeline below
data/
  raw/                  GWZ workbook, volume chain, published-signal reference
  processed/            panel.csv, codebook.csv, forecasts_h{1,3,12}.csv,
                        *_tech/_macro/_neely_biv/_expanded variants
  0X_*.R                fetch/build/table1/validation scripts
report/main.tex         LaTeX source  →  report/main.pdf (14 pages)
deck/                   make_deck.py → EC4308_Presentation.pptx;
                        speaker_scripts.md (per-person lines + timing)
output/tables/          table1..table5, tableA1, signal_validation (CSV + .tex)
output/figures/         figure1..figure4 PNG
review/                 CHECKPOINT_R1_LEON.md .. R4_VIENNA.md (review packets)
scripts/make_submission_zip.R   builds submission/EC4308_Project_Submission.zip
SUBMISSION_CHECKLIST.md steps for the Canvas upload (Mon 9 Nov)
PROJECT_TIMELINE_AND_MILESTONES.md  full roadmap + AI-handoff status log
```

## 4. The analysis pipeline (exact order)

```bash
# from the repo root; R 4.6.1 with all packages installed (Section 7)
Rscript data/01_build_panel.R            # panel 1951-02..2025-12, 899 mo, 98 cols
Rscript data/02_table1.R                 # Table 1 (summary + ADF)
Rscript data/03_validate_signals.R       # our signals vs published: 99.98%
Rscript R/09_run_models.R 1              # all models x h=1,3,12
                                         # Windows is serial; corrected run took 146 min
Rscript R/09_run_models.R 1 tech 1       # h=1 technical-only robustness
Rscript R/09_run_models.R 1 macro 1      # h=1 macro-only robustness
Rscript R/15_neely_bivariate.R           # bivariate robustness (fixed window)
Rscript R/16_neely_replication.R         # expanding-window replication/extension
Rscript R/11_evaluate.R                  # Tables 2-3 (accuracy, DM/CW, economic)
Rscript R/13_figures.R                   # Figures 1-4
Rscript R/14_make_latex_tables.R         # .tex table fragments
cd report && tectonic -r 2 main.tex      # report/main.pdf (validated build)
python3 deck/make_deck.py                # deck/EC4308_Presentation.pptx
Rscript scripts/make_submission_zip.R    # submission zip (code+data+LaTeX source)
```

Everything is deterministic (fixed seeds, `num.threads = 1` for ranger).
The corrected forecast run and downstream outputs were regenerated in the
working tree. A complete clean-directory rerun from the submission ZIP has
not been performed; do not claim clean-room reproducibility.

## 5. Key results (numbers to know)

- **Headline:** all model OOS R² estimates are negative, ranging from −15.49%
  to −0.38% across horizons. The closest models are LASSO at h=1 (−1.06%)
  and post-LASSO at h=3 (−0.38%) and h=12 (−0.52%). One-sided DM tests do
  not show significant improvement (minimum p=0.677); CW p-values are all
  above 0.10. PM RMSE is 4.403, 4.409, and 4.443 for h=1,3,12.
- **Replication:** the corrected expanding-window estimates on 1966–2011
  are VOL(2,9) +0.19% (CW p=0.193), VOL(2,12) +0.11% (p=0.247), and
  VOL(3,12) +0.53% (p=0.077); none reaches 5% significance. The selected
  2012–2025 extension estimates are negative and insignificant.
- **Subperiods (h=1, rlasso):** −0.63% (1971–99), −1.20% (2000–11), and
  −1.94% (2012–25). These are descriptive; they do not establish a causal
  explanation for differences across periods.
- **Economic results (h=1):** LASSO switching ends at $232.7 per dollar
  versus $341.9 for buy-and-hold; maximum drawdown is −44.4% versus −50.2%.
  Mean-variance ΔU is negative for every forecast model at 10 bps (LASSO
  −0.39%, post-LASSO −2.07%, GR −0.99%, equal-weight −0.76% p.a.).
- **Predictor-set variants (h=1):** all nine models have negative OOS R²
  for full, technical-only, and macro-only sets. Technical-only is closest
  to the benchmark for several models; the comparisons are descriptive.
- **Expanded GWZ-2024 variant:** all 27 OOS $R^2$ values from the corrected
  158-predictor rerun are negative (−12.265% to −0.228%). Counts are 658,
  654, and 636 forecasts for h=1,3,12. The regenerated summary is
  `data/processed/expanded_variant_summary.csv`; this robustness result is
  descriptive and is not included in the report's headline claims.

## 6. Design conventions — DO NOT BREAK

1. **R only** for the analysis (Prof's rule).
2. **Prevailing mean is the only benchmark** — no OLS benchmarks.
3. **Fixed 240-month rolling window**, horizons h ∈ {1,3,12}.
4. **No lookahead:** row t of X = information observable at end of month t;
   macro lag k: `x_lagk[t] = x[t-k]`; technical signals use data ≤ t.
5. **DM test** on squared/absolute errors, Newey-West HAC lag = h−1
   (Bartlett kernel, T-normalization — differs negligibly from
   `forecast::dm.test`, documented in `R/03_diebold_mariano.R`).
6. **Clark-West** is an appendix check only.
7. **GR combination:** weights ≥ 0, sum = 1, estimated only from OOS errors
   of targets ≤ origin−h; equal weights until 60 months of history.
8. **Economic evaluation net of costs** (10 bps baseline, 5/20 sensitivity);
   both h>1 position timings implemented (`R/11_evaluate.R` timing A,
   `R/17_switching_overlap.R` timing B — same conclusions).
9. **Seeds fixed** (CONFIG$SEED = 4308); reproducibility verified.

## 7. Environment facts

- The final report was compiled successfully with Tectonic; the PDF has 14
  pages. A non-fatal Fontconfig configuration message may appear.
- The presentation was rebuilt with Python and python-pptx; it has 10 slides
  with speaker notes on every slide.
- The submission archive script was run successfully and validated all 38
  expected files by extracting them to a temporary directory.
- These checks verify the current generated artifacts, not a clean-room
  reproduction of the complete pipeline.

## 8. How to verify "everything is correct" (fast)

```bash
Rscript R/99_demo_synthetic.R        # Sasi's original scaffold smoke test
Rscript R/98_smoke_models.R          # every model_fn on synthetic data
Rscript R/11_evaluate.R              # regenerate all accuracy/economic tables
git diff --check                     # verify whitespace
git status --short                   # review intended project changes
```
Cross-validations already done (results recorded in the review packets):
DM vs `forecast::dm.test`, ADF vs `tseries::adf.test`, Table 1 spot checks,
Neely signal match table, GR weight constraints, synthetic target-alignment
tests, and corrected all-horizon forecast counts. A complete clean-directory
rerun from the final ZIP remains unverified.

## 9. What each owner's agent must do

### Agent for Leon — R1, due Wed 28 Oct
Read `review/CHECKPOINT_R1_LEON.md`. Verify the 6 checklist items (you may
re-run `data/01_build_panel.R`, `02_table1.R`, `03_validate_signals.R`).
Answer decision #2 (expanded predictors yes/no — recommendation: no).
Report verdict.

### Agent for En Shao — R2, due Fri 30 Oct
Read `review/CHECKPOINT_R2_ENSHAO.md`. Verify the 8 checklist items
(`R/08_models.R`, `R/10_combine_forecasts.R`, harness diff in
`R/01_rolling_window.R`, forecast CSVs). Answer the 5 decisions. Report
verdict + any hyperparameter requests.

### Agent for Sasi — R3, due Wed 4 Nov + Canvas upload Mon 9 Nov
Read `review/CHECKPOINT_R3_SASI.md` and `SUBMISSION_CHECKLIST.md`. Verify
the 5 checklist items (rerun `R/11_evaluate.R`; DM/CW implementations).
Answer decision #1 (h>1 timing A vs B — both pre-computed in
`output/tables/table3_alt_h{3,12}.csv`). On Mon 9 Nov ensure the human
uploads `report/main.pdf` and `submission/EC4308_Project_Submission.zip`.

### Agent for Vienna — R4, due Sat 7 Nov
Read `review/CHECKPOINT_R4_VIENNA.md`. Review `report/main.pdf` (14 pages,
format compliance) and `deck/EC4308_Presentation.pptx` + `speaker_scripts.md`.
Supply the contribution-statement wording and any text edits. Coordinate the
Week-13 rehearsal.

## 10. How findings are reported

Agents report back to the coordinating agent (or directly in the group chat)
as: **`R<n> approved`** OR **`R<n> findings:`** followed by a bullet list of
concrete, actionable fixes with file paths. The coordinating agent applies
fixes, re-verifies (recompiles report, rebuilds zip), and pushes. Findings
must be actionable — not stylistic opinions without a suggested change.

## 11. Submission (Mon 9 Nov, Sasi/human)

Canvas: upload `report/main.pdf` (report slot) and
`submission/EC4308_Project_Submission.zip` (code+data slot — the zip
contains data, code, LaTeX source, deck generator, README; the PDF is
uploaded separately). See `SUBMISSION_CHECKLIST.md` for the 2-minute
pre-upload check. Then: Week-13 talk (all four speak, scripts in
`deck/speaker_scripts.md`), Reading-Week individual peer review.

## 12. Known pitfalls / tripwires

- `data/raw/*` and `data/processed/*` are gitignored; important artifacts
  are force-added (`git add -f`) — do not remove them from tracking.
- The submission zip intentionally excludes `report/main.pdf`.
- The report PDF's only non-reproducible bytes are its embedded
  CreationDate/ModDate timestamps.
- `R/09_run_models.R` and `R/11_evaluate.R` parse CLI args AFTER sourcing
  `R/00_config.R` (an earlier bug was fixed; keep it that way).
- `R/07_unitroot.R` reports significance bins vs MacKinnon asymptotic
  critical values (−4.04/−3.45/−3.15), BIC lag selection — matches
  `tseries::adf.test` within 0.2% at equal lags.
- The corrected full-spec run took about 146 minutes on Windows. Do not start
  a duplicate full run; use the targeted checks in Section 8 unless a
  substantive analysis change requires regeneration.
