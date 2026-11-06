# EC4308 Group 6 — SLIDE BUILD BRIEF (binding spec for the deck-building agent)

> **Status:** current as of repo commit `9d863ec` (branch `main`). Every number
> below was read from a CSV cell / `R/00_config.R` and is re-checkable with §9.
> Earlier versions of this file, `deck/make_deck.py`, `deck/EC4308_Presentation.pptx`,
> `report/main.tex|pdf`, README result text and `review/*.md` contain **stale,
> wrong numbers** — do not copy anything numeric from them.

---

## 0. Your role, inputs, job

| Item | Value |
|---|---|
| **Role** | You are the deck-building agent. You build the slides exactly as specified here; you do not re-analyse data or invent content. |
| **Inputs** | (1) this file; (2) GitHub repo `sasssyboujee/ec4308-equity-premium`, branch `main` (local clone = repo root). Figures in `output/figures/`, tables in `output/tables/` and `data/processed/`. |
| **Output file** | `deck/Group6_EC4308.pptx` (file name is mandatory: group number in name). Do **not** overwrite or edit any other repo file. |
| **Format** | 16:9 widescreen, 13.333 in × 7.5 in. Static: **no animations, no transitions, no embedded video/audio, no hyperlinks needed.** |
| **Slide count** | 16 slides total: main slides 1–10 (presented, timed), slide 11 "Thank you / Questions" (shown during Q&A, not timed, no slide number in the timing plan), then backup slides B1–B5 (= physical slides 12–16, not presented; used only to answer questions). |
| **Speaker notes** | Every slide gets a speaker-notes field containing only a pointer, e.g. `Script: deck/speaker_scripts.md → "### Slide 6 — Statistical accuracy" (Sasi, 1:15).` Do **not** paste script text into notes. Backup notes: `Backup for Q&A — not presented. Source: <file>.` |
| **Tooling** | Use `python-pptx` (installed, v1.0.2) or equivalent. Build from a blank 16:9 presentation; do not reuse the old `deck/EC4308_Presentation.pptx`. |
| **Numbers** | Copy displayed values **verbatim** from §5 slide specs (they equal the "Shown as" column of §8). Do **not** recompute or re-round from raw CSVs (R's rounding was used; e.g. −0.975 → −0.98). Render negative numbers with a typographic minus "−" (U+2212) or ASCII "-" — both pass §9. |
| **Done when** | All checks in §9.1–§9.3 pass and every box in §10 is ticked. |

---

## 1. Professor's presentation rules → design constraints

Source: Prof. Denis Tkachenko's email (via the binding outline). These are **hard constraints**.

| # | Rule | How it constrains the slides |
|---|---|---|
| R1 | ~1 minute per slide, 10 min total | Exactly 10 main slides, timings in §4. |
| R2 | Do **not** read slides | Low text: **max 5 bullets and ~35 words of body text per slide** (title, key-message line, table cells, figure captions excluded). No full sentences where a phrase works. |
| R3 | One key message per slide | Each slide has exactly one **key-message line** directly under the title (14–16 pt, grey, italic not required) — text given verbatim in §5. |
| R4 | Do **not** re-teach lecture methods (LASSO, Ridge, PCR, PLS, RF, DM, rolling windows) | Slide 5 lists models in one line each; no formulas, no derivations. |
| R5 | ~1 min intuition only for methods not in class (rlasso plug-in penalty, constrained Granger–Ramanathan) | Two intuition callouts on slide 5 only. |
| R6 | Minimal literature | Only two citations in the whole deck: Goyal, Welch & Zafirov (2024) data; Neely et al. (2014) technical signals. No lit-review slide. |
| R7 | Focus on what WE did and what results mean | Every result slide states the interpretation in the key-message line. |
| R8 | Audience = peers | Plain words; model names as in our tables (rlasso, post-LASSO, ridge, elastic net, PCR, PLS, random forest, equal-weight, GR). |
| R9 | Rounded numbers | R²_OOS and ΔU: 2 decimals, in %; p-values: 2 decimals; wealth: whole dollars; Sharpe: 2 decimals; max drawdown: whole %. Counts as integers. |

**Honesty rules (binding, from outline):** no model beats the prevailing mean (PM) significantly; never write "outperforms"/"beats" for a forecast without "not statistically significant" nearby; 9 models × 3 horizons ⇒ never crown a single winner; economic gains have **no significance test** and must be labelled so.

### 1.1 Design system

| Token | Value | Use |
|---|---|---|
| Navy | `#1F365C` (31,54,92) | titles, table headers, big numbers |
| Accent orange | `#C0502D` (192,80,45) | the one headline number per slide; "no significance test" tags |
| Grey | `#606060` | key-message line, captions, footers |
| Panel grey | `#F2F2F2` | callout / stat-card backgrounds |
| Background | white | all slides |

Font Calibri (fallback Arial). Title 28–30 pt bold navy, top-left at x = 0.6 in, y = 0.35 in, width 12.1 in. Key-message line 16 pt grey at y = 1.15 in. Body 16–18 pt. Table text 12–14 pt (main) / 10–11 pt (backup). Captions 11 pt grey. Footer on every slide (9 pt grey, bottom-left): `EC4308 · Group 6`; slide number bottom-right (main slides "1"…"10", Thank-you slide no number, backups "B1"…"B5"). Content zone y = 1.6–7.0 in. No logos, clip-art, or decorative images.

---

## 2. Repo asset table (every file the deck uses)

| Path (repo-relative) | What it contains | Used on |
|---|---|---|
| `output/figures/figure1_wealth.png` | Binary switching strategy, cumulative wealth per $1, net of 10 bps, three facet panels **in the order h = 1, h = 12, h = 3** (left→right; ggplot alphabetical facet order). Lines: buy-and-hold, Prevailing Mean, and "Switching (best model)" where best = highest full-OOS R²_OOS **chosen retrospectively**: ridge at h = 1 and h = 3, equal_comb at h = 12. The buy-and-hold line is hidden under the Prevailing Mean line (identical: PM forecast is always > 0 → always invested). 3000×1260 px (10 × 4.2 in @300 dpi). | 8 |
| `output/figures/figure2_r2oos.png` | Bar chart of R²_OOS (%) vs PM for all 9 models (rlasso, postlasso, ridge, enet, pcr, pls, rf, equal_comb, gr_comb), three stacked rows h = 1, 3, 12, common y-axis (≈ −15 to 0). RF bars dominate. 2100×1800 px (7 × 6 in). | 6 |
| `output/figures/figure3_gr_weights.png` | Stacked-area plot of constrained Granger–Ramanathan weights over time at h = 1 for the 7 base models (weights ≥ 0, sum to 1, from past OOS errors). Visually: PCR / elastic net / ridge carry the weight; ridge dominates the late sample; rf, pls, postlasso ≈ 0. 2400×1350 px (8 × 4.5 in). | B1 |
| `output/figures/figure4_subperiods.png` | Bar chart titled "LASSO out-of-sample R² by subperiod (h = 1)" — the model is **rlasso**. Three bars 1971-1999, 2000-2011, 2012-2025 with labels −0.6, −1.2, −1.9 (the −1.9 label is partly clipped at the bottom; the slide table supplies exact values). 1800×1080 px (6 × 3.6 in). | B3 |
| `output/tables/table1.csv` | Descriptive stats; row `Panel=A: target (full sample)` N = 899; row `A: target (OOS)` N = 658. | 3, 4 |
| `output/tables/signal_validation.csv` | Our rebuilt 14 technical signals vs Neely et al. published signals: `months_compared`, `mismatches` per signal (2 mismatches in total). | 3 |
| `output/tables/table2_h1.csv`, `table2_h3.csv`, `table2_h12.csv` | Statistical accuracy per model: `R2_OOS_pct`, RMSE, MAE, hit rate, one-sided DM stats/p-values (`DM_RMSE_p` = squared error, `DM_MAE_p` = absolute error). | 5, 6, 7, 10, B5 |
| `output/tables/table3_h1.csv`, `table3_h3.csv`, `table3_h12.csv` | Economic value per model: switching wealth at 5/10/20 bps (`sw_wealth_*bps`), buy-and-hold wealth (`sw_wealth_bh`), Sharpe and max drawdown at 10 bps, mean-variance ΔU at 5/10/20 bps (`mv_deltaU_*_pct`, % p.a.); rows `Buy-and-Hold`, `Prevailing Mean`. | 8, 9, 10, B5 |
| `output/tables/table3_alt_h3.csv`, `table3_alt_h12.csv` | Alternative timing robustness; used **only** for OOS month counts (`months` = 654 / 636). Do not show its wealth numbers. | 4 |
| `output/tables/table5_neely_replication.csv` | Neely et al. design: expanding-window bivariate regression per signal, h = 1; samples `Neely sample 1966-2011` (n = 552), `Extension 2012-2025` (n = 168), `Pooled 1966-2025`. | 9 |
| `output/tables/table_subperiods_h1.csv` | rlasso R²_OOS (h = 1) by block with n, first/last target dates (first OOS target 1971-03-01, last 2025-12-01). | 4, B3 |
| `output/tables/tableA1_tex.tex` | LaTeX table of h = 1 R²_OOS by predictor set (full / technical-only / macro-only). **No CSV exists**; values are recomputed in §9 from the three forecast files below. | B2 |
| `data/processed/forecasts_h1.csv`, `forecasts_h1_tech.csv`, `forecasts_h1_macro.csv`, `panel.csv` | Forecast files (columns `target_index`, model columns, `pm`) and panel (`eq_prem`) — used only by the §9 check to recompute B2 values. | B2 (check only) |
| `data/processed/expanded_variant_summary.csv` | R²_OOS for the expanded 146-column predictor set, 9 models × h = 1, 3, 12 (no DM tests in this file). | B4 |
| `data/processed/codebook.csv`, `codebook_expanded.csv` | Column dictionaries: 1 target + 84 macro + 14 technical (= 98 predictors); expanded: 132 macro + 14 technical (= 146). | 3, B4 |
| `R/00_config.R` | `W_ROLLING = 240`, `HORIZONS = 1,3,12`, `FEE_BPS = 10`, `FEE_SENSITIVITY = 5,20`, `GAMMA = 3`, `W_MIN = 0`, `W_MAX = 1.5`, `MAX_LAG = 6`, `SAMPLE_START = 1951-02-01`, `SAMPLE_END = 2025-12-01`, 14 `MACRO_CLASSIC`, 8 `MACRO_EXPANDED`, 14 `TECHNICAL_NAMES` (6 MA, 2 MOM, 6 VOL). | 3, 4, 8, 9 |
| `deck/speaker_scripts.md` | Spoken script; headings `### Slide N — …`. Pointer target for speaker notes only. | notes |

Not used on slides: `table4_h1.csv`, `table3_alt_*` wealth columns, `forecasts_h1_neely_biv.csv`, any `*.tex` other than tableA1.

---

## 3. Deck at a glance

| Phys. # | Label | Title (exact) | Speaker | Time | Visual |
|---|---|---|---|---|---|
| 1 | 1 | Can Machine Learning Beat the Historical Average? | Vienna | 0:30 | title only |
| 2 | 2 | Motivation & Research Questions | Vienna | 1:00 | 3 RQ cards |
| 3 | 3 | Data & Predictors | Leon | 1:00 | 3 stat tiles + bullets |
| 4 | 4 | Forecasting Design | En Shao | 1:00 | timing diagram (native shapes) |
| 5 | 5 | Models & Combinations | En Shao | 1:00 | model table + 2 intuition callouts |
| 6 | 6 | Statistical Accuracy | Sasi | 1:15 | figure2 + 3 stat cards |
| 7 | 7 | Is Anything Significant? | Sasi | 0:45 | 3-row p-value table |
| 8 | 8 | Economic Value: Switching Strategy | Sasi | 1:15 | figure1 + 3-row table |
| 9 | 9 | Technical Signals & the Mean-Variance Investor | Leon | 1:00 | 2-row table + ΔU panel |
| 10 | 10 | Conclusion & Takeaways | Vienna | 1:00 | 3 RQ answers + limitations |
| 11 | — | Thank You — Questions? | all | (Q&A, untimed) | text only |
| 12 | B1 | Backup B1: Granger–Ramanathan Weights (h = 1) | — | — | figure3 |
| 13 | B2 | Backup B2: Predictor-Set Variants (h = 1) | — | — | 9×3 table |
| 14 | B3 | Backup B3: rlasso R²_OOS by Subperiod (h = 1) | — | — | figure4 + 3-row table |
| 15 | B4 | Backup B4: Expanded Predictor Set (146 columns) | — | — | 9×3 table |
| 16 | B5 | Backup B5: Full Results at h = 3 and h = 12 | — | — | two 10-row tables |

---

## 4. Timing plan

| Slides | Speaker | Time | Cumulative |
|---|---|---|---|
| 1–2 | Vienna | 0:30 + 1:00 | 1:30 |
| 3 | Leon | 1:00 | 2:30 |
| 4–5 | En Shao | 1:00 + 1:00 | 4:30 |
| 6–8 | Sasi | 1:15 + 0:45 + 1:15 | 7:45 |
| 9 | Leon | 1:00 | 8:45 |
| 10 | Vienna | 1:00 | **9:45** |
| 11 (Thank you) + B1–B5 | all | Q&A 1–2 min, not counted | — |

---

## 5. Slide-by-slide specification

Conventions: "Key message" = the grey line under the title (verbatim). Bullet text is verbatim (you may only change "-" to "−" in numbers). Number IDs in brackets (e.g. [C005]) refer to §8 — **do not print the IDs on slides**.

### Slide 1 — Title · Vienna · 0:30

| Element | Spec |
|---|---|
| Title (exact, 36–40 pt bold navy, centred) | `Can Machine Learning Beat the Historical Average?` |
| Subtitle (exact, 24 pt navy) | `Forecasting the US Equity Premium` |
| Key message | none on this slide (the subtitle serves) |
| Line 3 (18 pt grey) | `EC4308 Machine Learning and Economic Forecasting · Group 6` |
| Line 4 (16 pt dark grey) | `Kannan Sasinthiran · Kollaart Leon Samuel · Vienna Fiorella Anong · Yeap En Shao` |
| Figure/table | none |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 1 — Title" (Vienna, 0:30).` |
| Do not | add a date, course logo, results, or the professor's name in large type; no slide-number footer on this slide. |

### Slide 2 — Motivation & Research Questions · Vienna · 1:00

| Element | Spec |
|---|---|
| Title | `Motivation & Research Questions` |
| Key message | `Many predictors look useful in-sample but lose to the historical average in real time.` |
| Bullets (top, 2) | • `Equity premium = S&P 500 return minus T-bill rate` <br> • `A usable forecast tells you when to hold stocks vs. cash` |
| 3 RQ cards (row of 3 panel-grey rounded rectangles, each ~3.8 in wide, y ≈ 3.6 in) | Card 1 header `RQ1 · Accuracy` body `Does any ML model beat the historical mean out-of-sample?` <br> Card 2 header `RQ2 · Technical signals` body `Do trading-rule signals add value beyond macro data?` <br> Card 3 header `RQ3 · Economics` body `Could an investor gain from the forecasts?` |
| Figure/table | none |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 2 — Motivation & research questions" (Vienna, 1:00).` |
| Do not | cite papers; no numbers; no "we find…" spoilers. |

### Slide 3 — Data & Predictors · Leon · 1:00

| Element | Spec |
|---|---|
| Title | `Data & Predictors` |
| Key message | `899 monthly observations and 98 predictors, all known at forecast time.` [C001, D001] |
| 3 stat tiles (top row, panel grey, big number 40 pt navy, label 13 pt grey) | Tile 1: `899` / `months · 1951:02–2025:12` [C001, D010, D011] <br> Tile 2: `98` / `predictors · 84 macro + 14 technical` [D001, D002, D003] <br> Tile 3 (number in orange): `99.98%` / `rebuilt signals match Neely et al. (2014)` [D007] |
| Bullets (below tiles, 4) | • `Target: monthly S&P 500 total return minus T-bill, simple % (not log)` <br> • `Macro: 14 Goyal–Welch–Zafirov (2024) variables × lags 1–6 = 84` [D004, D005, D002] <br> • `Technical: 14 Neely et al. rules — 6 MA, 2 MOM, 6 VOL` [D003, D006] <br> • `Robustness: +8 newer predictors → 146 columns (backup B4)` [D008, D009] |
| Figure/table | none |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 3 — Data & predictors" (Leon, 1:00).` |
| Do not | write "log premium"/"log excess return"; do not show mean/SD or Table 1; do not list all 14 variable names. |

### Slide 4 — Forecasting Design · En Shao · 1:00

| Element | Spec |
|---|---|
| Title | `Forecasting Design` |
| Key message | `Every forecast uses only information available at the forecast date.` |
| Timing diagram (left 7.6 in, native shapes, y 1.7–4.6 in) | Horizontal arrow = time. Row 1: navy rectangle labelled `Training window: last 240 months` ending at a tick `origin t`; then a gap and an orange circle labelled `target t + h` with brace label `h = 1, 3, 12 months ahead (one month's premium, not cumulative)`. Row 2 (same shapes, 40 % transparency, shifted right by one step) labelled `roll forward 1 month, refit`. [D012, D013] |
| Under diagram (13 pt grey) | `Out-of-sample: h = 1: 658 months (1971:03–2025:12) · h = 3: 654 · h = 12: 636` [C002, D014, D011, C003, C004] |
| Bullets (right column, 3) | • `Benchmark: prevailing mean (expanding historical average)` <br> • `Metric: out-of-sample R² vs prevailing mean` <br> • `Test: one-sided Diebold–Mariano, squared & absolute errors` |
| Callout box (bottom-right, panel grey, header `Changed after proposal feedback`, 12 pt) | `OLS → prevailing mean · Clark–West → DM · one lag → up to 6 lags · + switching strategy · + GR combination` [D005] |
| Figure/table | none (diagram is drawn) |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 4 — Forecasting design" (En Shao, 1:00).` |
| Do not | explain how rolling windows or DM work (taught in class); do not write "expanding window" for the ML models (only the PM benchmark is expanding); do not mention Clark–West results. |

### Slide 5 — Models & Combinations · En Shao · 1:00

| Element | Spec |
|---|---|
| Title | `Models & Combinations` |
| Key message | `Seven standard learners plus two combinations; only rlasso and constrained GR are new to class.` [D015] |
| Left: 2-column table (no header shading beyond navy header row; 13 pt) | Header: `Model` · `In one line` <br> `rlasso` · `LASSO with plug-in penalty, no cross-validation` <br> `post-LASSO` · `OLS on the rlasso-selected predictors` <br> `Ridge / Elastic Net` · `shrinkage, tuned on forward validation blocks` <br> `PCR / PLS` · `factor reduction, tuned the same way` <br> `Random Forest` · `nonlinear trees` <br> `Equal weight` · `average of the 7 forecasts` <br> `Constrained GR` · `weights ≥ 0, sum to 1, past errors only` |
| Right: 2 intuition callouts (panel grey, orange left border) | Callout 1 header `rlasso — new` body `Penalty set from theory, just above the noise level: noise predictors rarely enter, no CV needed.` <br> Callout 2 header `Constrained Granger–Ramanathan — new` body `Choose the mix of model forecasts with the smallest past out-of-sample errors.` |
| Figure/table | none |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 5 — Models & combinations" (En Shao, 1:00).` |
| Do not | show formulas/objective functions; re-teach ridge, PCR, PLS, RF; give the GR warm-up length or the number of validation blocks (not in a CSV/config). |

### Slide 6 — Statistical Accuracy · Sasi · 1:15

| Element | Spec |
|---|---|
| Title | `Statistical Accuracy` |
| Key message | `Only 2 of 27 model–horizon pairs beat the historical mean — both ridge, both tiny.` [D016] |
| Figure | `output/figures/figure2_r2oos.png`, left, x = 0.5 in, y = 1.6 in, height 5.3 in (width ≈ 6.18 in, keep aspect 7:6). Caption (11 pt grey, below): `R²_OOS (%) vs prevailing mean, 9 models × h = 1, 3, 12. Source: output/figures/figure2_r2oos.png` |
| Right: 3 stat cards (stacked, x ≈ 7.2 in, width 5.5 in; big number 32 pt) | Card 1: `+0.12%` / `ridge, h = 1` [C005] <br> Card 2: `+0.30%` / `ridge, h = 3` [C006] <br> Card 3: `−0.48%` / `best at h = 12 (equal-weight combination)` [C007] |
| One line under cards (14 pt) | `Random forest worst: −15.53% / −12.33% / −10.47%` [C008, C009, C010] |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 6 — Statistical accuracy" (Sasi, 1:15).` |
| Do not | call ridge "the best model" or "winner"; say "outperforms"; mention significance here (slide 7). |

### Slide 7 — Is Anything Significant? · Sasi · 0:45

| Element | Spec |
|---|---|
| Title | `Is Anything Significant?` |
| Key message | `No: none of 54 Diebold–Mariano tests rejects at 10%; the smallest p-value is 0.23.` [D018, D019, C012] |
| Table (centred, width 10 in, 16 pt, header navy) | see below |
| Footer line (12 pt grey) | `One-sided DM test, H₁: model beats prevailing mean; Newey–West lag h − 1. The models shown also have the smallest p-values at each horizon.` [D017, D020] |
| Figure | none |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 7 — Is anything significant?" (Sasi, 0:45).` |
| Do not | show t-statistics; add stars; mention Clark–West. |

Slide 7 table (values verbatim):

| Horizon | Highest R²_OOS model | R²_OOS | DM p (squared error) | DM p (absolute error) |
|---|---|---|---|---|
| h = 1 | ridge | +0.12% [C005] | 0.45 [C011] | 0.23 [C012] |
| h = 3 | ridge | +0.30% [C006] | 0.34 [C013] | 0.30 [C014] |
| h = 12 | equal-weight comb. | −0.48% [C007] | 0.81 [C015] | 0.85 [C016] |

Sources: R²_OOS → `output/tables/table2_h{1,3,12}.csv` col `R2_OOS_pct`; p-values → same files, cols `DM_RMSE_p` / `DM_MAE_p`; rows `ridge`, `ridge`, `equal_comb`.

### Slide 8 — Economic Value: Switching Strategy · Sasi · 1:15

| Element | Spec |
|---|---|
| Title | `Economic Value: Switching Strategy` |
| Key message | `At h = 1 some strategies end above buy-and-hold, but there is no significance test and gains fade at longer horizons.` |
| Figure | `output/figures/figure1_wealth.png`, top-left, x = 0.4 in, y = 1.6 in, width 8.3 in (height ≈ 3.49 in). Caption (10 pt grey): `Wealth per $1, net of 10 bps per switch. Panels: h = 1, h = 12, h = 3. Model shown = highest R²_OOS, chosen after the fact. Buy-and-hold line lies under the prevailing-mean line.` [D013, D021, D017] |
| Rule line (under caption, 12 pt) | `Rule: hold the S&P 500 if forecast > 0, else T-bills; costs charged on every switch incl. first entry.` |
| Right: table (x ≈ 8.9 in, width 4.1 in, 12 pt) | see below |
| Bullets (right, under table, 3, 13 pt) | • `Ridge at 5 / 10 / 20 bps: $508 / $499 / $482` [D021, C026, C017, C027] <br> • `4 of 9 models end below buy-and-hold at h = 1 (random forest $93)` [D022, C028] <br> • `h = 12: highest-R² model $193 vs buy-and-hold $265` [C029, C030] |
| Orange tag (bottom-right) | `No significance test on wealth — suggestive only` |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 8 — Economic value: switching strategy" (Sasi, 1:15).` |
| Do not | call ridge's strategy "the winner"; imply the wealth difference is significant; show `table3_alt_*` numbers; describe the panels as "h = 1, 3, 12 left to right". |

Slide 8 table (h = 1, 10 bps; values verbatim):

| Strategy | Wealth per $1 | Sharpe | Max drawdown |
|---|---|---|---|
| Ridge | $499 [C017] | 0.57 [C018] | −44% [C019] |
| GR combination | $421 [C020] | 0.55 [C021] | −44% [C022] |
| Buy-and-hold (= PM) | $342 [C023] | 0.49 [C024] | −50% [C025] |

Source: `output/tables/table3_h1.csv`, rows `ridge`, `gr_comb`, `Buy-and-Hold`; cols `sw_wealth_10bps`, `sw_sharpe_10bps` (annualised), `sw_maxdd_10bps` (×100). "(= PM)" justified by D023.

### Slide 9 — Technical Signals & the Mean-Variance Investor · Leon · 1:00

| Element | Spec |
|---|---|
| Title | `Technical Signals & the Mean-Variance Investor` |
| Key message | `The signals' small edge up to 2011 is gone in 2012–2025; utility gains at h = 1 do not survive h = 12.` |
| Left (width 7.4 in): heading `Neely et al. (2014) design, replicated and extended (h = 1)` 14 pt + table below | see table |
| Left caption (11 pt grey) | `Each of 14 signals alone, expanding-window regression vs prevailing mean; one-sided DM on squared errors. Source: output/tables/table5_neely_replication.csv` [D003] |
| Right (x ≈ 8.2 in, width 4.6 in): heading `Mean-variance investor (γ = 3, weight 0–1.5, 10 bps)` [D024, D021] 14 pt, then 4 bullets | • `h = 1: ΔU vs PM = +1.92% p.a. (ridge), +1.18% (GR)` [C037, C038] <br> • `h = 1: 6 of 9 models gain utility` [D026] <br> • `h = 12: 8 of 9 models lose utility` [D027] <br> • `No significance test on ΔU` (orange) |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 9 — Technical signals: replication + extension, and mean-variance" (Leon, 1:00).` |
| Do not | claim we "replicated Neely's significance" (none of our 1966–2011 p-values < 0.10); compare to Neely's published numbers (not in our CSVs); call ΔU "significant". |

Slide 9 table (values verbatim):

| Sample | Months | Signals with R²_OOS > 0 | R²_OOS range | Smallest DM p |
|---|---|---|---|---|
| 1966–2011 (Neely sample) | 552 [C031] | 10 of 14 [D025] | up to +0.59% [C032] | 0.20 [C033] |
| 2012–2025 (extension) | 168 [C034] | 0 of 14 [D025] | −2.54% to −0.27% [C039, C035] | 0.60 [C036] |

Source: `output/tables/table5_neely_replication.csv`; R²_OOS max/min and smallest p computed over the 14 rows of each `sample` (rows named in §8). ΔU source: `output/tables/table3_h1.csv` / `table3_h12.csv` col `mv_deltaU_10bps_pct`.

### Slide 10 — Conclusion & Takeaways · Vienna · 1:00

| Element | Spec |
|---|---|
| Title | `Conclusion & Takeaways` |
| Key message | `The historical average remains very hard to beat — and saying so honestly is our result.` |
| 3 answer rows (icon-free; bold label left, text right; 16 pt) | `RQ1 Accuracy` — `No significant beat at any horizon; ridge only +0.12% / +0.30% (smallest p = 0.23)` [C005, C006, C012] <br> `RQ2 Signals` — `Small edge up to 2011, gone in 2012–2025` <br> `RQ3 Economics` — `Some h = 1 gains, untested; they fade by h = 12` |
| Limitations box (panel grey, 13 pt) | `Limitations: one market · one window length · model shown chosen after the fact · 9 models × 3 horizons → some "winners" by luck` [D016] |
| Notes | `Script: deck/speaker_scripts.md → "### Slide 10 — Conclusion & takeaways" (Vienna, 1:00).` |
| Do not | write "ML outperforms", "ridge is best", or "profitable strategy"; add future-work lists. |

### Slide 11 — Thank You — Questions? · all · untimed

| Element | Spec |
|---|---|
| Title (centred, 40 pt navy) | `Thank You — Questions?` |
| Line 2 (16 pt grey) | `Code, data and results: github.com/sasssyboujee/ec4308-equity-premium` |
| Line 3 (12 pt grey) | `Backup slides B1–B5 follow` |
| Slide number | none |
| Notes | `Q&A: see deck/speaker_scripts.md → "## Q&A prep".` |
| Do not | add any numbers or summary of results. |

### Backup B1 — Granger–Ramanathan Weights (h = 1)

| Element | Spec |
|---|---|
| Title | `Backup B1: Granger–Ramanathan Weights (h = 1)` |
| Key message | `Weight moves between PCR, elastic net and ridge; ridge dominates the recent sample; RF, PLS and post-LASSO get almost none.` |
| Figure | `output/figures/figure3_gr_weights.png`, centred, width 10.5 in (height ≈ 5.9 in), y = 1.5 in. |
| Caption | `Constrained GR weights (≥ 0, sum to 1) from past OOS errors only; equal weights until enough OOS history. Source: output/figures/figure3_gr_weights.png` |
| Notes | `Backup for Q&A — not presented. Source: output/figures/figure3_gr_weights.png (R/13_figures.R).` |
| Do not | state numeric weights or the warm-up length (not in a CSV). |

### Backup B2 — Predictor-Set Variants (h = 1)

| Element | Spec |
|---|---|
| Title | `Backup B2: Predictor-Set Variants (h = 1)` |
| Key message | `No predictor subset rescues accuracy: only ridge (full set, macro-only) is above zero.` [D028] |
| Table | 9 rows × 4 columns, centred, width 8 in, 12 pt; values verbatim below (unit: R²_OOS in %). |
| Caption | `R²_OOS (%) vs prevailing mean, h = 1. Source: output/tables/tableA1_tex.tex (from data/processed/forecasts_h1*.csv).` |
| Notes | `Backup for Q&A — not presented. Source: output/tables/tableA1_tex.tex (R/14_make_latex_tables.R).` |

| Model | Full (98) | Technical only (14) | Macro only (84) |
|---|---|---|---|
| rlasso | -1.06 | -0.84 | -1.03 |
| postlasso | -2.83 | -0.53 | -2.80 |
| ridge | +0.12 | -1.06 | +0.17 |
| enet | -1.00 | -1.13 | -1.17 |
| pcr | -1.29 | -1.63 | -2.15 |
| pls | -1.24 | -1.67 | -1.25 |
| rf | -15.53 | -5.42 | -15.13 |
| equal_comb | -1.09 | -1.10 | -1.13 |
| gr_comb | -0.54 | -1.56 | -0.49 |

Each cell = row `R001`–`R027` in §8.2 (column order Full → R001–R009, Technical → R010–R018, Macro → R019–R027, rows in the model order shown).

### Backup B3 — rlasso R²_OOS by Subperiod (h = 1)

| Element | Spec |
|---|---|
| Title | `Backup B3: rlasso R²_OOS by Subperiod (h = 1)` |
| Key message | `rlasso trails the historical mean in every subperiod, most in 2012–2025.` |
| Figure | `output/figures/figure4_subperiods.png`, left, x = 0.5 in, y = 1.6 in, width 7.0 in (height ≈ 4.2 in). Caption: `Figure title says "LASSO" = rlasso. Source: output/figures/figure4_subperiods.png` |
| Table (right, x ≈ 8.0 in, width 4.6 in, 14 pt) | see below |
| Notes | `Backup for Q&A — not presented. Source: output/tables/table_subperiods_h1.csv.` |

| Block | Months | rlasso R²_OOS |
|---|---|---|
| 1971–1999 | 346 [C040] | −0.63% [C041] |
| 2000–2011 | 144 [C042] | −1.20% [C043] |
| 2012–2025 | 168 [C044] | −1.94% [C045] |

Source: `output/tables/table_subperiods_h1.csv`, rows `block=…`, cols `n`, `R2`. (346 + 144 + 168 = 658, D029.)

### Backup B4 — Expanded Predictor Set (146 columns)

| Element | Spec |
|---|---|
| Title | `Backup B4: Expanded Predictor Set (146 columns)` |
| Key message | `Adding 8 newer predictors gives 5 of 27 positive R²_OOS (largest +0.85%, ridge h = 3); no DM tests were run for this variant.` [D008, D009, D030, C057] |
| Table | 9 rows × 4 columns, centred, width 8 in, 12 pt; values verbatim below (R²_OOS in %). |
| Caption | `Baseline 98 predictors + skvw, tail, rdsp, avgcor, dtoy, dtoat, wtexas, lzrt (× 6 lags). Source: data/processed/expanded_variant_summary.csv` [D005] |
| Notes | `Backup for Q&A — not presented. Source: data/processed/expanded_variant_summary.csv.` |
| Do not | call any expanded result significant; claim the expanded set "improves" forecasts. |

| Model | h = 1 | h = 3 | h = 12 |
|---|---|---|---|
| rlasso | -1.04 | -1.22 | -1.17 |
| postlasso | -3.00 | +0.05 | -0.55 |
| ridge | +0.03 | +0.85 | -0.56 |
| enet | -1.52 | -1.62 | -0.66 |
| pcr | -1.35 | -0.13 | -1.03 |
| pls | -1.09 | +0.63 | -0.12 |
| rf | -13.12 | -11.94 | -8.70 |
| equal_comb | -0.96 | +0.10 | -0.38 |
| gr_comb | -0.68 | -0.04 | -0.76 |

Each cell = rows `C046`–`C072` in §8.1 (h = 1 → C046–C054, h = 3 → C055–C063, h = 12 → C064–C072, model order as shown).

### Backup B5 — Full Results at h = 3 and h = 12

| Element | Spec |
|---|---|
| Title | `Backup B5: Full Results at h = 3 and h = 12` |
| Key message | `No model is significant at h = 3 or h = 12; at h = 12 only PCR's switching strategy ends above buy-and-hold.` [D031] |
| Layout | Two tables side by side (left h = 3, right h = 12), each width 6.1 in, 10–11 pt, header navy. Column units: R²_OOS and ΔU in %, wealth in $ per $1, 10 bps. |
| Caption | `Sources: output/tables/table2_h3.csv, table2_h12.csv (R²_OOS, DM p); table3_h3.csv, table3_h12.csv (wealth, ΔU at 10 bps).` |
| Notes | `Backup for Q&A — not presented. Sources: output/tables/table2_h{3,12}.csv, table3_h{3,12}.csv.` |

**h = 3**

| Model | R2_OOS | DM p (sq.) | DM p (abs.) | Wealth 10 bps | DeltaU 10 bps |
|---|---|---|---|---|---|
| rlasso | -0.97 | 0.88 | 0.68 | $214 | -0.54 |
| postlasso | -0.38 | 0.68 | 0.42 | $337 | -0.35 |
| ridge | +0.30 | 0.34 | 0.30 | $379 | +1.27 |
| enet | -1.50 | 1.00 | 0.98 | $256 | -1.80 |
| pcr | -0.88 | 0.74 | 0.82 | $220 | +0.90 |
| pls | -0.64 | 0.68 | 0.39 | $506 | +0.70 |
| rf | -12.33 | 0.99 | 0.99 | $213 | +2.21 |
| equal_comb | -0.14 | 0.56 | 0.48 | $319 | +0.96 |
| gr_comb | -0.98 | 0.81 | 0.62 | $305 | +0.78 |
| Buy-and-hold | – | – | – | $328 | – |

**h = 12**

| Model | R2_OOS | DM p (sq.) | DM p (abs.) | Wealth 10 bps | DeltaU 10 bps |
|---|---|---|---|---|---|
| rlasso | -1.25 | 0.96 | 0.94 | $149 | -0.89 |
| postlasso | -0.52 | 0.95 | 0.90 | $265 | -0.89 |
| ridge | -1.54 | 0.98 | 0.98 | $261 | -1.05 |
| enet | -0.72 | 0.90 | 0.89 | $264 | -0.42 |
| pcr | -2.20 | 0.97 | 0.92 | $323 | -0.26 |
| pls | -1.44 | 0.92 | 0.88 | $259 | -0.10 |
| rf | -10.47 | 1.00 | 0.99 | $76 | +0.56 |
| equal_comb | -0.48 | 0.81 | 0.85 | $193 | -0.48 |
| gr_comb | -2.16 | 0.96 | 0.94 | $167 | -0.81 |
| Buy-and-hold | – | – | – | $265 | – |

Cells = rows `C073`–`C164` in §8.1 (per model: R²_OOS, DM p sq., DM p abs., wealth, ΔU; then buy-and-hold wealth).

---

## 6. Figure placement summary

| Figure | Slide | Position (x, y) | Size | Aspect check |
|---|---|---|---|---|
| figure2_r2oos.png | 6 | 0.5 in, 1.6 in | height 5.3 in | 7 : 6 |
| figure1_wealth.png | 8 | 0.4 in, 1.6 in | width 8.3 in | 10 : 4.2 |
| figure3_gr_weights.png | B1 | centred, 1.5 in | width 10.5 in | 8 : 4.5 |
| figure4_subperiods.png | B3 | 0.5 in, 1.6 in | width 7.0 in | 6 : 3.6 |

Never stretch (lock aspect), never crop, never regenerate figures.

---

## 7. Stale numbers and phrases that must NOT appear anywhere in the deck (slides or notes)

These come from pre-correction versions (old SLIDE_SPEC, make_deck.py, report, README, review files). §9.2 checks them automatically.

| Stale item | Where it came from | Correct replacement |
|---|---|---|
| `-15.49` / `−15.49%` (RF R²) | old spec / report | −15.53% (C008) |
| `232.7` (LASSO wealth) | old spec | not shown; ridge $499 |
| `341.9` (B&H wealth) | old spec | $342 (C023) |
| `-0.39` / `−0.39%` (LASSO ΔU) | old spec | not shown |
| `-2.07`, `-0.99` (old ΔU post-LASSO / GR) | old spec | GR ΔU +1.18% (C038) |
| `-5.30` (old PLS R²) | old spec | not shown |
| `-1.80%` **as GR R²_OOS** | old spec | GR h = 1 R²_OOS is −0.54% (not shown on main slides). Note: `−1.80` legitimately appears in B5 as elastic net ΔU at h = 3. |
| `0.767`, `0.776` (old Sharpe) | old spec | 0.57 / 0.49 (C018, C024) |
| `0.677` (old min DM p), `0.105` (CW p) | old spec | 0.23 (C012) |
| `0.193`, `0.247`, `0.077`, `0.442` (old Neely p-values) | old spec | 0.20 / 0.60 (C033, C036) |
| `4.403` (PM RMSE), hit-rate ranges `53.5`, `59.7`, `59.9`, `60.1` | old spec | not shown |
| `-44.4%`, `-50.2%` (old drawdowns, 1 dp) | old spec | −44% / −50% |
| "log premium", "log equity premium", "log excess return" | old report/spec | "simple % premium" |
| "Clark–West p", "CW test", "MSFE-adjusted" | old evaluation | Diebold–Mariano only (Clark–West may appear only as "Clark–West → DM" in the slide-4 change box) |
| "LASSO is the best model", "post-LASSO best", "outperforms", "winner" | old narrative | see honesty rules §1 |
| "OLS benchmark" as current design | proposal | prevailing mean |

---

## 8. Number appendix (every number on every slide)

Rounding: `Digits` = decimals after multiplying by `Scale`; R `round()` half-even semantics as produced by the generator. `Value` is the number §9 compares against. Row keys are `column=value` pairs joined by `&` that select exactly one CSV row.

### 8.1 Cell values (C rows) — read directly from one CSV cell

| ID | Slide | Shown as | Value | Digits | Scale | File | Row key | Column |
|---|---|---|---|---|---|---|---|---|
| C001 | 3 | 899 | 899 | 0 | 1 | `output/tables/table1.csv` | `Panel=A: target (full sample)&Series=eq_prem` | `N` |
| C002 | 4 | 658 | 658 | 0 | 1 | `output/tables/table1.csv` | `Panel=A: target (OOS)&Series=eq_prem` | `N` |
| C003 | 4 | 654 | 654 | 0 | 1 | `output/tables/table3_alt_h3.csv` | `model=pm` | `months` |
| C004 | 4 | 636 | 636 | 0 | 1 | `output/tables/table3_alt_h12.csv` | `model=pm` | `months` |
| C005 | 6, 7, 10 | +0.12% | 0.12 | 2 | 1 | `output/tables/table2_h1.csv` | `model=ridge` | `R2_OOS_pct` |
| C006 | 6, 7, 10 | +0.30% | 0.30 | 2 | 1 | `output/tables/table2_h3.csv` | `model=ridge` | `R2_OOS_pct` |
| C007 | 6, 7 | -0.48% | -0.48 | 2 | 1 | `output/tables/table2_h12.csv` | `model=equal_comb` | `R2_OOS_pct` |
| C008 | 6 | -15.53% | -15.53 | 2 | 1 | `output/tables/table2_h1.csv` | `model=rf` | `R2_OOS_pct` |
| C009 | 6 | -12.33% | -12.33 | 2 | 1 | `output/tables/table2_h3.csv` | `model=rf` | `R2_OOS_pct` |
| C010 | 6 | -10.47% | -10.47 | 2 | 1 | `output/tables/table2_h12.csv` | `model=rf` | `R2_OOS_pct` |
| C011 | 7 | 0.45 | 0.45 | 2 | 1 | `output/tables/table2_h1.csv` | `model=ridge` | `DM_RMSE_p` |
| C012 | 7, 10 | 0.23 | 0.23 | 2 | 1 | `output/tables/table2_h1.csv` | `model=ridge` | `DM_MAE_p` |
| C013 | 7 | 0.34 | 0.34 | 2 | 1 | `output/tables/table2_h3.csv` | `model=ridge` | `DM_RMSE_p` |
| C014 | 7 | 0.30 | 0.30 | 2 | 1 | `output/tables/table2_h3.csv` | `model=ridge` | `DM_MAE_p` |
| C015 | 7 | 0.81 | 0.81 | 2 | 1 | `output/tables/table2_h12.csv` | `model=equal_comb` | `DM_RMSE_p` |
| C016 | 7 | 0.85 | 0.85 | 2 | 1 | `output/tables/table2_h12.csv` | `model=equal_comb` | `DM_MAE_p` |
| C017 | 8 | $499 | 499 | 0 | 1 | `output/tables/table3_h1.csv` | `model=ridge` | `sw_wealth_10bps` |
| C018 | 8 | 0.57 | 0.57 | 2 | 1 | `output/tables/table3_h1.csv` | `model=ridge` | `sw_sharpe_10bps` |
| C019 | 8 | -44% | -44 | 0 | 100 | `output/tables/table3_h1.csv` | `model=ridge` | `sw_maxdd_10bps` |
| C020 | 8 | $421 | 421 | 0 | 1 | `output/tables/table3_h1.csv` | `model=gr_comb` | `sw_wealth_10bps` |
| C021 | 8 | 0.55 | 0.55 | 2 | 1 | `output/tables/table3_h1.csv` | `model=gr_comb` | `sw_sharpe_10bps` |
| C022 | 8 | -44% | -44 | 0 | 100 | `output/tables/table3_h1.csv` | `model=gr_comb` | `sw_maxdd_10bps` |
| C023 | 8 | $342 | 342 | 0 | 1 | `output/tables/table3_h1.csv` | `model=Buy-and-Hold` | `sw_wealth_10bps` |
| C024 | 8 | 0.49 | 0.49 | 2 | 1 | `output/tables/table3_h1.csv` | `model=Buy-and-Hold` | `sw_sharpe_10bps` |
| C025 | 8 | -50% | -50 | 0 | 100 | `output/tables/table3_h1.csv` | `model=Buy-and-Hold` | `sw_maxdd_10bps` |
| C026 | 8 | $508 | 508 | 0 | 1 | `output/tables/table3_h1.csv` | `model=ridge` | `sw_wealth_5bps` |
| C027 | 8 | $482 | 482 | 0 | 1 | `output/tables/table3_h1.csv` | `model=ridge` | `sw_wealth_20bps` |
| C028 | 8 | $93 | 93 | 0 | 1 | `output/tables/table3_h1.csv` | `model=rf` | `sw_wealth_10bps` |
| C029 | 8 | $193 | 193 | 0 | 1 | `output/tables/table3_h12.csv` | `model=equal_comb` | `sw_wealth_10bps` |
| C030 | 8 | $265 | 265 | 0 | 1 | `output/tables/table3_h12.csv` | `model=Buy-and-Hold` | `sw_wealth_10bps` |
| C031 | 9 | 552 | 552 | 0 | 1 | `output/tables/table5_neely_replication.csv` | `sample=Neely sample 1966-2011&signal=VOL_1_12` | `n` |
| C032 | 9 | +0.59% | 0.59 | 2 | 1 | `output/tables/table5_neely_replication.csv` | `sample=Neely sample 1966-2011&signal=VOL_1_12` | `R2_OOS_pct` |
| C033 | 9 | 0.20 | 0.20 | 2 | 1 | `output/tables/table5_neely_replication.csv` | `sample=Neely sample 1966-2011&signal=VOL_3_12` | `DM_RMSE_p` |
| C034 | 9 | 168 | 168 | 0 | 1 | `output/tables/table5_neely_replication.csv` | `sample=Extension 2012-2025&signal=VOL_3_9` | `n` |
| C035 | 9 | -0.27% | -0.27 | 2 | 1 | `output/tables/table5_neely_replication.csv` | `sample=Extension 2012-2025&signal=VOL_3_9` | `R2_OOS_pct` |
| C036 | 9 | 0.60 | 0.60 | 2 | 1 | `output/tables/table5_neely_replication.csv` | `sample=Extension 2012-2025&signal=VOL_3_12` | `DM_RMSE_p` |
| C037 | 9 | +1.92% | 1.92 | 2 | 1 | `output/tables/table3_h1.csv` | `model=ridge` | `mv_deltaU_10bps_pct` |
| C038 | 9 | +1.18% | 1.18 | 2 | 1 | `output/tables/table3_h1.csv` | `model=gr_comb` | `mv_deltaU_10bps_pct` |
| C039 | 9 | -2.54% | -2.54 | 2 | 1 | `output/tables/table5_neely_replication.csv` | `sample=Extension 2012-2025&signal=VOL_1_12` | `R2_OOS_pct` |
| C040 | B3 | 346 | 346 | 0 | 1 | `output/tables/table_subperiods_h1.csv` | `block=1971-1999` | `n` |
| C041 | B3 | -0.63% | -0.63 | 2 | 1 | `output/tables/table_subperiods_h1.csv` | `block=1971-1999` | `R2` |
| C042 | B3 | 144 | 144 | 0 | 1 | `output/tables/table_subperiods_h1.csv` | `block=2000-2011` | `n` |
| C043 | B3 | -1.20% | -1.20 | 2 | 1 | `output/tables/table_subperiods_h1.csv` | `block=2000-2011` | `R2` |
| C044 | B3 | 168 | 168 | 0 | 1 | `output/tables/table_subperiods_h1.csv` | `block=2012-2025` | `n` |
| C045 | B3 | -1.94% | -1.94 | 2 | 1 | `output/tables/table_subperiods_h1.csv` | `block=2012-2025` | `R2` |
| C046 | B4 | -1.04% | -1.04 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=rlasso&horizon=1` | `R2_OOS_pct` |
| C047 | B4 | -3.00% | -3.00 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=postlasso&horizon=1` | `R2_OOS_pct` |
| C048 | B4 | +0.03% | 0.03 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=ridge&horizon=1` | `R2_OOS_pct` |
| C049 | B4 | -1.52% | -1.52 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=enet&horizon=1` | `R2_OOS_pct` |
| C050 | B4 | -1.35% | -1.35 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=pcr&horizon=1` | `R2_OOS_pct` |
| C051 | B4 | -1.09% | -1.09 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=pls&horizon=1` | `R2_OOS_pct` |
| C052 | B4 | -13.12% | -13.12 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=rf&horizon=1` | `R2_OOS_pct` |
| C053 | B4 | -0.96% | -0.96 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=equal_comb&horizon=1` | `R2_OOS_pct` |
| C054 | B4 | -0.68% | -0.68 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=gr_comb&horizon=1` | `R2_OOS_pct` |
| C055 | B4 | -1.22% | -1.22 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=rlasso&horizon=3` | `R2_OOS_pct` |
| C056 | B4 | +0.05% | 0.05 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=postlasso&horizon=3` | `R2_OOS_pct` |
| C057 | B4 | +0.85% | 0.85 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=ridge&horizon=3` | `R2_OOS_pct` |
| C058 | B4 | -1.62% | -1.62 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=enet&horizon=3` | `R2_OOS_pct` |
| C059 | B4 | -0.13% | -0.13 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=pcr&horizon=3` | `R2_OOS_pct` |
| C060 | B4 | +0.63% | 0.63 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=pls&horizon=3` | `R2_OOS_pct` |
| C061 | B4 | -11.94% | -11.94 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=rf&horizon=3` | `R2_OOS_pct` |
| C062 | B4 | +0.10% | 0.10 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=equal_comb&horizon=3` | `R2_OOS_pct` |
| C063 | B4 | -0.04% | -0.04 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=gr_comb&horizon=3` | `R2_OOS_pct` |
| C064 | B4 | -1.17% | -1.17 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=rlasso&horizon=12` | `R2_OOS_pct` |
| C065 | B4 | -0.55% | -0.55 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=postlasso&horizon=12` | `R2_OOS_pct` |
| C066 | B4 | -0.56% | -0.56 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=ridge&horizon=12` | `R2_OOS_pct` |
| C067 | B4 | -0.66% | -0.66 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=enet&horizon=12` | `R2_OOS_pct` |
| C068 | B4 | -1.03% | -1.03 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=pcr&horizon=12` | `R2_OOS_pct` |
| C069 | B4 | -0.12% | -0.12 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=pls&horizon=12` | `R2_OOS_pct` |
| C070 | B4 | -8.70% | -8.70 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=rf&horizon=12` | `R2_OOS_pct` |
| C071 | B4 | -0.38% | -0.38 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=equal_comb&horizon=12` | `R2_OOS_pct` |
| C072 | B4 | -0.76% | -0.76 | 2 | 1 | `data/processed/expanded_variant_summary.csv` | `model=gr_comb&horizon=12` | `R2_OOS_pct` |
| C073 | B5 | -0.97% | -0.97 | 2 | 1 | `output/tables/table2_h3.csv` | `model=rlasso` | `R2_OOS_pct` |
| C074 | B5 | 0.88 | 0.88 | 2 | 1 | `output/tables/table2_h3.csv` | `model=rlasso` | `DM_RMSE_p` |
| C075 | B5 | 0.68 | 0.68 | 2 | 1 | `output/tables/table2_h3.csv` | `model=rlasso` | `DM_MAE_p` |
| C076 | B5 | $214 | 214 | 0 | 1 | `output/tables/table3_h3.csv` | `model=rlasso` | `sw_wealth_10bps` |
| C077 | B5 | -0.54% | -0.54 | 2 | 1 | `output/tables/table3_h3.csv` | `model=rlasso` | `mv_deltaU_10bps_pct` |
| C078 | B5 | -0.38% | -0.38 | 2 | 1 | `output/tables/table2_h3.csv` | `model=postlasso` | `R2_OOS_pct` |
| C079 | B5 | 0.68 | 0.68 | 2 | 1 | `output/tables/table2_h3.csv` | `model=postlasso` | `DM_RMSE_p` |
| C080 | B5 | 0.42 | 0.42 | 2 | 1 | `output/tables/table2_h3.csv` | `model=postlasso` | `DM_MAE_p` |
| C081 | B5 | $337 | 337 | 0 | 1 | `output/tables/table3_h3.csv` | `model=postlasso` | `sw_wealth_10bps` |
| C082 | B5 | -0.35% | -0.35 | 2 | 1 | `output/tables/table3_h3.csv` | `model=postlasso` | `mv_deltaU_10bps_pct` |
| C083 | B5 | +0.30% | 0.30 | 2 | 1 | `output/tables/table2_h3.csv` | `model=ridge` | `R2_OOS_pct` |
| C084 | B5 | 0.34 | 0.34 | 2 | 1 | `output/tables/table2_h3.csv` | `model=ridge` | `DM_RMSE_p` |
| C085 | B5 | 0.30 | 0.30 | 2 | 1 | `output/tables/table2_h3.csv` | `model=ridge` | `DM_MAE_p` |
| C086 | B5 | $379 | 379 | 0 | 1 | `output/tables/table3_h3.csv` | `model=ridge` | `sw_wealth_10bps` |
| C087 | B5 | +1.27% | 1.27 | 2 | 1 | `output/tables/table3_h3.csv` | `model=ridge` | `mv_deltaU_10bps_pct` |
| C088 | B5 | -1.50% | -1.50 | 2 | 1 | `output/tables/table2_h3.csv` | `model=enet` | `R2_OOS_pct` |
| C089 | B5 | 1.00 | 1.00 | 2 | 1 | `output/tables/table2_h3.csv` | `model=enet` | `DM_RMSE_p` |
| C090 | B5 | 0.98 | 0.98 | 2 | 1 | `output/tables/table2_h3.csv` | `model=enet` | `DM_MAE_p` |
| C091 | B5 | $256 | 256 | 0 | 1 | `output/tables/table3_h3.csv` | `model=enet` | `sw_wealth_10bps` |
| C092 | B5 | -1.80% | -1.80 | 2 | 1 | `output/tables/table3_h3.csv` | `model=enet` | `mv_deltaU_10bps_pct` |
| C093 | B5 | -0.88% | -0.88 | 2 | 1 | `output/tables/table2_h3.csv` | `model=pcr` | `R2_OOS_pct` |
| C094 | B5 | 0.74 | 0.74 | 2 | 1 | `output/tables/table2_h3.csv` | `model=pcr` | `DM_RMSE_p` |
| C095 | B5 | 0.82 | 0.82 | 2 | 1 | `output/tables/table2_h3.csv` | `model=pcr` | `DM_MAE_p` |
| C096 | B5 | $220 | 220 | 0 | 1 | `output/tables/table3_h3.csv` | `model=pcr` | `sw_wealth_10bps` |
| C097 | B5 | +0.90% | 0.90 | 2 | 1 | `output/tables/table3_h3.csv` | `model=pcr` | `mv_deltaU_10bps_pct` |
| C098 | B5 | -0.64% | -0.64 | 2 | 1 | `output/tables/table2_h3.csv` | `model=pls` | `R2_OOS_pct` |
| C099 | B5 | 0.68 | 0.68 | 2 | 1 | `output/tables/table2_h3.csv` | `model=pls` | `DM_RMSE_p` |
| C100 | B5 | 0.39 | 0.39 | 2 | 1 | `output/tables/table2_h3.csv` | `model=pls` | `DM_MAE_p` |
| C101 | B5 | $506 | 506 | 0 | 1 | `output/tables/table3_h3.csv` | `model=pls` | `sw_wealth_10bps` |
| C102 | B5 | +0.70% | 0.70 | 2 | 1 | `output/tables/table3_h3.csv` | `model=pls` | `mv_deltaU_10bps_pct` |
| C103 | B5 | -12.33% | -12.33 | 2 | 1 | `output/tables/table2_h3.csv` | `model=rf` | `R2_OOS_pct` |
| C104 | B5 | 0.99 | 0.99 | 2 | 1 | `output/tables/table2_h3.csv` | `model=rf` | `DM_RMSE_p` |
| C105 | B5 | 0.99 | 0.99 | 2 | 1 | `output/tables/table2_h3.csv` | `model=rf` | `DM_MAE_p` |
| C106 | B5 | $213 | 213 | 0 | 1 | `output/tables/table3_h3.csv` | `model=rf` | `sw_wealth_10bps` |
| C107 | B5 | +2.21% | 2.21 | 2 | 1 | `output/tables/table3_h3.csv` | `model=rf` | `mv_deltaU_10bps_pct` |
| C108 | B5 | -0.14% | -0.14 | 2 | 1 | `output/tables/table2_h3.csv` | `model=equal_comb` | `R2_OOS_pct` |
| C109 | B5 | 0.56 | 0.56 | 2 | 1 | `output/tables/table2_h3.csv` | `model=equal_comb` | `DM_RMSE_p` |
| C110 | B5 | 0.48 | 0.48 | 2 | 1 | `output/tables/table2_h3.csv` | `model=equal_comb` | `DM_MAE_p` |
| C111 | B5 | $319 | 319 | 0 | 1 | `output/tables/table3_h3.csv` | `model=equal_comb` | `sw_wealth_10bps` |
| C112 | B5 | +0.96% | 0.96 | 2 | 1 | `output/tables/table3_h3.csv` | `model=equal_comb` | `mv_deltaU_10bps_pct` |
| C113 | B5 | -0.98% | -0.98 | 2 | 1 | `output/tables/table2_h3.csv` | `model=gr_comb` | `R2_OOS_pct` |
| C114 | B5 | 0.81 | 0.81 | 2 | 1 | `output/tables/table2_h3.csv` | `model=gr_comb` | `DM_RMSE_p` |
| C115 | B5 | 0.62 | 0.62 | 2 | 1 | `output/tables/table2_h3.csv` | `model=gr_comb` | `DM_MAE_p` |
| C116 | B5 | $305 | 305 | 0 | 1 | `output/tables/table3_h3.csv` | `model=gr_comb` | `sw_wealth_10bps` |
| C117 | B5 | +0.78% | 0.78 | 2 | 1 | `output/tables/table3_h3.csv` | `model=gr_comb` | `mv_deltaU_10bps_pct` |
| C118 | B5 | $328 | 328 | 0 | 1 | `output/tables/table3_h3.csv` | `model=Buy-and-Hold` | `sw_wealth_10bps` |
| C119 | B5 | -1.25% | -1.25 | 2 | 1 | `output/tables/table2_h12.csv` | `model=rlasso` | `R2_OOS_pct` |
| C120 | B5 | 0.96 | 0.96 | 2 | 1 | `output/tables/table2_h12.csv` | `model=rlasso` | `DM_RMSE_p` |
| C121 | B5 | 0.94 | 0.94 | 2 | 1 | `output/tables/table2_h12.csv` | `model=rlasso` | `DM_MAE_p` |
| C122 | B5 | $149 | 149 | 0 | 1 | `output/tables/table3_h12.csv` | `model=rlasso` | `sw_wealth_10bps` |
| C123 | B5 | -0.89% | -0.89 | 2 | 1 | `output/tables/table3_h12.csv` | `model=rlasso` | `mv_deltaU_10bps_pct` |
| C124 | B5 | -0.52% | -0.52 | 2 | 1 | `output/tables/table2_h12.csv` | `model=postlasso` | `R2_OOS_pct` |
| C125 | B5 | 0.95 | 0.95 | 2 | 1 | `output/tables/table2_h12.csv` | `model=postlasso` | `DM_RMSE_p` |
| C126 | B5 | 0.90 | 0.90 | 2 | 1 | `output/tables/table2_h12.csv` | `model=postlasso` | `DM_MAE_p` |
| C127 | B5 | $265 | 265 | 0 | 1 | `output/tables/table3_h12.csv` | `model=postlasso` | `sw_wealth_10bps` |
| C128 | B5 | -0.89% | -0.89 | 2 | 1 | `output/tables/table3_h12.csv` | `model=postlasso` | `mv_deltaU_10bps_pct` |
| C129 | B5 | -1.54% | -1.54 | 2 | 1 | `output/tables/table2_h12.csv` | `model=ridge` | `R2_OOS_pct` |
| C130 | B5 | 0.98 | 0.98 | 2 | 1 | `output/tables/table2_h12.csv` | `model=ridge` | `DM_RMSE_p` |
| C131 | B5 | 0.98 | 0.98 | 2 | 1 | `output/tables/table2_h12.csv` | `model=ridge` | `DM_MAE_p` |
| C132 | B5 | $261 | 261 | 0 | 1 | `output/tables/table3_h12.csv` | `model=ridge` | `sw_wealth_10bps` |
| C133 | B5 | -1.05% | -1.05 | 2 | 1 | `output/tables/table3_h12.csv` | `model=ridge` | `mv_deltaU_10bps_pct` |
| C134 | B5 | -0.72% | -0.72 | 2 | 1 | `output/tables/table2_h12.csv` | `model=enet` | `R2_OOS_pct` |
| C135 | B5 | 0.90 | 0.90 | 2 | 1 | `output/tables/table2_h12.csv` | `model=enet` | `DM_RMSE_p` |
| C136 | B5 | 0.89 | 0.89 | 2 | 1 | `output/tables/table2_h12.csv` | `model=enet` | `DM_MAE_p` |
| C137 | B5 | $264 | 264 | 0 | 1 | `output/tables/table3_h12.csv` | `model=enet` | `sw_wealth_10bps` |
| C138 | B5 | -0.42% | -0.42 | 2 | 1 | `output/tables/table3_h12.csv` | `model=enet` | `mv_deltaU_10bps_pct` |
| C139 | B5 | -2.20% | -2.20 | 2 | 1 | `output/tables/table2_h12.csv` | `model=pcr` | `R2_OOS_pct` |
| C140 | B5 | 0.97 | 0.97 | 2 | 1 | `output/tables/table2_h12.csv` | `model=pcr` | `DM_RMSE_p` |
| C141 | B5 | 0.92 | 0.92 | 2 | 1 | `output/tables/table2_h12.csv` | `model=pcr` | `DM_MAE_p` |
| C142 | B5 | $323 | 323 | 0 | 1 | `output/tables/table3_h12.csv` | `model=pcr` | `sw_wealth_10bps` |
| C143 | B5 | -0.26% | -0.26 | 2 | 1 | `output/tables/table3_h12.csv` | `model=pcr` | `mv_deltaU_10bps_pct` |
| C144 | B5 | -1.44% | -1.44 | 2 | 1 | `output/tables/table2_h12.csv` | `model=pls` | `R2_OOS_pct` |
| C145 | B5 | 0.92 | 0.92 | 2 | 1 | `output/tables/table2_h12.csv` | `model=pls` | `DM_RMSE_p` |
| C146 | B5 | 0.88 | 0.88 | 2 | 1 | `output/tables/table2_h12.csv` | `model=pls` | `DM_MAE_p` |
| C147 | B5 | $259 | 259 | 0 | 1 | `output/tables/table3_h12.csv` | `model=pls` | `sw_wealth_10bps` |
| C148 | B5 | -0.10% | -0.10 | 2 | 1 | `output/tables/table3_h12.csv` | `model=pls` | `mv_deltaU_10bps_pct` |
| C149 | B5 | -10.47% | -10.47 | 2 | 1 | `output/tables/table2_h12.csv` | `model=rf` | `R2_OOS_pct` |
| C150 | B5 | 1.00 | 1.00 | 2 | 1 | `output/tables/table2_h12.csv` | `model=rf` | `DM_RMSE_p` |
| C151 | B5 | 0.99 | 0.99 | 2 | 1 | `output/tables/table2_h12.csv` | `model=rf` | `DM_MAE_p` |
| C152 | B5 | $76 | 76 | 0 | 1 | `output/tables/table3_h12.csv` | `model=rf` | `sw_wealth_10bps` |
| C153 | B5 | +0.56% | 0.56 | 2 | 1 | `output/tables/table3_h12.csv` | `model=rf` | `mv_deltaU_10bps_pct` |
| C154 | B5 | -0.48% | -0.48 | 2 | 1 | `output/tables/table2_h12.csv` | `model=equal_comb` | `R2_OOS_pct` |
| C155 | B5 | 0.81 | 0.81 | 2 | 1 | `output/tables/table2_h12.csv` | `model=equal_comb` | `DM_RMSE_p` |
| C156 | B5 | 0.85 | 0.85 | 2 | 1 | `output/tables/table2_h12.csv` | `model=equal_comb` | `DM_MAE_p` |
| C157 | B5 | $193 | 193 | 0 | 1 | `output/tables/table3_h12.csv` | `model=equal_comb` | `sw_wealth_10bps` |
| C158 | B5 | -0.48% | -0.48 | 2 | 1 | `output/tables/table3_h12.csv` | `model=equal_comb` | `mv_deltaU_10bps_pct` |
| C159 | B5 | -2.16% | -2.16 | 2 | 1 | `output/tables/table2_h12.csv` | `model=gr_comb` | `R2_OOS_pct` |
| C160 | B5 | 0.96 | 0.96 | 2 | 1 | `output/tables/table2_h12.csv` | `model=gr_comb` | `DM_RMSE_p` |
| C161 | B5 | 0.94 | 0.94 | 2 | 1 | `output/tables/table2_h12.csv` | `model=gr_comb` | `DM_MAE_p` |
| C162 | B5 | $167 | 167 | 0 | 1 | `output/tables/table3_h12.csv` | `model=gr_comb` | `sw_wealth_10bps` |
| C163 | B5 | -0.81% | -0.81 | 2 | 1 | `output/tables/table3_h12.csv` | `model=gr_comb` | `mv_deltaU_10bps_pct` |
| C164 | B5 | $265 | 265 | 0 | 1 | `output/tables/table3_h12.csv` | `model=Buy-and-Hold` | `sw_wealth_10bps` |

### 8.2 Recomputed values (R rows) — B2 table (no CSV exists; source of display = `output/tables/tableA1_tex.tex`)

Value = `round(100 * (1 - sum((y - f_model)^2) / sum((y - f_pm)^2)), 2)` over the rows of the forecast file, `y = panel.csv$eq_prem[target_index]`.

| ID | Slide | Shown as | Value | Digits | Forecast file | Model column |
|---|---|---|---|---|---|---|
| R001 | B2 | -1.06% | -1.06 | 2 | `data/processed/forecasts_h1.csv` | `rlasso` |
| R002 | B2 | -2.83% | -2.83 | 2 | `data/processed/forecasts_h1.csv` | `postlasso` |
| R003 | B2 | +0.12% | 0.12 | 2 | `data/processed/forecasts_h1.csv` | `ridge` |
| R004 | B2 | -1.00% | -1.00 | 2 | `data/processed/forecasts_h1.csv` | `enet` |
| R005 | B2 | -1.29% | -1.29 | 2 | `data/processed/forecasts_h1.csv` | `pcr` |
| R006 | B2 | -1.24% | -1.24 | 2 | `data/processed/forecasts_h1.csv` | `pls` |
| R007 | B2 | -15.53% | -15.53 | 2 | `data/processed/forecasts_h1.csv` | `rf` |
| R008 | B2 | -1.09% | -1.09 | 2 | `data/processed/forecasts_h1.csv` | `equal_comb` |
| R009 | B2 | -0.54% | -0.54 | 2 | `data/processed/forecasts_h1.csv` | `gr_comb` |
| R010 | B2 | -0.84% | -0.84 | 2 | `data/processed/forecasts_h1_tech.csv` | `rlasso` |
| R011 | B2 | -0.53% | -0.53 | 2 | `data/processed/forecasts_h1_tech.csv` | `postlasso` |
| R012 | B2 | -1.06% | -1.06 | 2 | `data/processed/forecasts_h1_tech.csv` | `ridge` |
| R013 | B2 | -1.13% | -1.13 | 2 | `data/processed/forecasts_h1_tech.csv` | `enet` |
| R014 | B2 | -1.63% | -1.63 | 2 | `data/processed/forecasts_h1_tech.csv` | `pcr` |
| R015 | B2 | -1.67% | -1.67 | 2 | `data/processed/forecasts_h1_tech.csv` | `pls` |
| R016 | B2 | -5.42% | -5.42 | 2 | `data/processed/forecasts_h1_tech.csv` | `rf` |
| R017 | B2 | -1.10% | -1.10 | 2 | `data/processed/forecasts_h1_tech.csv` | `equal_comb` |
| R018 | B2 | -1.56% | -1.56 | 2 | `data/processed/forecasts_h1_tech.csv` | `gr_comb` |
| R019 | B2 | -1.03% | -1.03 | 2 | `data/processed/forecasts_h1_macro.csv` | `rlasso` |
| R020 | B2 | -2.80% | -2.80 | 2 | `data/processed/forecasts_h1_macro.csv` | `postlasso` |
| R021 | B2 | +0.17% | 0.17 | 2 | `data/processed/forecasts_h1_macro.csv` | `ridge` |
| R022 | B2 | -1.17% | -1.17 | 2 | `data/processed/forecasts_h1_macro.csv` | `enet` |
| R023 | B2 | -2.15% | -2.15 | 2 | `data/processed/forecasts_h1_macro.csv` | `pcr` |
| R024 | B2 | -1.25% | -1.25 | 2 | `data/processed/forecasts_h1_macro.csv` | `pls` |
| R025 | B2 | -15.13% | -15.13 | 2 | `data/processed/forecasts_h1_macro.csv` | `rf` |
| R026 | B2 | -1.13% | -1.13 | 2 | `data/processed/forecasts_h1_macro.csv` | `equal_comb` |
| R027 | B2 | -0.49% | -0.49 | 2 | `data/processed/forecasts_h1_macro.csv` | `gr_comb` |

### 8.3 Derived counts, config constants and labels (D rows) — each R check must return TRUE

Helper objects available to the expressions: `rd(f)` (read.csv), `CONFIG` (from `R/00_config.R`), `M` (the 9 model names), `T2(h)`/`T3(h)` (paths of table2/table3 for horizon h), `N5` (Neely table path).

| ID | Slide | Shown as | Value(s) | R check |
|---|---|---|---|---|
| D001 | 3 | 98 predictors | 98 | `sum(rd("data/processed/codebook.csv")$group != "target") == 98` |
| D002 | 3 | 84 macro columns | 84 | `sum(rd("data/processed/codebook.csv")$group == "macro") == 84` |
| D003 | 3, 9 | 14 technical signals | 14 | `sum(rd("data/processed/codebook.csv")$group == "technical") == 14 & length(CONFIG$TECHNICAL_NAMES) == 14` |
| D004 | 3 | 14 macro variables | 14 | `length(CONFIG$MACRO_CLASSIC) == 14` |
| D005 | 3, 4, B4 | lags 1–6 / up to 6 lags | 1 6 | `CONFIG$MAX_LAG == 6` |
| D006 | 3 | 6 MA, 2 MOM, 6 VOL | 6 2 6 | `all(c(sum(startsWith(CONFIG$TECHNICAL_NAMES, "MA_")), sum(startsWith(CONFIG$TECHNICAL_NAMES, "MOM_")), sum(startsWith(CONFIG$TECHNICAL_NAMES, "VOL_"))) == c(6, 2, 6))` |
| D007 | 3 | 99.98% | 99.98 | `with(rd("output/tables/signal_validation.csv"), round(100 * (1 - sum(mismatches) / sum(months_compared)), 2) == 99.98)` |
| D008 | 3, B4 | +8 newer predictors | 8 | `length(CONFIG$MACRO_EXPANDED) == 8` |
| D009 | 3, B4 | 146 columns | 146 | `sum(rd("data/processed/codebook_expanded.csv")$group != "target") == 146` |
| D010 | 3 | 1951:02 | 1951 2 | `CONFIG$SAMPLE_START == "1951-02-01"` |
| D011 | 3, 4 | 2025:12 | 2025 12 | `CONFIG$SAMPLE_END == "2025-12-01" & rd("output/tables/table_subperiods_h1.csv")$last_target[3] == "2025-12-01"` |
| D012 | 4 | 240 months | 240 | `CONFIG$W_ROLLING == 240` |
| D013 | 4, 6, 8 | h = 1, 3, 12 | 1 3 12 | `identical(as.integer(CONFIG$HORIZONS), c(1L, 3L, 12L))` |
| D014 | 4 | 1971:03 (first h = 1 target) | 1971 3 | `rd("output/tables/table_subperiods_h1.csv")$first_target[1] == "1971-03-01"` |
| D015 | 5 | 7 models + 2 combinations | 7 2 | `nrow(rd(T2(1))) == 9 & sum(rd(T2(1))$model %in% c("equal_comb", "gr_comb")) == 2` |
| D016 | 6, 10 | 2 of 27 positive; 9 models × 3 horizons | 2 27 9 3 | `{ r <- unlist(lapply(c(1, 3, 12), function(h) rd(T2(h))$R2_OOS_pct)); sum(r > 0) == 2 & length(r) == 27 }` |
| D017 | 7, 8 | highest-R² model: ridge, ridge, equal_comb | — | `identical(sapply(c(1, 3, 12), function(h) { d <- rd(T2(h)); d$model[which.max(d$R2_OOS_pct)] }), c("ridge", "ridge", "equal_comb"))` |
| D018 | 7 | none of 54 tests rejects at 10% | 54 10 0.10 | `{ p <- unlist(lapply(c(1, 3, 12), function(h) { d <- rd(T2(h)); c(d$DM_RMSE_p, d$DM_MAE_p) })); sum(p < 0.10) == 0 & length(p) == 54 }` |
| D019 | 7, 10 | smallest p = 0.23 | 0.23 | `{ p <- unlist(lapply(c(1, 3, 12), function(h) { d <- rd(T2(h)); c(d$DM_RMSE_p, d$DM_MAE_p) })); round(min(p), 2) == 0.23 }` |
| D020 | 7 | shown models have the smallest p per horizon | — | `all(sapply(c(1, 3, 12), function(h) { d <- rd(T2(h)); b <- d$model[which.max(d$R2_OOS_pct)]; d$model[which.min(d$DM_RMSE_p)] == b & d$model[which.min(d$DM_MAE_p)] == b }))` |
| D021 | 8 | costs 5 / 10 / 20 bps | 5 10 20 | `CONFIG$FEE_BPS == 10 & identical(CONFIG$FEE_SENSITIVITY, c(5, 20))` |
| D022 | 8 | 4 of 9 below buy-and-hold at h = 1 | 4 9 | `{ d <- rd(T3(1)); d <- d[d$model %in% M, ]; nrow(d) == 9 & sum(d$sw_wealth_10bps < d$sw_wealth_bh) == 4 }` |
| D023 | 8 | buy-and-hold = PM at h = 1 | — | `{ d <- rd(T3(1)); pm <- d[d$model == "Prevailing Mean", ]; pm$sw_switches == 1 & pm$sw_eq_exposure == 1 & abs(pm$sw_wealth_10bps - d$sw_wealth_10bps[d$model == "Buy-and-Hold"]) < 0.001 }` |
| D024 | 9 | γ = 3, weight 0–1.5 | 3 0 1.5 | `CONFIG$GAMMA == 3 & CONFIG$W_MIN == 0 & CONFIG$W_MAX == 1.5` |
| D025 | 9 | 10 of 14 (1966–2011), 0 of 14 (2012–2025) positive; extremes/min p at named signals | 10 14 0 1966 2011 2012 2025 | `{ d <- rd(N5); a <- d[d$sample == "Neely sample 1966-2011", ]; b <- d[d$sample == "Extension 2012-2025", ]; sum(a$R2_OOS_pct > 0) == 10 & sum(b$R2_OOS_pct > 0) == 0 & nrow(a) == 14 & nrow(b) == 14 & a$signal[which.max(a$R2_OOS_pct)] == "VOL_1_12" & a$signal[which.min(a$DM_RMSE_p)] == "VOL_3_12" & b$signal[which.max(b$R2_OOS_pct)] == "VOL_3_9" & b$signal[which.min(b$R2_OOS_pct)] == "VOL_1_12" & b$signal[which.min(b$DM_RMSE_p)] == "VOL_3_12" }` |
| D026 | 9 | h = 1: 6 of 9 gain utility; ridge highest | 6 9 | `{ d <- rd(T3(1)); d <- d[d$model %in% M, ]; sum(d$mv_deltaU_10bps_pct > 0) == 6 & d$model[which.max(d$mv_deltaU_10bps_pct)] == "ridge" }` |
| D027 | 9 | h = 12: 8 of 9 lose utility | 8 9 | `{ d <- rd(T3(12)); d <- d[d$model %in% M, ]; sum(d$mv_deltaU_10bps_pct < 0) == 8 }` |
| D028 | B2 | only ridge (full, macro) > 0 | — | `{ y <- rd("data/processed/panel.csv")$eq_prem; pos <- unlist(lapply(c("forecasts_h1.csv", "forecasts_h1_tech.csv", "forecasts_h1_macro.csv"), function(f) { fc <- rd(file.path("data/processed", f)); a <- y[fc$target_index]; s <- sapply(M, function(m) 1 - sum((a - fc[[m]])^2) / sum((a - fc$pm)^2)); if (any(s > 0)) paste(f, M[s > 0]) })); identical(pos, c("forecasts_h1.csv ridge", "forecasts_h1_macro.csv ridge")) }` |
| D029 | B3 | 346 + 144 + 168 = 658 | 658 | `sum(rd("output/tables/table_subperiods_h1.csv")$n) == 658` |
| D030 | B4 | 5 of 27 positive, largest = ridge h = 3 | 5 27 | `{ e <- rd("data/processed/expanded_variant_summary.csv"); sum(e$R2_OOS_pct > 0) == 5 & nrow(e) == 27 & e$model[which.max(e$R2_OOS_pct)] == "ridge" & e$horizon[which.max(e$R2_OOS_pct)] == 3 }` |
| D031 | B5 | no DM p < 0.10 at h = 3, 12; h = 12 only PCR above buy-and-hold | — | `{ p <- unlist(lapply(c(3, 12), function(h) { d <- rd(T2(h)); c(d$DM_RMSE_p, d$DM_MAE_p) })); d <- rd(T3(12)); d <- d[d$model %in% M, ]; sum(p < 0.10) == 0 & identical(d$model[d$sw_wealth_10bps > d$sw_wealth_bh], "pcr") }` |

### 8.4 Whitelisted label numbers (W rows) — allowed on slides, not data results

| ID | Numbers | Why allowed |
|---|---|---|
| W001 | 0 1 2 3 4 5 6 7 8 9 10 11 12 | slide numbers, h labels, RQ numbering, "weights ≥ 0, sum to 1", list counts |
| W002 | 14 20 | "14 signals/variables"; "20-year window" (240 months) |
| W003 | 1951 1966 1971 1999 2000 2011 2012 2014 2024 2025 | sample years, subperiod labels, citation years Neely et al. (2014), Goyal–Welch–Zafirov (2024) |
| W004 | 4308 | course code EC4308 (normally not tokenised because it follows letters) |
| W005 | 500 | index name "S&P 500" |

---

## 9. Verification (run from repo root before delivering)

### 9.1 Re-check every appendix number against the CSVs (R)

Paste into `Rscript -` (PowerShell: pipe a here-string) — do **not** save it as a repo file. Expected final line: `ALL NUMBER CHECKS PASSED (C=… R=… D=…)`.

```r
source("R/00_config.R")
rd <- function(f) read.csv(f, check.names = FALSE, stringsAsFactors = FALSE)
M  <- c("rlasso","postlasso","ridge","enet","pcr","pls","rf","equal_comb","gr_comb")
T2 <- function(h) sprintf("output/tables/table2_h%d.csv", h)
T3 <- function(h) sprintf("output/tables/table3_h%d.csv", h)
N5 <- "output/tables/table5_neely_replication.csv"
L  <- readLines("deck/SLIDE_SPEC.md", encoding = "UTF-8", warn = FALSE)
rows <- function(prefix) {
  x <- grep(paste0("^\\| ", prefix, "[0-9]{3} \\|"), L, value = TRUE)
  lapply(strsplit(x, " | ", fixed = TRUE),
         function(p) trimws(gsub("^\\|\\s*|\\s*\\|$|`", "", p)))
}
fail <- 0
bad <- function(id, msg) { fail <<- fail + 1; cat("FAIL", id, msg, "\n") }
C <- rows("C"); for (p in C) {
  d <- rd(p[7]); sel <- rep(TRUE, nrow(d))
  for (kv in strsplit(strsplit(p[8], "&", fixed = TRUE)[[1]], "=", fixed = TRUE))
    sel <- sel & as.character(d[[kv[1]]]) == kv[2]
  if (sum(sel) != 1) { bad(p[1], "row key not unique"); next }
  v <- round(as.numeric(d[sel, p[9]]) * as.numeric(p[6]), as.integer(p[5]))
  if (abs(v - as.numeric(p[4])) > 1e-9) bad(p[1], paste("csv", v, "spec", p[4]))
}
y <- rd("data/processed/panel.csv")$eq_prem
R <- rows("R"); for (p in R) {
  fc <- rd(p[6]); a <- y[fc$target_index]
  v <- round(100 * (1 - sum((a - fc[[p[7]]])^2) / sum((a - fc$pm)^2)), 2)
  if (abs(v - as.numeric(p[4])) > 1e-9) bad(p[1], paste("recomputed", v, "spec", p[4]))
}
D <- rows("D"); for (p in D) {
  ok <- tryCatch(isTRUE(all(eval(parse(text = p[5])))), error = function(e) FALSE)
  if (!ok) bad(p[1], p[3])
}
if (fail == 0) cat(sprintf("ALL NUMBER CHECKS PASSED (C=%d R=%d D=%d)\n", length(C), length(R), length(D))) else quit(status = 1)
```

### 9.2 Scan the built PPTX: only appendix numbers, no stale content, required numbers present (Python)

Run `python -` with this script after building. Expected last line: `PPTX CHECK PASSED`.

```python
import re, sys
from pptx import Presentation
from pptx.enum.shapes import MSO_SHAPE_TYPE

