# Canvas Submission Checklist — Mon 9 Nov 2026 (Sasi)

> Everything below is staged and frozen after Vienna's R4 sign-off (Sat 7 Nov).

## What to upload (two files)

| # | Canvas slot | File | Location on this Mac |
|---|---|---|---|
| 1 | Report (PDF) | **final report** — 12 pages, 11pt, 1.5 spacing | `report/main.pdf` |
| 2 | Code + data (zip) | **EC4308_Project_Submission.zip** — 38 files: all R scripts, raw data (GWZ workbook, volume chain, published-signal reference), LaTeX source, deck generator, README with run instructions | `submission/EC4308_Project_Submission.zip` |

## Before uploading (2-minute check)

- [ ] Open `report/main.pdf` — confirm the title page, 12 pages, tables/figures render.
- [ ] Unzip a COPY of the zip in a scratch folder and run the first two lines of
      its README (`data/01_build_panel.R`, `data/02_table1.R`) to confirm it
      runs from raw data. (A full from-scratch run was already verified on
      Mon 26 Oct — all outputs bit-identical.)

## Upload steps

1. Log in to Canvas → EC4308 → Project assignment.
2. Upload `report/main.pdf` to the report slot.
3. Upload `submission/EC4308_Project_Submission.zip` to the code/data slot.
4. Submit **before Mon 9 Nov deadline**. Do not leave it as a draft.

## After submission

- [ ] Tell the group chat it's in.
- [ ] Week 13 class: 10-minute presentation — all four speak. Scripts:
      `deck/speaker_scripts.md`; deck: `deck/EC4308_Presentation.pptx`.
- [ ] Reading Week (14–20 Nov): each member completes the individual peer
      review on Canvas (5% of grade).

## Emergency re-generation (if anything must change last-minute)

```bash
Rscript R/14_make_latex_tables.R
cd report && latexmk -pdf main.tex && cd ..
Rscript scripts/make_submission_zip.R
```
