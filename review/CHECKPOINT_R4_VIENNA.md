# Review Checkpoint R4 — Report & Presentation (Reviewer: Vienna, by Sat 7 Nov)

> **Deferred after code corrections:** the report/deck have not been synchronized
> with the current simple-return contract, tuning, cash units and outputs.
> All readiness/results claims below are historical. See [README](../README.md).

> **Historical snapshot (2026-10-28).** The report/deck values and narrative
> below predate the 2026-11-01 predictor/target alignment correction and
> are superseded. Review the current `report/main.tex`, regenerated deck,
> and `review/AUDIT_REPORT.md`.

> **Current status (2026-11-01):** the corrected report is 14 pages and the
> rebuilt deck has 10 slides with speaker notes. The three focal volume rules
> have positive but insignificant 1966–2011 estimates; none of the six volume
> rules is significant at 5%. At h=1 and 10 bps net, mean–variance ΔU is
> −0.39% p.a. for LASSO and −2.07% for post-LASSO. Main ML forecast targets
> run from March 1971 (h=1), July 1971 (h=3), or January 1973 (h=12) through
> December 2025. Figure 4's source calculations are in
> `output/tables/table_subperiods_h1.csv`; the report table is generated from
> that CSV. These changes remain uncommitted.

**Stage:** Corrected report and presentation rebuilt; the original review
checklist below is a historical snapshot. You own the narrative, document
standards, and presentation, so review the corrected claims above and the
current artifacts.

## Deliverables for review

| Item | Path | Status |
| :--- | :--- | :--- |
| Final report PDF (14 pages, 11pt, 1.5 spacing) | `report/main.pdf` | rebuilt after the alignment correction and subperiod table; within the 15-page limit |
| LaTeX source | `report/main.tex` | intro written last (per guidelines), abstract, data/methods/results/conclusion, appendix |
| Presentation deck (10 slides + speaker notes per slide) | `deck/EC4308_Presentation.pptx` | generated from the result CSVs (`deck/make_deck.py`) |
| Figures | `output/figures/figure1_wealth.png`, `figure2_r2oos.png`, `figure3_gr_weights.png`, `figure4_subperiods.png` | includes descriptive subperiod figure; source values in `output/tables/table_subperiods_h1.csv` |
| Submission package script | `scripts/make_submission_zip.R` | produces `submission/EC4308_Project_Submission.zip` |

## Your checklist

- [ ] **Format compliance**: ≤15 pages (currently 14), 11pt, 1.5 spacing —
      verify in the PDF. Prof. Denis's rubric: intro written last, figures/
      tables self-contained with notes, methods outside class elaborated
      (rlasso theoretical penalty, GR constraints, CW test — all covered).
- [ ] **Narrative coherence**: the corrected replication does not find 5%
      significance for any volume rule; the extension is not interpreted as
      evidence of decay. The main ML results and economic results are stated
      separately and without causal claims.
- [ ] **Numbers match the tables**: no volume rule is significant at 5%;
      h=1 and 10 bps net ΔU is −0.39% p.a. for LASSO and −2.07% for
      post-LASSO. Cross-check `table5_neely_replication.csv`,
      `table3_h1.csv`, and `table_subperiods_h1.csv`.
- [ ] **Deck timing**: 10 slides ≈ 10 minutes. Speaker notes are assigned:
      Vienna (slides 1–2, 8–10), Leon (3), En Shao (4), Sasi (5–7). Rehearse
      and re-split if the group prefers a different order.
- [ ] **Academic tone**: no first-person hyperbole, all claims cited
      (GW 2008/2024, Neely 2014, GKX 2020, CT 2008, DM 1995, CW 2007, GR 1984).
- [ ] **Contribution statement**: the report has no contribution/author
      statement yet — tell me the wording you want on the title page.

## Decisions I made (flag any you disagree with)

1. Title page lists all four members without individual sections; the deck
   assigns speaking parts instead. Add a contributions footnote if you want.
2. Tables are auto-generated from CSVs (`R/14_make_latex_tables.R`) so any
   re-run keeps the report in sync — no hand-typed numbers.
3. Table 5 (replication) is in the body; the full 14-signal version lives in
   the appendix CSV path referenced from the table note.
4. The deck uses the generated figures directly.

## What I need back from you

- Verdict + any text edits you want (tell me in chat and I'll apply them to
  the LaTeX and recompile).
- Your preferred contribution statement / title-page wording.
- Rehearsal plan for Week 13 (I can generate per-speaker cue cards if useful).

*Submission happens Mon 9 Nov via Sasi on Canvas; the zip + PDF are frozen
after your sign-off Sat 7 Nov.*