SPEC, DECK = "deck/SLIDE_SPEC.md", "deck/Group6_EC4308.pptx"
NUM = re.compile(r"(?<![\w.])[-\u2212]?\d+(?:\.\d+)?")
def nums(s):
    return {round(float(t.replace("\u2212", "-")), 6) for t in NUM.findall(s)}

spec = open(SPEC, encoding="utf-8").read().splitlines()
allowed, required = set(), []
for line in spec:
    m = re.match(r"^\| ([CRDW])(\d{3}) \| (.*)$", line)
    if not m:
        continue
    cells = [c.strip().strip("`") for c in line.strip().strip("|").split(" | ")]
    kind = m.group(1)
    if kind in "CR":
        val = round(float(cells[3]), 6); allowed.add(val)
        for sl in cells[1].split(","):
            required.append((cells[0], sl.strip(), val))
    elif kind == "D":
        allowed |= nums(cells[3])
    else:
        allowed |= nums(cells[1])

def texts(shapes):
    for sh in shapes:
        if sh.shape_type == MSO_SHAPE_TYPE.GROUP:
            yield from texts(sh.shapes)
        if getattr(sh, "has_text_frame", False) and sh.has_text_frame:
            yield sh.text_frame.text
        if getattr(sh, "has_table", False) and sh.has_table:
            for r in sh.table.rows:
                for c in r.cells:
                    yield c.text

