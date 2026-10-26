# Review Checkpoint R4 — Report & Presentation (Reviewer: Vienna, by Sat 7 Nov)

**Stage:** Phase 4 deliverables drafted. You own the narrative, the document
standards, and the presentation, so this packet is yours to shape.

## Deliverables for review

| Item | Path | Status |
| :--- | :--- | :--- |
| Final report PDF (11 pages, 11pt, 1.5 spacing) | `report/main.pdf` | compiled clean, 0 errors, 0 overfull boxes |
| LaTeX source | `report/main.tex` | intro written last (per guidelines), abstract, data/methods/results/conclusion, appendix |
| Presentation deck (10 slides + speaker notes per slide) | `deck/EC4308_Presentation.pptx` | generated from the result CSVs (`deck/make_deck.py`) |
| Figures | `output/figures/figure1_wealth.png`, `figure2_r2oos.png`, `figure3_gr_weights.png` | in report + deck |
| Submission package script | `scripts/make_submission_zip.R` | produces `submission/EC4308_Project_Submission.zip` |

## Your checklist

- [ ] **Format compliance**: ≤15 pages (currently 11), 11pt, 1.5 spacing —
      verify in the PDF. Prof. Denis's rubric: intro written last, figures/
      tables self-contained with notes, methods outside class elaborated
      (rlasso theoretical penalty, GR constraints, CW test — all covered).
- [ ] **Narrative coherence**: the story is "replication succeeds → extension
      shows decay → honest negative statistical results → economic value
      persists as risk management". Read the abstract, intro, and conclusion;
      flag anything that oversells or undersells.
- [ ] **Numbers match the tables**: intro quotes −8.2%..−50.3% R²_OOS,
      drawdown −50%→−23%, MV gains 1.2–1.3% p.a. — cross-check against
      `output/tables/table{2,3,5}_h1.csv`.
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
