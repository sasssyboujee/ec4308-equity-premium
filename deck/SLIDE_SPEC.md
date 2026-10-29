# EC4308 — Slide-by-Slide Content & Design Specification

> The authoritative, exhaustive spec for the 10-minute presentation deck.
> Every slide: exact copy, figures, numbers (with the CSV they come from),
> layout, and design treatment. Pair with `deck/speaker_scripts.md`
> (spoken lines) and regenerate with `python3 deck/make_deck.py`.
> Current build: `deck/EC4308_Presentation.pptx` (10 slides, speaker notes embedded).

---

## 0. Global design system

**Canvas:** 16:9 — 13.333 in × 7.5 in (matches the built deck).

**Color palette (design tokens):**
| Token | Hex | Use |
|---|---|---|
| Navy | `#1F365C` | slide titles, primary bars, big numbers |
| Accent (burnt orange) | `#C0502D` | the ONE takeaway per slide, emphasis |
| Grey | `#606060` | subtitles, captions, secondary text |
| Panel grey | `#F2F2F2` | callout boxes behind numbers |
| White | `#FFFFFF` | background |

**Typography:** Calibri or Arial. Title 28–30 pt bold navy. Body bullets
16–18 pt dark grey. **Display numbers 36–48 pt bold** (navy for facts, orange
for the headline number). Figure captions 11–12 pt grey.

