# Review Checkpoint R1 — Data & Features (Reviewer: Leon, by Wed 28 Oct)

**Stage:** Phase 1 (data pipeline) is complete and committed to `main`.
**What you are reviewing:** the data layer only — panel construction, Table 1,
technical signal replication. Nothing below touches the models yet.

## What was built

| Artifact | Path | What it is |
| :--- | :--- | :--- |
| Panel | `data/processed/panel.csv` | 899 months (1951-02 → 2025-12), 100 columns: date, `eq_prem`, 84 macro-lag cols, 14 Neely signals |
| Codebook | `data/processed/codebook.csv` | column-by-column source/definition/alignment |
| Table 1 | `output/tables/table1.csv` | Panel A target, Panel B macro, Panel C technical signals, ADF tests |
| Signal validation | `output/tables/signal_validation.csv` | our signals vs Neely et al. (2014) published signals |
| Builders | `data/01_build_panel.R`, `data/02_table1.R`, `data/03_validate_signals.R`, `R/06_technical_indicators.R`, `R/07_unitroot.R` | reproducible scripts |

Reproduce everything with (from repo root):
```bash
Rscript data/00_fetch_technical.R   # verify raw inputs
Rscript data/01_build_panel.R       # rebuild panel
Rscript data/02_table1.R            # rebuild Table 1
Rscript data/03_validate_signals.R  # re-run published-signal check
```

## Your checklist (things to actually verify)

- [ ] **No lookahead**: `data/README.md` alignment convention — row t of X is
      observable at end of month t. Confirm `data/01_build_panel.R` follows it
      (macro lags: `x_lagk[t] = x[t-k]`; technicals use data through t only).
- [ ] **Lag spot-checks**: re-run `01_build_panel.R` — it asserts
      `x_lagk[t] == x[t-k]` on 5 random rows per macro column. Confirm it passes.
- [ ] **Sample period**: 1951-02 → 2025-12, 899 rows, zero NAs after start
      (asserted). The binding constraint is the VOL signals (volume from 1950-01
      + 12-month OBV burn-in). Sanity-check the dates in the panel.
- [ ] **Table 1 numbers**: spot-check 3–5 series (e.g., mean/SD of `eq_prem`,
      `d/p`, one MA signal) against your own quick computation.
- [ ] **Signal replication**: `signal_validation.csv` should show 12/14 signals
      at 100.000% and MOM_12 & VOL_2_9 at 99.864% (one mismatching month each,
      1968-03 and 1980-04). This is documented in the report as data revisions.
- [ ] **ADF implementation**: `R/07_unitroot.R` — ADF with intercept+trend, BIC
      lag selection, MacKinnon asymptotic critical values (−4.04/−3.45/−3.15).
      Read it and confirm the regression matches the ADF form you were taught.

## Decisions I made (flag any you disagree with — tell me in chat)

1. **Target** = `eq_prem` = 100·(ret − Rfree), i.e. log total return minus log
   risk-free in percent. Justification: correlates 0.9991 with Neely et al.'s
   published `eq_prem` on 1950–2011 (the workbook's `retx` is *ex-dividend*
   return, cor 0.9964 — not the premium). Verified in the R1 working notes.
2. **Macro set** = the classic Goyal–Welch (2008) 14 used by Neely et al. —
   NOT the 10 extra GWZ-2024 predictors (`skvw, tail, fbm, rdsp, avgcor, dtoy,
   dtoat, wtexas, lzrt, ogap`). They are implemented behind
   `CONFIG$USE_EXPANDED = FALSE`. Note: enabling them does **not** shorten the
   sample (technicals still bind), it only widens X. **Do you want the expanded
   predictors as a robustness check in the appendix? (yes/no)**
3. **Lag convention** = README convention: `x_lagk[t] = x[t-k]`, k = 1..6. So
   "lag 1" is the value from one month ago. (Neely et al. use only one lag,
   effectively x[t−1] in our indexing.)
4. **Volume splice** = paper's own volume (1950–2011) + Yahoo avg-daily volume
   (2012–2025); cor 0.9999 on overlap, signals invariant to constant volume
   rescaling. Alternative was published signals + computed extension; I chose
   the fully-computed chain for a single consistent methodology.
5. **Two micro-deviations vs published** (MOM_12 1968-03, VOL_2_9 1980-04)
   accepted and documented rather than patched.

## What I need back from you

- **Verdict** (sign-off or list of fixes) in the group chat by Wed 28 Oct.
- Answer to decision #2 (expanded predictors: yes/no).
- Any Table 1 formatting preferences before it goes into the LaTeX report.

*Next checkpoint (R2, En Shao) will be staged on Fri 30 Oct regardless; your
findings fold into the next build and are re-verified.*