prs = Presentation(DECK)
errs = []
if len(prs.slides) != 16: errs.append(f"expected 16 slides, got {len(prs.slides)}")
if abs(prs.slide_width / prs.slide_height - 16 / 9) > 0.01: errs.append("not 16:9")
label = {str(i): i for i in range(1, 11)}; label.update({f"B{i}": 11 + i for i in range(1, 6)})
STALE_NUM = {-15.49, 232.7, 341.9, -0.39, -2.07, -0.99, -5.3, 0.767, 0.776, 0.677, 0.105,
             0.193, 0.247, 0.077, 0.442, 4.403, 53.5, 59.7, 59.9, 60.1, -44.4, -50.2}
STALE_TXT = ["log premium", "log equity premium", "log excess return", "clark-west p",
             "clark\u2013west p", "cw test", "msfe-adjusted", "outperform", "winner",
             "lasso is the best", "post-lasso best"]
slide_nums = {}
for i, s in enumerate(prs.slides, start=1):
    body = "\n".join(texts(s.shapes))
    notes = s.notes_slide.notes_text_frame.text if s.has_notes_slide else ""
    found = nums(body); slide_nums[i] = found
    for v in sorted(found - allowed):
        errs.append(f"slide {i}: number {v} not in appendix")
    for v in found & STALE_NUM:
        errs.append(f"slide {i}: stale number {v}")
    low = (body + "\n" + notes).lower()
    for t in STALE_TXT:
        if t in low: errs.append(f"slide {i}: stale/forbidden phrase '{t}'")
    if i <= 10 and "speaker_scripts.md" not in notes:
        errs.append(f"slide {i}: notes lack pointer to deck/speaker_scripts.md")