**Layout grid:** title zone y=0.25–1.30 in (title + one-line subtitle);
content zone y=1.40–7.10 in; thin footer (slide number + "EC4308 — Group
Project") optional. Default split: **figure left (~6.2 in wide), bullets
right (~5.9 in)**; for text-only slides use full width.

**Design principles (hard rules):**
1. One message per slide; the headline number is the largest thing on it.
2. Max 4 bullets; max ~12 words per bullet. Numbers outrank adjectives.
3. Every figure gets a one-line caption saying what it IS (self-contained,
   per Prof. Denis's rubric).
4. Consistent verb: claim first, evidence number second.
5. Nothing decorative: every number on a slide must exist in
   `output/tables/*.csv` (see the audit's claim→evidence map in
   `review/AUDIT_REPORT.md`).

---

## 1. Title slide — speaker: Vienna, ~0:20 (no figure)

**Layout:** centered text block at y≈2.0–4.5 in, full width, navy on white.
**Copy:**
- Title (32 pt bold navy): "Forecasting the Equity Risk Premium Out-of-Sample: Regularized ML, Technical Indicators & Tactical Asset Allocation"
- Subtitle (18 pt accent): "EC4308 Machine Learning and Economic Forecasting — Group Project (Week 13)"
- Names (18 pt grey): "Leon • En Shao • Sasinthiran Kannan • Vienna"

**Design note:** no numbers, no logos, no animation. The title alone.

---

## 2. Motivation — speaker: Vienna, ~1:00 (no figure)

**Layout:** full-width bullets; no image.
**Bullets:**
1. "The equity premium — how much stocks beat cash — is the key input for portfolio choice."
2. "Goyal & Welch: essentially no macro fundamental beats the prevailing mean out-of-sample; Goyal–Welch–Zafirov (2024) reach the same conclusion with an expanded dataset of 57 monthly series."
3. "Neely et al. (2014): 14 technical indicators (MA, MOM, OBV) DO predict the premium out-of-sample on 1966–2011."
4. "Our question: with modern regularized ML, do technical indicators + macro lags beat the prevailing mean on the extended 1951–2025 sample?"

**Design note:** highlight the last bullet in accent; no figures — this slide
sets the puzzle.

---

## 3. Data — speaker: Leon, ~1:15 (no figure)

**Layout:** full-width bullets; consider 2×2 mini number callouts at bottom.
**Bullets:**
1. "Target: monthly log equity premium (%), S&P 500 over the risk-free rate."
2. "Predictors: 14 Goyal–Welch macro variables × 6 lags (84 columns) + 14 Neely binary technical signals."
3. "Sample: Feb 1951 → Dec 2025 = 899 months; strict no-lookahead alignment."
4. "Validation: our signals match the published Neely series in 99.98% of signal-months (12/14 exact)."
5. "Fixed 240-month rolling window; first OOS forecast Feb 1971 → 659 OOS months at h=1."

**Numbers to display (callouts):** `899` months · `98` predictors ·
`99.98%` match · `659` OOS months (h=1) · `1951–2025`.
**Sources:** panel dims `data/processed/panel.csv`; match
`output/tables/signal_validation.csv`; OOS counts `output/tables/table2_h*.csv`.

---

## 4. Methods — speaker: En Shao, ~1:30 (no figure)

**Layout:** full-width bullets with a compact method-list block.
**Bullets:**
1. "Benchmark: the prevailing (historical) mean — the only admissible benchmark."
2. "Models (re-estimated every window): LASSO (hdm, theoretical penalty — no CV) & post-LASSO · Ridge & Elastic Net (10-fold CV inside the window) · PCR & PLS (CV-selected components) · Random Forest (500 trees, fixed seed)."
3. "Combinations: equal-weight 1/N and constrained Granger–Ramanathan (Σw=1, w≥0, weights from past OOS errors only)."
4. "Horizons h ∈ {1,3,12}; Diebold–Mariano tests (HAC lag h−1); Clark–West appendix check; costs 5/10/20 bps."

**Design note:** render the model list as a grey panel; stress "no lookahead"
in accent. No figures.

---

## 5. Replication (credibility check) — speaker: Sasi, ~1:15 (no figure)

**Layout:** full-width; a small 2-column mini-table (panel style) for the numbers.
**Copy:**
- "Expanding-window bivariate regressions, one signal at a time — Neely et al.'s exact design."

**Mini-table (navy header, white rows):**

| Signal | 1966–2011 R²_OOS | CW p | 2012–2025 R²_OOS | CW p |
|---|---|---|---|---|
| VOL(2,9) | **+0.36%** | 0.017 | −6.92% | 0.892 |
| VOL(2,12) | **+0.66%** | 0.015 | −4.67% | 0.702 |
| VOL(3,12) | **+0.76%** | 0.029 | −1.28% | 0.429 |

- "Published VOL(2,12): +0.33% — same sign, significance and order of magnitude."
- "Takeaway: our pipeline finds predictability where the literature found it — and it vanishes after 2012."

**Source:** `output/tables/table5_neely_replication.csv`.

---

## 6. Result 1 — statistical accuracy — speaker: Sasi, ~1:15 (figure)

**Layout:** figure left (6.4 in wide), bullets right.
**Figure:** `output/figures/figure2_r2oos.png` (bar chart, R²_OOS by model ×
horizon). Caption: "Out-of-sample R² (%) vs the prevailing mean — negative =
worse than the benchmark."

**Bullets:**
1. "No model beats the prevailing mean at any horizon — the Goyal–Welch result with modern ML."
2. "Best: LASSO R²_OOS = −8.8% (h=1); GR combination −10.0%."
3. "Worst: PLS −40.6%, Random Forest −48.4% (h=1)."
4. "Hit rates 53–58% vs the benchmark's 60% — direction is hard too."

**Numbers to display (big):** **−8.8%** (LASSO h=1, accent) · PM RMSE 4.399 ·
stable across horizons: h=3 −8.2%, h=12 −11.5%.
**Source:** `output/tables/table2_h1.csv`, `table2_h3.csv`, `table2_h12.csv`
(columns R2_OOS_pct, RMSE, HR, HR_pm).

---

## 7. Result 2 — economic value — speaker: Sasi, ~1:15 (figure)

**Layout:** figure left (7.2 in wide), bullets right.
**Figure:** `output/figures/figure1_wealth.png` (wealth paths: best switching
model, prevailing mean, buy-and-hold, by horizon). Caption: "Cumulative wealth
per $1, net of 10 bps costs."

**Bullets:**
1. "Switching (post-LASSO, 10 bps): max drawdown −23.4% vs buy-and-hold −50.2% at Sharpe 0.767 vs 0.777."
2. "Terminal wealth $67.7 vs $346.5 — the cost of dodging bear markets in a bull-dominated sample."
3. "Mean-variance investor (γ=3): ΔU = +1.31% p.a. (post-LASSO), +1.22% (LASSO), +1.06% (GR), +0.73% (equal), net of costs."
4. "Forecasts earn their keep as risk-management signals."

**Numbers to display (big):** **−50% → −23%** drawdown (accent) · **+1.3% p.a.**
net utility gain.
**Source:** `output/tables/table3_h1.csv` (sw_maxdd_10bps, sw_wealth_10bps,
sw_sharpe_10bps, mv_deltaU_10bps_pct; Buy-and-Hold / Prevailing Mean rows).

---

## 8. Why predictability decayed — speaker: Vienna, ~1:00 (figure)

**Layout:** figure left (6.2 in wide), bullets right.
**Figure:** `output/figures/figure4_subperiods.png` (LASSO R²_OOS by subperiod
bar chart). Caption: "LASSO out-of-sample R² by subperiod — closest to the
benchmark in the crisis decade."

**Bullets:**
1. "The signals earn their keep in crisis months: 2000–02 and 2008–09."
2. "Subperiods (LASSO, h=1): −10.5% (1971–99) → −1.2% (2000–11) → −13.4% (2012–25)."
3. "GR combination: −10.9% → −1.9% → −17.5%."
4. "Passive flows and faster arbitrage of published signals likely killed it."
5. "Macro-only LASSO is closest to the benchmark (−0.9%) — joint fits dilute the signal."

**Source:** subperiod R² recomputed from `data/processed/forecasts_h1.csv` +
`panel.csv`; macro-only from `data/processed/forecasts_h1_macro.csv` (also
`output/tables/tableA1_tex.tex`).

---

## 9. Conclusion — speaker: Vienna, ~0:45 (no figure)

**Bullets:**
1. "We replicate Neely et al. (2014) faithfully — their 1966–2011 result survives; our signals match theirs 99.98%."
2. "Extended to 2025, no model — regularized, tree-based, or combined — beats the prevailing mean."
3. "Economic value persists: drawdown halved (−50% → −23%); MV gains +1.2–1.3% p.a. net of costs."
4. "Lesson: honest evaluation, disciplined windows and costs matter more than model complexity."

**Design note:** the three findings as three numbered statements; final line in accent.

---

## 10. Q&A — all four, ~2:00 (no figure)

**Layout:** centered "Thank you — questions?" (40 pt navy).
**Q&A prep by owner (also in `speaker_scripts.md`):**
- **En Shao:** why CV inside the window is leakage-free; the GR constraint.
- **Sasi:** DM vs CW; the h>1 switching timing; fee assumptions.
- **Leon:** the volume splice (paper 1950–2011 + Yahoo 2012–2025); the two mismatching signal-months.
- **Vienna:** interpretation — negative results are results; the macro-only variant.

---

## Number appendix — every on-slide number and its source

| Number | Value | Source file (column) |
|---|---|---|
| Sample months | 899 (1951-02 → 2025-12) | `data/processed/panel.csv` |
| Predictors | 98 = 84 macro lags + 14 signals | `data/processed/codebook.csv` |
| Signal match | 99.9805% | `output/tables/signal_validation.csv` |
| OOS months | 659 / 657 / 648 (h=1/3/12) | `output/tables/table2_h{1,3,12}.csv` (n rows) |
| PM RMSE (h=1) | 4.399 | `table2_h1.csv` (RMSE_pm) |
| LASSO R²_OOS | −8.8% / −8.2% / −11.5% | `table2_h{1,3,12}.csv` (R2_OOS_pct) |
| GR R²_OOS (h=1) | −10.0% | `table2_h1.csv` |
| PLS / RF R²_OOS (h=1) | −40.6% / −48.4% | `table2_h1.csv` |
| Hit rates | 53–58% models vs 60% PM | `table2_h*.csv` (HR, HR_pm) |
| Neely replication | +0.36/+0.66/+0.76%, p 0.017/0.015/0.029 | `table5_neely_replication.csv` |
| Published VOL(2,12) | +0.33% | Neely et al. (2014), Table II |
| Extension 2012–2025 | all negative, e.g. VOL(3,12) −1.28% (p 0.429) | `table5_neely_replication.csv` |
| Drawdown | −50.2% (BH) → −23.4% (post-LASSO) | `table3_h1.csv` (sw_maxdd_10bps) |
| Terminal wealth | $67.7 vs $346.5 | `table3_h1.csv` (sw_wealth_10bps) |
| Sharpe | 0.767 vs 0.777 | `table3_h1.csv` (sw_sharpe_10bps) |
| MV ΔU (10 bps) | +1.31 / +1.22 / +1.06 / +0.73% p.a. | `table3_h1.csv` (mv_deltaU_10bps_pct) |
| Subperiods (LASSO h=1) | −10.5% / −1.2% / −13.4% | recomputed: `forecasts_h1.csv` + `panel.csv` |
| Subperiods (GR h=1) | −10.9% / −1.9% / −17.5% | same |
| Macro-only LASSO | −0.9% | `forecasts_h1_macro.csv` (Appendix A1) |

**Build/rebuild:** edit `deck/make_deck.py` for layout/text, then
`python3 deck/make_deck.py` → `deck/EC4308_Presentation.pptx`. Figures
regenerate with `Rscript R/13_figures.R`. All numbers auto-pulled from the
CSVs — edit the CSVs' source (the R pipeline), never hand-edit slide numbers.
