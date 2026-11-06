# EC4308 Group 6 — Speaker Script (10-minute talk)

Deck: `Group6_EC4308.pptx` (10 slides + backups B1–B5). Spoken text is in the
`>` quote blocks. Pace target: ~130 words per minute, so word budget = slide
time x 130. Speak to the room, glance at the slide, don't read it.

**Numbers rule:** every number below is traced to a cell in
`output/tables/*.csv`, `data/processed/expanded_variant_summary.csv` or
`R/00_config.R` (one exception, flagged in Q&A: the lag-1 quick check).
The rewritten report (commit `52ac2ab`) uses the same numbers; anything under
`legacy/` (old deck, review packets) is stale — do not take numbers from it.

## Run order

| Slide | Title | Speaker | Start | Duration | Budget (words) | Script (words) |
|---|---|---|---|---|---|---|
| 1 | Can Machine Learning Beat the Historical Average? | Vienna | 0:00 | 0:30 | 65 | 54 |
| 2 | Motivation & research questions | Vienna | 0:30 | 1:00 | 130 | 125 |
| 3 | Data & predictors | Leon | 1:30 | 1:00 | 130 | 126 |
| 4 | Forecasting design | En Shao | 2:30 | 1:00 | 130 | 128 |
| 5 | Models & combinations | En Shao | 3:30 | 1:00 | 130 | 129 |
| 6 | Statistical accuracy | Sasi | 4:30 | 1:15 | 163 | 140 |
| 7 | Is anything significant? | Sasi | 5:45 | 0:45 | 98 | 77 |
| 8 | Economic value: switching strategy | Sasi | 6:30 | 1:15 | 163 | 151 |
| 9 | Technical signals: replication + extension | Leon | 7:45 | 1:00 | 130 | 123 |
| 10 | Conclusion & takeaways | Vienna | 8:45 | 1:00 | 130 | 129 |
| | **Total** | | | **9:45** | **1,269** | **1,182** |

Leaves ~15 s buffer before the 10:00 mark, then 1–2 min Q&A.

**Handover lines (memorise these):**

- Vienna → Leon (end of slide 2): "Leon will start with the data."
- Leon → En Shao (end of slide 3): "En Shao will show you how we forecast with it."
- En Shao → Sasi (end of slide 5): "Sasi has the results."
- Sasi → Leon (end of slide 8): "Leon will take the technical signals."
- Leon → Vienna (end of slide 9): "Vienna will wrap up."

---

## Turn 1 — Vienna — Slides 1–2 — 0:00–1:30 (1:30, 179 words)

### Slide 1 — Title (0:30, 54 words)

> Hi everyone, we're Group 6. I'm Vienna, and with me are Leon, En Shao and
> Sasi. Our question is simple: can machine learning beat the most boring
> forecast there is, the historical average, when predicting the US equity
> premium? Short version: it's much harder than it sounds, and we'll show you
> exactly how hard.

- **Point at:** the title, then gesture to teammates as you name them.
- **Numbers:** "Group 6" — course slot (outline), not a result.

### Slide 2 — Motivation & research questions (1:00, 125 words)

> Why care? The equity premium is the extra return you get for holding
> stocks instead of T-bills. If you could forecast it even a little, you'd
> know when to be in the market and when to sit in cash. The catch is that
> many variables look predictive in-sample, then fall apart when you forecast
> in real time, and the plain historical average keeps winning. Machine
> learning might help, because it can handle many predictors and shrink away
> noise. So we asked three questions. One: does any model get a positive
> out-of-sample R-squared against the historical mean? Two: do technical
> trading signals add anything beyond macro variables? Three: even if the
> statistics are weak, could an investor actually make money? Leon will start
> with the data.

- **Point at:** the three numbered research questions as you say "one, two, three".
- **Numbers:** none (question numbering only).

---

## Turn 2 — Leon — Slide 3 — 1:30–2:30 (1:00, 126 words)

### Slide 3 — Data & predictors (1:00, 126 words)

> Our target is the monthly S&P 500 return, including dividends, minus the
> T-bill rate: a simple return in percent, not a log return. The sample runs
> from February 1951 to December 2025, so 899 months. Predictors come in two
> groups. First, 14 classic macro and valuation variables, like the
> dividend-price ratio, interest rates and inflation, each with six lags, so
> 84 columns. Second, 14 technical signals: on-off rules based on moving
> averages, momentum and volume. We built those ourselves, so we checked them
> against the published series: they match in 99.98 percent of months, just
> two mismatched months in total. As a robustness check we also add 8 newer
> predictors, which takes us to 146 columns. En Shao will show you how we
> forecast with it.

