# Canvas Submission Checklist — Week 13

> Complete the final human review before upload; update this checklist if that review changes either deliverable.

> **Code correction notice:** the target is simple excess return; cash units,
> chronological tuning and the expanded set changed. Historical report, deck
> and review sign-offs are not synchronized. Follow [README](README.md) for the
> complete code-only chain and obtain instructor clarification/actual AI-use
> disclosure where needed. Never substitute AI-generated sign-offs for review.

## Verified code-only snapshot

Both regression suites pass; all 26 R files parse. A clean-input production run,
84 real-data endpoint refits and an independent 658-row macro-variant repeat
were checked. All 38 ZIP members match current source/input files, and all
36 generated outputs match the checked run. This does not certify report,
presentation or human AI-policy compliance.

Verified ZIP SHA-256:
`697a3f7bcc42dfd382ebe702e1cf629d476a2cb783a952b82a9ace27ee61c7ea`.
Any later code/data change invalidates this snapshot until rechecked.

## What to upload (two files)

| # | Canvas slot | File | Project path |
|---|---|---|---|
| 1 | Report (PDF) | **final report** — human revision pending; follow the guideline's page and format limits | `report/main.pdf` |
| 2 | Code + data (zip) | **EC4308_Project_Submission.zip** — 38 files: all R scripts, raw data (GWZ workbook, volume chain, published-signal reference), LaTeX source, deck generator, README with run instructions | `submission/EC4308_Project_Submission.zip` |

## Before uploading

- [ ] Revise and open `report/main.pdf` — confirm the guideline's format/page limit and that methods, tables and figures match the corrected analysis.
- [ ] Unzip a COPY of the zip in a scratch folder and run the complete
      code/data/results chain in its README, including the mandatory
      technical/macro variants and eligible expanded set. Record environment,
      source checksums and output comparisons. After any final alignment or results
      change, regenerate dependent outputs and confirm they match the report
      and presentation.

## Upload steps

1. Log in to Canvas → EC4308 → Project assignment.
2. Upload `report/main.pdf` to the report slot.
3. Upload `submission/EC4308_Project_Submission.zip` to the code/data slot.
4. Confirm the final deadline in Canvas and submit before it. The PDF's Monday-of-Week-13 date is provisional. Do not leave the upload as a draft.

## After submission

- [ ] Tell the group chat it's in.
- [ ] Week 13 class: 10-minute presentation — all four speak. Scripts:
      `deck/speaker_scripts.md`; deck: `deck/EC4308_Presentation.pptx`.
- [ ] Reading Week: each member completes the individual peer
      review on Canvas (5% of grade).

## Re-generation after changes

Follow the complete code/data/results chain in [README](README.md). Changing
models, alignment or units requires new forecasts, not just new tables.
Report and slide rendering remain deferred until their content is reviewed;
the legacy slide generator intentionally rejects the corrected table schema.