for rid, sl, val in required:
    i = label.get(sl)
    if i and val not in slide_nums.get(i, set()):
        errs.append(f"{rid}: value {val} missing on slide {sl}")
print("\n".join(errs) if errs else "PPTX CHECK PASSED")
sys.exit(1 if errs else 0)
```

### 9.3 Word/bullet budget check (Python, optional but recommended)

For slides 2–10, count words in text frames excluding the title placeholder, the key-message line, tables, captions (11 pt or smaller) and footers. Must be ≤ ~40 (target 35) and ≤ 5 bullet paragraphs per text box. Fix by shortening wording, never by deleting a required number.

---

## 10. Acceptance checklist

- [ ] File is `deck/Group6_EC4308.pptx`; 16:9; 16 slides (1–10, Thank-you, B1–B5); no animations/transitions.
- [ ] Titles match §3 exactly; key-message line under each title matches §5 verbatim.
- [ ] Speakers/timings match §4 (total 9:45); speaker notes on 1–10 are pointers to `deck/speaker_scripts.md` headings, not scripts.
- [ ] Figures: figure2 on 6, figure1 on 8, figure3 on B1, figure4 on B3 — aspect locked, not cropped, not regenerated; captions as specified (figure1 caption states "chosen after the fact" and panel order h = 1, 12, 3).
- [ ] Slide 7 and slide 8 tables, slide 9 table, B2/B4/B5 tables contain exactly the values in §5.
- [ ] Every number visible on any slide appears in §8 (C/R/D/W) — §9.2 passes.
- [ ] §9.1 passes against the CSVs at `main`.
- [ ] No stale numbers/phrases from §7 (slides and notes) — §9.2 passes.
- [ ] Honesty: "not statistically significant"/"no significance test" stated on 7, 8, 9, 10; no "outperforms", no single "winner".
- [ ] ≤ 5 bullets and ~35 words body text on each main slide; no formulas; no lecture re-teaching; only rlasso and constrained GR get intuition (slide 5).
- [ ] Only citations: Goyal–Welch–Zafirov (2024), Neely et al. (2014).
- [ ] No other repo file modified; nothing committed unless the user asks.

---

## 11. Items intentionally NOT on slides (not traceable to a CSV/config cell)

| Item | Status |
|---|---|
| GR warm-up length (equal weights until enough OOS history) | Constant lives in `R/10_combine_forecasts.R`, not in a CSV/config → describe qualitatively only. |
| Number of forward validation blocks for ridge/enet/PCR/PLS | Lives in `R/08_models.R` → say "forward validation blocks" without a count. |
| h = 3 / h = 12 first OOS target dates | Not in a CSV → show only month counts (654, 636). |
| "Lag-1-only check: no significant difference vs 6 lags (DM p ≥ 0.28)" | One-off, not in repo CSVs → may be said in Q&A only, never on a slide. |
| $0 commission / sub-basis-point spread justification for 10 bps | Comment in `R/00_config.R` → speaker notes / Q&A only. |
| 60-month variance window for the mean-variance investor | `R/00_config.R` `VAR_WINDOW = 60` — allowed but intentionally omitted for low text; if added, add a D row first. |