- **Point at:** the two predictor boxes (macro / technical); then the 99.98% validation badge.
- **Sources:**

| Said | Source |
|---|---|
| simple return in percent | `R/00_config.R`, `CONFIG$TARGET` comment ("simple monthly excess return in percentage points") |
| February 1951, December 2025 | `R/00_config.R`, `CONFIG$SAMPLE_START = "1951-02-01"`, `CONFIG$SAMPLE_END = "2025-12-01"` |
| 899 months | `output/tables/table1.csv`, row `A: target (full sample)`, col `N` |
| 14 macro variables | `R/00_config.R`, `CONFIG$MACRO_CLASSIC` (14 names) |
| six lags | `R/00_config.R`, `CONFIG$MAX_LAG = 6L` |
| 84 columns | 14 x 6 from the two config entries above |
| 14 technical signals | `R/00_config.R`, `CONFIG$TECHNICAL_NAMES` (14 names); also 14 rows of `output/tables/signal_validation.csv` |
| 99.98 percent | `output/tables/signal_validation.csv`: col `mismatches` sums to 2 over 14 signals x col `months_compared` 733 = 10,262 signal-months → 1 − 2/10,262 = 99.98% (equivalently the mean of col `match_pct`) |
| two mismatched months | same file, col `mismatches` = 1 in rows `MOM_12` (1968-03) and `VOL_2_9` (1980-04), 0 elsewhere |
| 8 newer predictors | `R/00_config.R`, `CONFIG$MACRO_EXPANDED` (8 names) |
| 146 columns | `data/processed/expanded_variant_summary.csv`, col `spec` = "expanded (146 cols)" |

---

## Turn 3 — En Shao — Slides 4–5 — 2:30–4:30 (2:00, 257 words)

### Slide 4 — Forecasting design (1:00, 128 words)

> Every month we pretend we're standing in real time. We train only on the
> most recent 240 months, a 20-year rolling window, and forecast the premium
> h months ahead, for h equal to 1, 3 and 12. That's one month's return, h
> months out, not a cumulative return. The first one-month forecast is for
> March 1971 and we run to December 2025, so 658 forecasts. The benchmark is
> the prevailing mean: the average of all past premiums. We score models by
> out-of-sample R-squared against it and a one-sided Diebold-Mariano test.
> Several choices came from the proposal feedback: benchmark switched from
> OLS to the prevailing mean, Clark-West replaced by Diebold-Mariano on
> squared and absolute errors, one lag became six, and we added a trading
> strategy and a forecast combination.

- **Point at:** the timeline diagram — the 240-month training block sliding forward, then the gap of h months to the target; then the "what changed after feedback" box.
- **Sources:**

| Said | Source |
|---|---|
| 240 months / 20-year | `R/00_config.R`, `W_ROLLING = 240L` (comment: "20-year fixed rolling window") |
| h = 1, 3, 12 | `R/00_config.R`, `HORIZONS = c(1L, 3L, 12L)` |
| March 1971 | `output/tables/table_subperiods_h1.csv`, row `1971-1999`, col `first_target` = 1971-03-01 |
| December 2025 | `output/tables/table_subperiods_h1.csv`, row `2012-2025`, col `last_target` = 2025-12-01 |
| 658 forecasts | `output/tables/table1.csv`, row `A: target (OOS)`, col `N` |
| one lag → six | `R/00_config.R`, `CONFIG$MAX_LAG = 6L` |

### Slide 5 — Models & combinations (1:00, 129 words)

> We run seven models. Most you know from class: ridge, elastic net, PCR,
> PLS, random forest, plus two LASSO variants. The lecture models are tuned
> on forward-in-time blocks inside each window, so nothing peeks ahead. Two
> things weren't covered in class. First, rlasso. Normal LASSO picks its
> penalty by cross-validation, which is noisy when the signal is this weak.
> rlasso sets the penalty from theory instead: just high enough that pure
> noise predictors almost never get in, with no cross-validation.
> Post-LASSO then re-fits OLS on the survivors to undo the shrinkage. Second,
> the Granger-Ramanathan combination. Instead of averaging models equally, we
> ask which mix of forecasts had the smallest errors so far. Weights can't be
> negative, must sum to one, and only use past errors. Sasi has the results.

