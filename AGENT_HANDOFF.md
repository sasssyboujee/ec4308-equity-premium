# AGENT HANDOFF — EC4308 Equity-Premium Project

> **For AI agents working on behalf of the EC4308 group members.**
> Read this document first. It is the single source of truth for the state of
> the project, the conventions you must not break, and exactly what your
> owner needs from you.
> **State captured:** Mon 27 Oct 2026, 23:47 SGT · **Deadline:** Mon 9 Nov 2026.

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

**All technical work is COMPLETE, VERIFIED, and PUSHED to GitHub
(`origin/main`, repo `sasssyboujee/ec4308-equity-premium`).**
Nothing requires new analysis unless a reviewer requests it. The only
remaining tasks are (a) four human reviews with due dates below, (b) folding
in any findings they produce, and (c) the Canvas upload.

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
report/main.tex         LaTeX source  →  report/main.pdf (12 pages)
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
Rscript R/09_run_models.R 6              # ALL models x h=1,3,12 (~35 min)
                                         # variants: ... 2 tech 1 | ... 2 macro 1
Rscript R/15_neely_bivariate.R           # bivariate robustness (fixed window)
Rscript R/16_neely_replication.R         # expanding-window replication/extension
Rscript R/11_evaluate.R                  # Tables 2-3 (accuracy, DM/CW, economic)
Rscript R/13_figures.R                   # Figures 1-4
Rscript R/14_make_latex_tables.R         # .tex table fragments
cd report && latexmk -pdf main.tex       # report/main.pdf
python3 deck/make_deck.py                # deck/EC4308_Presentation.pptx
Rscript scripts/make_submission_zip.R    # submission zip (code+data+LaTeX source)
```

Everything is deterministic (fixed seeds, `num.threads = 1` for ranger).
A from-scratch rerun of this chain from the zip in a clean directory was
performed: **all CSVs identical, figures byte-identical, PDF text-identical**
(only the embedded creation timestamp differs).

## 5. Key results (numbers to know)

- **Headline:** no model beats the prevailing mean at any horizon on the
  extended sample. OOS R²: rlasso −8.8% (h=1), −8.2% (h=3), −11.5% (h=12);
  worst is PLS/RF ≈ −40..−50%. PM RMSE ≈ 4.40.
- **Replication (credibility check):** expanding-window bivariate design of
  Neely et al. (2014) reproduces their positive findings on 1966–2011 —
  VOL(2,9) +0.36%, VOL(2,12) +0.66%, VOL(3,12) +0.76% (CW p ≤ 0.03) — and
  everything turns negative/insignificant on 2012–2025.
- **Subperiods (h=1, rlasso):** −10.5% (1971–99), **−1.2% (2000–11)**,
  −13.5% (2012–25) → predictability is crisis-episodic.
- **Economic value:** switching strategy halves max drawdown (−50.2% →
  −23.4%) at Sharpe 0.767 vs BH 0.777, but trails in terminal wealth
  ($67.7 vs $346.5). Mean-variance investor (γ=3, 10 bps): ΔU = +1.31%
  p.a. (post-LASSO), +1.22% (rlasso), +1.06% (GR), +0.73% (equal).
- **Variants:** technical-only and macro-only (Appendix A1) are also
  negative; macro-only rlasso is closest (−0.9%). Expanded GWZ-2024
  predictors (158 cols, all horizons pre-computed) never change the
  headline — see `data/processed/expanded_variant_summary.csv`.

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

## 7. Environment facts (this Mac)

- R 4.6.1 at `/opt/homebrew/bin/R`; all packages installed (hdm, glmnet,
  pls, ranger, forecast, sandwich, readxl, dplyr, tidyr, ggplot2, limSolve,
  openxlsx, lmtest, zoo, xts, tseries, readr, vroom, ...).
- **C++ fix (important):** `~/.R/Makevars` adds
  `CPPFLAGS += -I/Library/Developer/CommandLineTools/SDKs/MacOSX27.0.sdk/usr/include/c++/v1`
  (Homebrew R 4.6.1 cannot find libc++ headers otherwise).
- LaTeX: TeX Live 2026basic + `threeparttable`/`multirow` installed into
  `~/Library/texmf/` (tlmgr is root-only).
- Python (miniconda): python-pptx, yfinance, pypdf, openpyxl, Pillow.
- Git credentials in macOS keychain; push directly to `main` (team decision).

## 8. How to verify "everything is correct" (fast)

```bash
Rscript R/99_demo_synthetic.R        # Sasi's original scaffold smoke test
Rscript R/98_smoke_models.R          # every model_fn on synthetic data
Rscript R/11_evaluate.R 1            # must reproduce output/tables/table2_h1.csv
git status --short                   # must be empty
```
Cross-validations already done (results recorded in the review packets):
DM vs `forecast::dm.test`, ADF vs `tseries::adf.test`, Table 1 spot checks,
Neely signal match table, GR weight constraints, two independent full h=1
runs bit-identical, from-scratch zip rerun identical.

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
Read `review/CHECKPOINT_R4_VIENNA.md`. Review `report/main.pdf` (12 pages,
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
- Don't rerun the full 35-minute model pipeline unless a reviewer requests a
  change; verification uses the targeted commands in Section 8.
