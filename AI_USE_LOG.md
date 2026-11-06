# AI use log (EC4308 Group 6)

This log supports the AI-use declaration required by the project guidelines
(pp. 11–12, "Referencing AI Use"). It records the use of **GitHub Copilot
(agent mode, in VS Code)** during one working session from 6 to 7 November 2026.
It covers only that session. **Each group member must add any other AI use**
(other tools, earlier sessions, individual work) in the table at the end.

Chat transcript: `[link/export to be added by the group]`

## 1. What the AI did

| Area | What the AI did | Where to see it |
|---|---|---|
| Topic and deliverables check | Read the guidelines PDF, identified Topic 2 (predictive regressions in finance) and audited the Week 13 code, data and outputs. | (session only) |
| Code review and correction | Found and fixed the problems below. The group approved the main design choices. | Commit `9d863ec` |
| Regeneration | Re-ran the full pipeline from raw inputs: forecasts, tables, figures and the submission ZIP. | Commit `9d863ec` |
| Verification | Wrote verification scripts (forecast recomputation, end-point refits, table and figure checks, ZIP and checksum checks). These were not committed to the repo. | (session files) |
| Instructor-feedback check | Compared the proposal with Prof. Tkachenko's feedback and ran a one-off lag-1 vs 6-lag comparison. This comparison was not saved to the repo. | (session only) |
| Report text | Wrote the paragraphs on transaction-cost justification, DM-only testing and the 8 expanded predictors, and updated Table 5 to Diebold–Mariano p-values. | Commit `9d863ec` |
| Report rewrite | Rewrote `report/main.tex` at the group's explicit request: introduction and motivation, methods, results interpretation, discussion and conclusion. | Commit after `df55c5e` |
| Presentation | Wrote the slide build brief and the per-speaker script. | Commit `df55c5e` (`deck/SLIDE_SPEC.md`, `deck/speaker_scripts.md`) |

### Problems found and fixed in commit `9d863ec`

- The target was mislabelled as a log return. It is the simple excess return.
- Cash returns used the wrong units.
- Tuning used random cross-validation. It now uses chronological validation folds.
- The expanded predictor set included variables built from the full sample (look-ahead).
- Clark–West p-values were reported without support. They were removed.
- The ADF test had defects.
- Transaction costs were handled inconsistently.
- Forecast combinations could produce invalid weights.
- Missing inputs were not handled.
- The test assertions were weak.

## 2. Decisions taken by the group, not the AI

- The excess-return target is simple, not log, and each horizon forecasts a single month's return h months ahead. The group chose this after the AI explained the options.
- `fbm` and `ogap` are excluded, and tuning uses chronological validation folds.
- For the report, the group chose a full AI rewrite (option C) after being shown the guideline restriction on AI-written motivation, interpretation and discussion.

## 3. Note on the guidelines

The guidelines list "generate motivation, interpret results, or write
discussion" and "produce very large parts of your report" as unacceptable uses.
The report rewrite and the speaker script fall into those categories. The group
should consider rewriting those parts in its own words, or ask Prof. Tkachenko
whether the declared use is acceptable. The guidelines say "consult me before
proceeding".

## 4. Other AI use (to be completed by each member)

| Member | Tool | What it was used for | Transcript/link |
|---|---|---|---|
| Sasi | | | |
| Leon | | | |
| Vienna | | | |
| En Shao | | | |