- **Point at:** the seven-model list (one sweep, don't stop on each); then the rlasso box ("penalty from theory, no CV"); then the GR box ("weights ≥ 0, sum to 1, past errors only").
- **Sources:**

| Said | Source |
|---|---|
| seven models | 7 non-combination model rows (`rlasso` … `rf`) in `output/tables/table2_h1.csv` |
| sum to one | definition of the constraint, not a result |

Delivery note: the rlasso + GR intuition is the ~1 minute the prof asked for
on non-lecture methods; spend ~25 s on each and keep the lecture models to the
one-sentence list. If asked: GR uses equal weights until enough past forecast
errors exist (see B1).

---

## Turn 4 — Sasi — Slides 6–8 — 4:30–7:45 (3:15, 368 words)

### Slide 6 — Statistical accuracy (1:15, 140 words)

> Here's the headline. Each bar is out-of-sample R-squared against the
> prevailing mean, so above zero means beating the historical average. At
> one month, ridge is the only model above zero, at 0.12 percent. At three
> months, ridge again, at 0.30 percent. At twelve months nothing is positive;
> the best is the equal-weight combination at minus 0.48. Everything else
> sits between about minus 0.1 and minus 2.8 percent. The long bars are
> random forest: minus 15.5, minus 12.3 and minus 10.5 percent. With only 240
> months of training data and a very noisy target, the forest fits noise and
> its forecasts swing far too much. The combinations don't rescue things
> either: Granger-Ramanathan is minus 0.54 at one month. So for question one,
> the best we get is barely positive, and only for ridge. Is even that real?
> That's the next slide.

- **Point at:** the zero line first; the tiny ridge bars above zero in the h=1 and h=3 panels; the long random-forest bars; the GR bar in the h=1 panel. (Figure `output/figures/figure2_r2oos.png`, per `R/13_figures.R`: bars of R²_OOS vs PM for 9 models, one panel per horizon, models ordered rlasso, postlasso, ridge, enet, pcr, pls, rf, equal_comb, gr_comb — RF is 7th, not last.)
- **Sources:**

| Said | Source |
|---|---|
| 0.12 percent (ridge, h=1) | `output/tables/table2_h1.csv`, row `ridge`, col `R2_OOS_pct` = 0.12 |
| 0.30 percent (ridge, h=3) | `output/tables/table2_h3.csv`, row `ridge`, col `R2_OOS_pct` = 0.298 |
| minus 0.48 (equal comb, h=12) | `output/tables/table2_h12.csv`, row `equal_comb`, col `R2_OOS_pct` = -0.481 |
| about minus 0.1 | `output/tables/table2_h3.csv`, row `equal_comb`, col `R2_OOS_pct` = -0.141 |
| minus 2.8 | `output/tables/table2_h1.csv`, row `postlasso`, col `R2_OOS_pct` = -2.827 |
| minus 15.5 / 12.3 / 10.5 (RF) | `table2_h1.csv` / `table2_h3.csv` / `table2_h12.csv`, row `rf`, col `R2_OOS_pct` = -15.532 / -12.33 / -10.468 |
| 240 months | `R/00_config.R`, `W_ROLLING = 240L` |
| minus 0.54 (GR, h=1) | `output/tables/table2_h1.csv`, row `gr_comb`, col `R2_OOS_pct` = -0.535 |

("Everything else" = all non-RF entries other than ridge h=1/h=3: range across the three table2 files is -0.141 to -2.827.)

### Slide 7 — Is anything significant? (0:45, 77 words)

> Short answer: no. These are one-sided Diebold-Mariano p-values, where small
> means the model beats the prevailing mean. Across nine models, three
> horizons and both squared and absolute errors, the smallest p-value is
> 0.23, for ridge at one month on absolute errors. Ridge's positive R-squared
> at one month has a p-value of 0.45. At twelve months, every p-value is
> above 0.8. So nothing significantly beats the historical average, anywhere.
> But statistics aren't money, so let's check the economics.

- **Point at:** the p-value table; circle the smallest cell (ridge, h=1, MAE column); then sweep the h=12 column.
- **Sources:**

| Said | Source |
|---|---|
| nine models | 9 model rows in each `output/tables/table2_h*.csv` |
| 0.23 | `output/tables/table2_h1.csv`, row `ridge`, col `DM_MAE_p` = 0.2328 (minimum over `DM_RMSE_p` and `DM_MAE_p` in all three table2 files) |
| 0.45 | `output/tables/table2_h1.csv`, row `ridge`, col `DM_RMSE_p` = 0.451 |
| above 0.8 at h=12 | `output/tables/table2_h12.csv`: min `DM_RMSE_p` = 0.8139 (`equal_comb`), min `DM_MAE_p` = 0.853 (`equal_comb`) |

### Slide 8 — Economic value: switching strategy (1:15, 151 words)

> The rule is simple: if the forecast is positive, hold the S&P 500;
> otherwise hold T-bills. We charge 10 basis points on every switch,
> including the first entry. The prevailing mean is always positive, so it's
> just buy-and-hold: this line, ending at about 342 dollars per dollar
> invested. Ridge, the model with the best R-squared, ends near 499 dollars,
> with a Sharpe ratio of 0.57 versus 0.49 and a smaller worst drawdown, 44
> percent versus 50. At 20 basis points it still ends at 482. The
> Granger-Ramanathan combination ends at 421. But be careful. Ridge was
> picked after the fact, and none of this has a significance test. At one
> month, four of the nine models end below buy-and-hold, random forest at 93
> dollars. At twelve months, the best-R-squared model ends at 193 against 265
> for buy-and-hold. So the one-month gains are suggestive, not proven. Leon
> will take the technical signals.

- **Point at:** `output/figures/figure1_wealth.png` (per `R/13_figures.R`: cumulative wealth per $1 net of 10 bps; three panels h=1/3/12; lines = buy-and-hold, Prevailing Mean, and "Switching (best-R²_OOS model)", chosen retrospectively). In the h=1 panel: end of the buy-and-hold/PM line (they overlap), then end of "Switching (ridge)"; then the h=12 panel where "Switching (equal_comb)" ends below buy-and-hold.
- **Sources:**

| Said | Source |
|---|---|
| 10 basis points | `R/00_config.R`, `FEE_BPS = 10` |
| PM = buy-and-hold | `output/tables/table3_h1.csv`, row `Prevailing Mean`: `sw_switches` = 1, `sw_eq_exposure` = 1, `sw_wealth_10bps` = 341.588, same as row `Buy-and-Hold` |
| about 342 | `output/tables/table3_h1.csv`, row `Buy-and-Hold`, col `sw_wealth_10bps` = 341.587892989 |
| 499 | `output/tables/table3_h1.csv`, row `ridge`, col `sw_wealth_10bps` = 499.356 |
| Sharpe 0.57 vs 0.49 | `output/tables/table3_h1.csv`, col `sw_sharpe_10bps`: row `ridge` = 0.569, row `Buy-and-Hold` = 0.494 |
| drawdown 44% vs 50% | `output/tables/table3_h1.csv`, col `sw_maxdd_10bps`: row `ridge` = -0.4443, row `Buy-and-Hold` = -0.5022 |
| 20 basis points → 482 | `R/00_config.R`, `FEE_SENSITIVITY = c(5, 20)`; `table3_h1.csv`, row `ridge`, col `sw_wealth_20bps` = 482.263 |
| 421 (GR) | `output/tables/table3_h1.csv`, row `gr_comb`, col `sw_wealth_10bps` = 421.299 |
| four of nine below buy-and-hold | `table3_h1.csv`, col `sw_wealth_10bps` < 341.588 for `rlasso` 257.776, `postlasso` 242.671, `pcr` 330.376, `rf` 92.58 |
| 93 (RF) | `output/tables/table3_h1.csv`, row `rf`, col `sw_wealth_10bps` = 92.58 |
| 193 vs 265 (h=12) | `output/tables/table3_h12.csv`, col `sw_wealth_10bps`: row `equal_comb` = 193.269, row `Buy-and-Hold` = 264.754383269255 (`equal_comb` has the best h=12 R²_OOS, `table2_h12.csv` -0.481) |

---

## Turn 5 — Leon — Slide 9 — 7:45–8:45 (1:00, 123 words)

### Slide 9 — Technical signals: replication + extension, and mean-variance (1:00, 123 words)

> Back to question two. First, we replicated the classic exercise: each of
> the 14 signals on its own, over 1966 to 2011. Ten of the 14 give a positive
> R-squared, up to about 0.6 percent, but with our Diebold-Mariano test none
> is significant; the smallest p-value is 0.20. Then we extended to 2012
> through 2025: all 14 turn negative, as low as minus 2.5 percent. So
> whatever edge the signals had has faded. Last, the mean-variance investor
> with risk aversion of 3. At one month, ridge gives a utility gain of 1.92
> percent a year over the prevailing mean, and Granger-Ramanathan 1.18. But
> at twelve months, eight of the nine models lose utility, and again there's
> no significance test. Vienna will wrap up.

- **Point at:** table5 — the 1966–2011 block (mostly small positives), then the 2012–2025 block (all negative); then the ΔU summary: h=1 ridge and GR, then the h=12 row.
- **Sources:**

| Said | Source |
|---|---|
| 14 signals | 14 rows per `sample` in `output/tables/table5_neely_replication.csv` |
| 1966 to 2011 | `table5_neely_replication.csv`, col `sample` = "Neely sample 1966-2011" |
| ten of 14 positive | same file and sample: `R2_OOS_pct` > 0 for MA_1_9, MA_1_12, MA_2_9, MA_2_12, MA_3_9, VOL_1_9, VOL_1_12, VOL_2_9, VOL_2_12, VOL_3_12 (10); negative for MA_3_12, MOM_9, MOM_12, VOL_3_9 |
| about 0.6 percent | same sample, row `VOL_1_12`, col `R2_OOS_pct` = 0.591 |
| smallest p 0.20 | same sample, row `VOL_3_12`, col `DM_RMSE_p` = 0.196 |
| 2012 through 2025, all 14 negative | sample "Extension 2012-2025": all 14 `R2_OOS_pct` < 0 (highest -0.274, `VOL_3_9`) |
| minus 2.5 | sample "Extension 2012-2025", row `VOL_1_12`, col `R2_OOS_pct` = -2.535 |
| risk aversion 3 | `R/00_config.R`, `GAMMA = 3` |
| 1.92 (ridge, h=1) | `output/tables/table3_h1.csv`, row `ridge`, col `mv_deltaU_10bps_pct` = 1.92 |
| 1.18 (GR, h=1) | `output/tables/table3_h1.csv`, row `gr_comb`, col `mv_deltaU_10bps_pct` = 1.18 |
| eight of nine lose at h=12 | `output/tables/table3_h12.csv`, col `mv_deltaU_10bps_pct` < 0 for every model except `rf` (0.56) |

---

## Turn 6 — Vienna — Slide 10 — 8:45–9:45 (1:00, 129 words)

### Slide 10 — Conclusion & takeaways (1:00, 129 words)

> So, our three answers. One: no model significantly beats the historical
> average at any horizon. Ridge is slightly positive at one and three
> months, but nowhere near significant. Two: technical signals looked mildly
> useful up to 2011, not since 2012, and they don't rescue the machine
> learning models. Three: at one month, some strategies ended with more
> wealth and higher utility than buy-and-hold, but those are point estimates
> with no significance test, and with nine models and three horizons, some
> winners will show up by luck. Limitations: one window length, one
> market, and no test on the economic gains. The takeaway: a 20-year window
> and a hundred-odd predictors aren't enough to reliably beat a simple
> average, and saying so honestly is the result. Thanks, we're happy to take
> questions.

- **Point at:** the three answer boxes in turn (RQ1, RQ2, RQ3), then the limitations line.
- **Sources:**

| Said | Source |
|---|---|
| 2011 / 2012 | `output/tables/table5_neely_replication.csv`, col `sample` labels |
| nine models, three horizons | 9 model rows in `table2_h*.csv`; `R/00_config.R` `HORIZONS` |
| 20-year window | `R/00_config.R`, `W_ROLLING = 240L` comment |
| a hundred-odd predictors | deliberately rounded: 98 baseline (14 x 6 + 14, from config) and 146 expanded (`expanded_variant_summary.csv` `spec`) |

---

## Q&A prep (1–2 min; answer in 2–3 sentences, then stop)

| # | Likely question | Concise answer | Answerer (role) | Show |
|---|---|---|---|---|
| 1 | Why the prevailing mean as benchmark, not OLS? | It's the forecast anyone can make with zero model risk, and R²_OOS is defined against it; the prof's proposal feedback moved us from OLS to it. Beating it is the real bar, and nothing does significantly (smallest DM p 0.23: `table2_h1.csv`, `ridge`, `DM_MAE_p`). | Sasi (evaluation) | Slide 7 |
| 2 | Why a 240-month window? | It's 20 years (`R/00_config.R` `W_ROLLING`, set per the prof's rolling-window directive): long enough to estimate many coefficients, short enough to adapt. We fixed it up front instead of tuning it on the test period; other lengths are an untested limitation. Performance also worsens recently: rlasso h=1 R²_OOS -0.63 (1971–1999), -1.20 (2000–2011), -1.94 (2012–2025) (`table_subperiods_h1.csv`, col `R2`). | En Shao (models) | B3 |
| 3 | Why simple, not log, returns? | The investor earns simple returns, and both the switching wealth and the mean-variance utility are computed on them, so the target matches what we evaluate (`R/00_config.R`, `CONFIG$TARGET` comment). | Leon (data) | Slide 3 |
| 4 | Why is random forest so bad? | Noisy monthly target, only 240 training months and about a hundred predictors: the trees fit noise and forecasts jump around. At h=1 its R²_OOS is -15.53 and in switching it trades 167 times, ending at 92.58 (`table2_h1.csv` `rf` `R2_OOS_pct`; `table3_h1.csv` `rf` `sw_switches`, `sw_wealth_10bps`). | En Shao (models) | B5 / Slide 6 |
| 5 | Are the economic gains significant? | We didn't test them, so they're point estimates. Ridge was picked after seeing R², and with 9 models x 3 horizons some will look good by chance. Example: RF has the worst h=3 R² (-12.33) yet the highest h=3 ΔU, 2.21 (`table2_h3.csv` / `table3_h3.csv`, row `rf`, `mv_deltaU_10bps_pct`). | Sasi (evaluation) | Slide 8 |
| 6 | Why only 8 extra predictors? | Only these 8 have complete monthly data from 1950-08 to 2025-12 without a full-sample-construction warning; others like fbm and ogap are built with future data, i.e. look-ahead (`R/00_config.R`, comment above `MACRO_EXPANDED`). They don't change the story: h=1 ridge 0.029, rf -13.117; a few h=3 positives (ridge 0.847, pls 0.629) with no DM test in that summary; h=12 all negative (`data/processed/expanded_variant_summary.csv`). | Leon (data) | B4 |
| 7 | Why 10 bps transaction costs? | Brokers charge $0 online commission and a one-cent spread on SPY is ~0.14 bps, so 10 bps is conservative (`R/00_config.R`, `FEE_BPS` comment). Results barely move: ridge h=1 ends at 508.122 / 499.356 / 482.263 at 5 / 10 / 20 bps (`table3_h1.csv`, row `ridge`). | Sasi (evaluation) | Slide 8 |
| 8 | Why not Clark-West? | Course feedback. DM asks directly whether our forecasts have lower squared or absolute errors, which is what a user of the forecast cares about. Clark-West adjusts for estimation noise in nested models and rejects more easily, which is likely why published technical-signal results look significant while our DM p-values don't (smallest 0.196 in 1966–2011: `table5_neely_replication.csv`, `VOL_3_12`). | Sasi (evaluation) | Slide 9 |
| 9 | Did six lags actually help? | A quick check re-ran h=1 with lag 1 only (28 predictors): no significant difference from six lags, DM p ≥ 0.28. **Not in the repo CSVs: say "a quick check", give no other numbers.** | En Shao (models) | — |
| 10 | Do technical signals help inside the ML models? | Mixed, not consistent. At h=1 ridge R²_OOS is 0.12 with all predictors, 0.17 macro-only, -1.06 technical-only; rlasso is -1.06 / -1.03 / -0.84 (`output/tables/tableA1_tex.tex`, verified against `data/processed/forecasts_h1_macro.csv` / `forecasts_h1_tech.csv`). Each signal alone at h=1 is negative (`table4_h1.csv`, all `R2_OOS_pct` < 0). | Leon (data) | B2 |

Also ready: "Which models get weight in the GR combination?" → show B1
(`figure3_gr_weights.png`: stacked non-negative GR weights over time at h=1,
from past OOS errors); describe qualitatively, no numbers.

---

## Rehearsal tips (from the prof's email)

- **Talk, don't read.** Learn each slide's one message and its 2–3 numbers;
  the slide carries the rest. Glance at the point-at cue, then face the room.
- **Hit the clock at ~130 words/min.** Do a timed run; each turn should land
  within ±5 s (Vienna 1:30, Leon 1:00, En Shao 2:00, Sasi 3:15, Leon 1:00,
  Vienna 1:00). If over, cut sentences, don't speed up.
- **No lecture re-teaching.** One clause max for ridge/PCR/PLS/RF/DM/rolling
  windows; En Shao's ~50 s on rlasso and GR is the only methods teaching.
  Skip author names beyond what's on the slide.
- **Honest wording.** Never say "outperforms" without "not significantly";
  say "point estimate, no significance test" for wealth and ΔU; don't crown
  a winner. Practise the handover lines so turns flow without pauses.
