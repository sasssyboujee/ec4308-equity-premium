# Email submission checklist

The instructor's latest instruction is to email the project by **Wednesday of
reading week at 23:59**, CC'ing every group member. Confirm the exact calendar
date and applicable time zone. This supersedes the older provisional
Monday/Canvas submission instructions.

## Attachments

| Attachment | File | Contents |
|---|---|---|
| Report | [report/main.pdf](report/main.pdf) | PDF compiled from the current report source, tables and figures |
| Replication code and data | [submission/EC4308_Project_Submission.zip](submission/EC4308_Project_Submission.zip) | R scripts, five raw data inputs, report source and reproduction instructions |

## Technical verification

On 2026-11-16, the ZIP was extracted into a clean directory and the complete
documented code/data/results pipeline was run using only its supplied inputs.
All 22 verification steps passed, including both smoke tests, all forecast
horizons, technical/macro/expanded variants, economic evaluations, table and
figure generation, ZIP rebuilding and report compilation.

- All 27 R scripts parsed, including the packaging script.
- All 37 archive members matched the current source and five raw inputs.
  The raw inputs were unchanged by replication.
- All 38 generated result files matched the report inputs: 30 byte-for-byte and
  eight forecast CSVs within absolute/relative numerical tolerances of `1e-10`.
- The replicated PDF matched that snapshot's text and rendered pages.
- All 42 handwritten Neely sample/signal comparisons matched the source CSV.
  The headline results matched the output tables: ridge has the only two
  positive baseline out-of-sample R-squared values, and none of the 54
  Diebold-Mariano tests rejects at 10%.

On 2026-11-17, the economic-results table was split into two portrait tables and
the AI-use statement was shortened while retaining the recorded report-drafting
assistance. The table generator and PDF were rebuilt, then the ZIP was refreshed.
All 37 numerical, figure and other-table baselines remained byte-identical.
All 66 split economic-table rows and 462 result cells matched the CSVs at their
displayed precision. The updated PDF has **15 portrait pages**, no rotated pages
or text outside page bounds, no LaTeX layout warnings, and valid cross-references.
The original one-inch margins, 11pt body font and 1.5 body line spacing remained
at that stage; the economic tables use 10pt text with single-spaced rows.
Rebuilding from the refreshed ZIP with the previously verified numerical inputs
reproduced all five table fragments exactly and matched the updated PDF's text
and rendered pages. All 37 archive members matched the current source files.

The forecasting pipeline was not rerun for this presentation-only change.
The earlier clean replication establishes the unchanged numerical results;
the newer checks establish the updated table and PDF presentation.

On 2026-11-18, the report was restructured to the guideline order:
Introduction, Methodology, Data, Results and Conclusion. A roadmap paragraph,
a list of R packages, and source notes naming the generating script were added
to every figure and table. Floats are now placed at paragraph boundaries, and
margins were reduced from 1 inch to 2 cm to stay within 15 pages. The PDF has
15 A4 portrait pages. Body text is 11pt Latin Modern with a 16.4pt baseline
(1.5 times the font size, `\onehalfspacing`). It has no em dashes, unresolved
references, LaTeX layout warnings or text outside page bounds. Table rows
were not changed; the packaged code regenerated all five table fragments
exactly, and the rebuilt PDF matched the attachment's text and rendered pages.

Later on 2026-11-18, all text, including table cells, table notes, captions and
the abstract, was set to 11pt with 1.5 line spacing (16.4pt baselines). Margins
were reduced to 1.6 cm. Tables 1, 4 and 5 are longtables that may break only
between panels. Table 4 shows the identical prevailing-mean and buy-and-hold
switching rows as one row, and Table 5 omits the empty buy-and-hold rows. Every
cell of Tables 4 and 5 was rechecked against `output/tables/table3_h*.csv`. The
PDF has 15 A4 portrait pages. The only text below 11pt is math subscripts and
superscripts. It has no em dashes, unresolved references, overfull or underfull
boxes, or text outside page bounds. From a clean extract of the ZIP with the
current outputs copied in, the packaged code regenerated all five table
fragments exactly and the PDF matched the attachment's text and rendered pages.

On 2026-11-18, the README was reduced to reproduction instructions. The ZIP now
contains 27 files, with no smoke-test or demo scripts, deck-only scripts, or
extra markdown files. Its README is the only markdown file.

Verified environment: Windows, R 4.6.1; hdm 0.3.2, glmnet 5.2, pls 2.9.0,
ranger 0.18.0, limSolve 2.0.3, readxl 1.6.0 and ggplot2 4.0.3. The run emitted
a warning that glmnet was built under R 4.6.2 and a Fontconfig configuration
message during PDF compilation; neither prevented the checks above from passing.

| Attachment | Size (bytes) | SHA-256 |
|---|---:|---|
| Report PDF | 244056 | `555eb5fed5e172bf0dd5da7779455fe9994dc6713520abbd6bf96446e6a96983` |
| Replication ZIP | 1409230 | `6a27f21c9a770efce3996a96a4ff1f0a4ee3c70b2a18ffd706cf269ade5960a9` |

These results apply only to these attachments. Any later source, data or report
change requires the corresponding rebuild and checks. Technical verification
does not certify the group's substantive review or AI-policy compliance, and
the report is not ready to send until the human checks below are resolved.

## Final report checks requiring the group

- [ ] Read the actual attachment, not only the LaTeX source. Confirm the title,
      all four names, report date, complete pages and readable tables/figures.
- [ ] Check the 15-page limit, 11pt font and 1.5 line spacing throughout,
      including tables, and confirm that nothing is clipped.
- [ ] Confirm the data sources, transformations and timing: simple excess
      returns in percentage points; 899 months; 98 baseline and 146 expanded
      predictors; 240 eligible training pairs; horizons 1, 3 and 12; chronological
      tuning; expanding prevailing mean and past-error combination weights.
- [ ] Reconcile the abstract, results, conclusion, captions and handwritten
      Neely table with the replicated outputs. Do not claim significant forecast
      improvement or economic gains without the corresponding tests.
- [ ] Verify each bibliographic entry against the original source and confirm
      that the discussion and limitations reflect the group's own understanding.
- [ ] Replace the report's `[link/transcript to be added by group]` placeholder
      with genuine chat links or exported transcripts. Complete each member's
      entries in [AI_USE_LOG.md](AI_USE_LOG.md), including later sessions.
- [ ] Confirm that "All group members reviewed the code, results and text" is
      true before retaining it. Obtain instructor clarification for the uses
      identified in the log as outside the guidelines, or replace affected
      material with the group's own work. Disclosure alone does not establish
      approval.

## Email checks

- [ ] Use the instructor's correct email address and CC every group member.
- [ ] Attach the current PDF and ZIP and check the mailbox attachment limit.
      If a download link is needed, test its access permissions from another
      account and ensure it contains the final frozen files.
- [ ] Confirm the exact Wednesday deadline and send before 23:59.
- [ ] Open both attachments from the sent email and retain the sent message.

No email is sent automatically by the repository scripts.

## Regeneration after changes

Follow the complete code/data/results chain in [README.md](README.md). Changes
to models, alignment or units require new forecasts and all dependent outputs.
After any report source, table or figure change, compile the PDF again from
`report/` with `tectonic main.tex`. Rebuild the ZIP with
`Rscript scripts/make_submission_zip.R` and recheck its contents.
