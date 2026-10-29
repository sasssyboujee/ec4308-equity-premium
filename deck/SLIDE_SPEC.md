# EC4308 — SLIDE BUILD BRIEF (for the agent building the presentation)

> **Who you are:** an agent building a 10-minute presentation deck for an NUS
> EC4308 group project. **Your inputs:** (1) this markdown, (2) the GitHub
> repo `sasssyboujee/ec4308-equity-premium` (clone it: all numbers and figures
> live there). **Your job:** produce a 10-slide PPTX that follows this brief
> exactly — every word and number below is final; do not invent or change
> numbers. If anything is unclear or a figure is missing, STOP and report
> rather than guessing.
>
> **Reference implementation already exists:** `deck/EC4308_Presentation.pptx`
> (built by `deck/make_deck.py` from the same CSVs). Use it as the visual
> baseline; this brief is the contract it satisfies. If you rebuild from
> scratch, the result must be content-identical to the slides specified here.

---

## 1. Mission

Build a 10-slide, 16:9 deck for a **10-minute live talk** where **all four
group members speak**. Slides must be self-contained (a viewer understands
each figure from its caption), visually minimal, and numerically exact — every
number on every slide must match the "Number appendix" (§8), which is sourced
from `output/tables/*.csv` in the repo.

**Acceptance criteria (verify before delivering):**
- [ ] Exactly 10 slides, 16:9 (13.333 × 7.5 in).
- [ ] Every slide has speaker notes (text given per slide in §4).
- [ ] Every number on every slide equals the appendix value.
- [ ] The 3 figures specified in §4 are embedded and non-blank.
- [ ] File opens in PowerPoint/Keynote; notes survive export.
- [ ] No invented numbers, no extra slides, no watermarking, no animations
      required (static is fine and preferred).

## 2. Where every fact comes from (repo paths)

Clone: `git clone https://github.com/sasssyboujee/ec4308-equity-premium.git`

| Asset | Path in repo |
|---|---|
| All result tables (numbers) | `output/tables/table1.csv`, `table2_h1.csv`, `table2_h3.csv`, `table2_h12.csv`, `table3_h1.csv`, `table3_h3.csv`, `table3_h12.csv`, `table4_h1.csv`, `table5_neely_replication.csv`, `signal_validation.csv` |
| Figures | `output/figures/figure1_wealth.png`, `figure2_r2oos.png`, `figure3_gr_weights.png`, `figure4_subperiods.png` |
| Panel (row counts) | `data/processed/panel.csv` (899 rows; `eq_prem` column) |
| Forecasts | `data/processed/forecasts_h{1,3,12}.csv` (columns `rlasso`, `gr_comb`, `pls`, `rf`, `pm`, …) |
| Variant forecasts | `data/processed/forecasts_h1_tech.csv`, `forecasts_h1_macro.csv` |
| Written report (for any wording) | `report/main.pdf` |
| Spoken lines (full scripts) | `deck/speaker_scripts.md` |
| Existing deck (visual baseline) | `deck/EC4308_Presentation.pptx`, generator `deck/make_deck.py` |

**Re-verification command** — run this in the repo and diff against §8
(R 4.6.1, no packages beyond base + readxl):

```bash
Rscript -e 'suppressMessages(library(readxl)); source("R/00_config.R")
panel <- read.csv("data/processed/panel.csv"); y <- panel$eq_prem
cat("panel rows:", nrow(panel), "\n")
t2 <- read.csv("output/tables/table2_h1.csv")
cat("PM RMSE:", round(t2$RMSE_pm[1],3), "PM HR:", round(t2$HR_pm[1],3), "\n")
for (m in c("rlasso","gr_comb","pls","rf")) { r<-t2[t2$model==m,]; cat(m,": R2=",r$R2_OOS_pct," RMSE=",round(r$RMSE,2)," HR=",r$HR,"\n",sep="") }
for (h in c(3,12)) { t<-read.csv(sprintf("output/tables/table2_h%d.csv",h)); r<-t[t$model=="rlasso",]; cat("h",h,"rlasso R2:",r$R2_OOS_pct,"\n",sep="") }
t3 <- read.csv("output/tables/table3_h1.csv")
for (m in c("Buy-and-Hold","postlasso","rlasso","gr_comb","equal_comb")) { r<-t3[t3$model==m,]; cat(m,": wealth=",r$sw_wealth_10bps," maxDD=",r$sw_maxdd_10bps," sharpe=",r$sw_sharpe_10bps," dU=",r$mv_deltaU_10bps_pct,"\n",sep="") }
t5 <- read.csv("output/tables/table5_neely_replication.csv"); print(t5[t5$signal %in% c("VOL_2_9","VOL_2_12","VOL_3_12","MA_2_12"),c("sample","signal","R2_OOS_pct","CW_p")],row.names=FALSE)
sv <- read.csv("output/tables/signal_validation.csv"); cat("signal match:", 100*(1-sum(sv$mismatches)/sum(sv$months_compared)), "\n")'
```

## 3. Design system (apply to every slide)

**Canvas:** 13.333 in × 7.5 in (16:9).

**Colors (RGB):**
| Token | RGB | Use |
|---|---|---|
| Navy | (31, 54, 92) `#1F365C` | titles, bars, display numbers |
| Accent orange | (192, 80, 45) `#C0502D` | the one headline number per slide, emphasis |
| Grey | (96, 96, 96) `#606060` | subtitles, captions, secondary text |
| Panel grey | (242, 242, 242) `#F2F2F2` | callout/panel backgrounds |
| White | (255, 255, 255) | background |

**Type:** Calibri (fallback Arial). Sizes: slide title 28–30 pt bold navy;
subtitle 14 pt grey; bullets 16–18 pt dark grey; **display numbers 36–48 pt
bold** (navy; the headline number in accent orange); figure captions 11–12 pt
grey; speaker notes invisible to audience (just embed as notes).

**Layout grid:** title zone y = 0.25–1.30 in; content zone y = 1.40–7.10 in.
Text+figure slides: figure LEFT (6.2–7.2 in wide, x = 0.6), bullets RIGHT
(x = 7.0–8.0, width 4.9–5.9 in). Text-only slides: full width (x = 0.7,
width 11.9 in).

**Hard rules:** ≤4–5 bullets per slide; ≤12 words per bullet; one headline
number per slide rendered large; every figure gets a caption; no decorative
elements.

---

## 4. Slide-by-slide specification

### Slide 1 — Title (speaker: Vienna, 0:20, no figure)
- **Layout:** centered text block, y ≈ 2.0–4.6 in, full width.
- **Title (32 pt bold navy):** "Forecasting the Equity Risk Premium Out-of-Sample: Regularized ML, Technical Indicators & Tactical Asset Allocation"
- **Subtitle (18 pt accent):** "EC4308 Machine Learning and Economic Forecasting — Group Project (Week 13)"
- **Names (18 pt grey):** "Leon • En Shao • Sasinthiran Kannan • Vienna"
- **Speaker notes:** "Vienna (0:45): title, the Goyal-Welch puzzle in one sentence, roadmap of the talk."

### Slide 2 — Motivation (speaker: Vienna, 1:00, no figure)
- **Title:** "Motivation: Can anything beat the historical average?"
- **Subtitle:** "Goyal–Welch (2008, 2024) vs Neely, Rapach, Tu & Zhou (2014)"
- **Bullets (verbatim):**
  1. "The equity premium — how much stocks beat cash — is the key input for portfolio choice."
  2. "Goyal & Welch: essentially no macro fundamental beats the prevailing mean out-of-sample; Goyal–Welch–Zafirov (2024) reach the same conclusion with an expanded dataset of 57 monthly series."
  3. "Neely et al. (2014): 14 technical indicators (MA, MOM, OBV) DO predict the premium out-of-sample on 1966–2011."
  4. "Our question: with modern regularized ML, do technical indicators + macro lags beat the prevailing mean on the extended 1951–2025 sample?"
  5. "We replicate Neely et al. exactly (signals match 99.98%), then extend the sample to 2025."
- **Design:** highlight bullet 4 in accent.
- **Speaker notes:** "Vienna (1:00): set up the puzzle. Emphasise: replication first, extension second."

### Slide 3 — Data (speaker: Leon, 1:15, no figure)
- **Title:** "Data: 899 months, 98 predictors, zero lookahead"
- **Bullets (verbatim):**
  1. "Target: monthly log equity premium (%), S&P 500 over the risk-free rate."
  2. "Macro: the 14 Goyal–Welch predictors, each with lags 1–6 → 84 columns."
  3. "Technical: 14 binary Neely signals — 6 MA, 2 MOM, 6 OBV — from raw index level + S&P 500 volume."
  4. "Sample: 1951-02 → 2025-12; predictors aligned to 'observable at end of month t' — no lookahead."
  5. "Validation: our signals match the published Neely series in 99.98% of signal-months (12/14 exact)."
  6. "Fixed 240-month rolling window; first OOS forecast 1971-02; 659 OOS months at h = 1."
- **Display numbers:** 899 months · 98 predictors · 99.98% · 659 OOS (h=1) · 1951–2025.
- **Speaker notes:** "Leon (1:15): data sources, alignment convention, the 99.98% validation number, sample dates."

### Slide 4 — Methods (speaker: En Shao, 1:30, no figure)
- **Title:** "Methods: 7 models + 2 combinations vs the prevailing mean"
- **Bullets (verbatim):**
  1. "Benchmark: prevailing (historical) mean — the only admissible benchmark."
  2. "Models (same 98-predictor matrix, re-estimated every window):"
  3. "— LASSO (hdm, theoretical penalty — no CV) & post-LASSO"
  4. "— Ridge and Elastic Net (glmnet, 10-fold CV inside the window)"
  5. "— PCR & PLS (CV-selected components) • Random Forest (500 trees, fixed seed)"
  6. "Combinations: equal-weight 1/N and constrained Granger–Ramanathan (Σw=1, w≥0, weights from past OOS errors only)."
  7. "Horizons h ∈ {1, 3, 12}; DM (1995) tests with HAC lag h−1; Clark–West as appendix check."
- **Design:** model list as a grey panel; stress "no lookahead / inside the window" in accent.
- **Speaker notes:** "En Shao (1:30): one line per method, stress the no-lookahead CV protocol and the GR constraint."

### Slide 5 — Replication credibility check (speaker: Sasi, 1:15, no figure)
- **Title:** "Step 1: we replicate Neely et al. (2014) — their result survives"
- **Subtitle:** "Expanding-window bivariate regressions, one signal at a time, Clark–West test"
- **Mini-table (exact values — do not round):**

  | Signal | 1966–2011 R²_OOS | CW p | 2012–2025 R²_OOS | CW p |
  |---|---|---|---|---|
  | VOL(2,9) | +0.36% | 0.017 | −6.92% | 0.892 |
  | VOL(2,12) | +0.66% | 0.015 | −4.67% | 0.702 |
  | VOL(3,12) | +0.76% | 0.029 | −1.28% | 0.429 |

  (Source: `output/tables/table5_neely_replication.csv`, rows with
  sample = "Neely sample 1966-2011" / "Extension 2012-2025".)
- **Bullets:**
  1. "Volume-based (OBV) signals carry the predictive content; MA/MOM are weaker — the same pattern as the paper."
  2. "Published VOL(2,12): +0.33% — same sign, significance and order of magnitude as ours."
  3. "Extension 2012–2025: every signal turns negative/insignificant."
  4. "This validates our data pipeline and test implementation before we extend the sample."
- **Speaker notes:** "Sasi (1:15): replication = credibility. Show the numbers side by side with the published ones."

### Slide 6 — Result 1: statistical accuracy (speaker: Sasi, 1:15, FIGURE)
- **Title:** "Result 1: nothing beats the prevailing mean on the extended sample"
- **Figure:** `output/figures/figure2_r2oos.png` — LEFT, x=0.6, width=6.4 in, vertically centered.
  - **Caption (below figure, 11 pt grey):** "Out-of-sample R² (%) versus the prevailing mean by model and horizon. Negative values indicate lower accuracy than the benchmark."
- **Bullets (RIGHT, x=7.3, width=5.6 in):**
  1. "All models show NEGATIVE R²_OOS at every horizon: the Goyal–Welch result, reproduced with modern ML."
  2. "Best at h=1: LASSO R²_OOS = −8.8%; GR combination −10.0% (PM RMSE 4.399)."
  3. "Worst: PLS −40.6%, Random Forest −48.4% (h=1)."
  4. "Hit rates 53–58% vs PM 60% — the direction of the premium is also hard to call."
  5. "Stable across horizons: h=3 −8.2%, h=12 −11.5% (LASSO)."
- **Display numbers:** **−8.8%** (accent, large) · 4.399 · 60% · −48.4%.
- **Speaker notes:** "Sasi (1:15): negative results are results — correct execution matters more than a positive sign. Walk through the bar chart."

### Slide 7 — Result 2: economic value (speaker: Sasi, 1:15, FIGURE)
- **Title:** "Result 2: forecasts still have economic value — drawdown control"
- **Figure:** `output/figures/figure1_wealth.png` — LEFT, x=0.6, width=7.2 in.
  - **Caption:** "Cumulative wealth per $1 of the binary switching strategy (best model per horizon), the prevailing mean, and buy-and-hold, net of 10 bps costs."
- **Bullets (RIGHT, x=8.0, width=4.9 in):**
  1. "Switching (post-LASSO, 10 bps): max drawdown −23.4% vs buy-and-hold −50.2%; Sharpe 0.767 vs 0.777."
  2. "Terminal wealth $67.7 vs $346.5 — dodging bear markets costs upside in a bull-dominated sample."
  3. "Mean–variance investor (γ=3): ΔU = +1.31% p.a. (post-LASSO), +1.22% (LASSO), +1.06% (GR), +0.73% (equal) — net of costs."
  4. "Fee sensitivity at 5/20 bps reported in the paper."
- **Display numbers:** **−50% → −23%** (accent) · **+1.31% p.a.** · 0.767 / 0.777.
- **Speaker notes:** "Sasi (1:15): Sharpe vs wealth trade-off; ΔU interpretation; fee sensitivity 5/20 bps in the report."

### Slide 8 — Why predictability decayed (speaker: Vienna, 1:00, FIGURE)
- **Title:** "Why did predictability decay?"
- **Figure:** `output/figures/figure4_subperiods.png` — LEFT, x=0.6, width=6.2 in.
  - **Caption:** "LASSO out-of-sample R² by subperiod (h = 1) — closest to the prevailing mean exactly in the 2000–2011 crisis decade."
- **Bullets (RIGHT, x=7.0, width=5.9 in):**
  1. "Recession months drive the signal value: volume/MA rules earn their R² in a handful of crisis months (2000–02, 2008–09)."
  2. "Subperiods (LASSO, h=1): −10.5% (1971–99) → −1.2% (2000–11) → −13.4% (2012–25)."
  3. "GR combination: −10.9% → −1.9% → −17.5%."
  4. "Post-2011: fewer deep drawdowns, a passive-dominated market, and faster arbitrage of published signals."
  5. "Macro-only LASSO is closest to the benchmark (−0.9%) — joint fits dilute the signal."
- **Display numbers:** **−1.2%** (accent, the crisis-decade dip) · −10.5 / −13.4.
- **Speaker notes:** "Vienna (1:00): economic interpretation, connect to the literature."

### Slide 9 — Conclusion (speaker: Vienna, 0:45, no figure)
- **Title:** "Conclusion"
- **Bullets (verbatim):**
  1. "We reproduce Neely et al. (2014) faithfully (99.98% signal match; positive VOL-signal R²_OOS on 1966–2011)."
  2. "Extended to 2025, no model — regularized, tree-based, or combined — beats the prevailing mean on RMSE/MAE or direction."
  3. "Economic value persists: switching halves the max drawdown (−50% → −23%); MV gains of +1.2–1.3% p.a. net of costs."
  4. "Lesson: honest evaluation, disciplined windows and costs matter more than model complexity."
- **Design:** three numbered findings; final line in accent.
- **Speaker notes:** "Vienna (0:45): wrap-up, hand over to Q&A."

### Slide 10 — Q&A (all four, 2:00, no figure)
- **Layout:** centered "Thank you — questions?" (40 pt bold navy), y ≈ 2.6–4.1 in.
- **Speaker notes (embed):**
  "All four members (2:00): En Shao on model choices, Sasi on evaluation details, Leon on data, Vienna on interpretation."
  Q&A prep per member (also in `deck/speaker_scripts.md`):
  - En Shao: why CV inside the window is leakage-free; the GR constraint.
  - Sasi: DM vs CW; the h>1 switching timing; fee assumptions.
  - Leon: the volume splice (paper 1950–2011 + Yahoo 2012–2025); the two mismatching signal-months.
  - Vienna: negative results are results; the macro-only variant.

---

## 5. Total timing

1:00+1:15+1:30+1:15+1:15+1:15+1:00+0:45 (talking) + 0:20 title + 2:00 Q&A
≈ **10:00** including hand-offs. Do not add slides beyond these 10.

## 6. Number appendix (final values — use these, verbatim)

| # | Value | Source (repo) |
|---|---|---|
| Sample size | 899 months (1951-02 → 2025-12) | `data/processed/panel.csv` |
| Predictors | 98 = 84 macro-lag + 14 technical | `data/processed/codebook.csv` |
| Signal replication match | 99.9805% (2 of 10,262 signal-months differ) | `output/tables/signal_validation.csv` |
| OOS months | h=1: 659 · h=3: 657 · h=12: 648 | `output/tables/table2_h{1,3,12}.csv` row counts |
| PM RMSE (h=1) | 4.399 | `table2_h1.csv` (RMSE_pm) |
| LASSO R²_OOS | h=1 −8.8% · h=3 −8.2% · h=12 −11.5% | `table2_h{1,3,12}.csv` (R2_OOS_pct) |
| GR R²_OOS (h=1) | −10.0% | `table2_h1.csv` |
| PLS / RF R²_OOS (h=1) | −40.6% / −48.4% | `table2_h1.csv` |
| Hit rates | models 53–58% · PM 60% | `table2_h*.csv` (HR, HR_pm) |
| Neely replication 1966–2011 | VOL(2,9) +0.36% (p 0.017) · VOL(2,12) +0.66% (p 0.015) · VOL(3,12) +0.76% (p 0.029) | `table5_neely_replication.csv` |
| Published VOL(2,12) | +0.33% | Neely et al. (2014) Table II |
| Extension 2012–2025 | all negative; VOL(3,12) −1.28% (p 0.429) | `table5_neely_replication.csv` |
| Drawdown | BH −50.2% → post-LASSO −23.4% | `table3_h1.csv` (sw_maxdd_10bps) |
| Terminal wealth | post-LASSO $67.7 · BH $346.5 | `table3_h1.csv` (sw_wealth_10bps) |
| Switching Sharpe | post-LASSO 0.767 · BH 0.777 | `table3_h1.csv` (sw_sharpe_10bps) |
| MV ΔU (10 bps) | post-LASSO +1.31% · LASSO +1.22% · GR +1.06% · equal +0.73% p.a. | `table3_h1.csv` (mv_deltaU_10bps_pct) |
| Subperiods LASSO (h=1) | 1971–99 −10.5% · 2000–11 −1.2% · 2012–25 −13.4% | recompute from `forecasts_h1.csv` + `panel.csv` |
| Subperiods GR (h=1) | −10.9% · −1.9% · −17.5% | same |
| Macro-only LASSO (h=1) | −0.9% | `forecasts_h1_macro.csv` (Appendix A1) |
| GWZ 2024 citation | "A Comprehensive 2022 Look…", RFS 37(11), DOI 10.1093/rfs/hhae044 | `report/main.tex` bibliography |

## 7. Figures (paths, sizes, captions)

| Figure | Path | On slide | Embed size | Caption (11 pt grey, below figure) |
|---|---|---|---|---|
| fig2 | `output/figures/figure2_r2oos.png` | 6 | w 6.4 in | "Out-of-sample R² (%) versus the prevailing mean by model and horizon. Negative values indicate lower accuracy than the benchmark." |
| fig1 | `output/figures/figure1_wealth.png` | 7 | w 7.2 in | "Cumulative wealth per $1 of the binary switching strategy (best model per horizon), the prevailing mean, and buy-and-hold, net of 10 bps costs." |
| fig4 | `output/figures/figure4_subperiods.png` | 8 | w 6.2 in | "LASSO out-of-sample R² by subperiod (h = 1) — closest to the prevailing mean exactly in the 2000–2011 crisis decade." |

Figures are 300 dpi PNGs (e.g., 2100×1800, 3000×1260, 1800×1080); keep
aspect ratio (do not distort). If you regenerate them: `Rscript R/13_figures.R`.

## 8. Deliverable & verification checklist

Deliver: a `.pptx` (10 slides + notes). Before handing over, verify:
1. `python3 -c "from pptx import Presentation; p=Presentation('YOUR_FILE.pptx'); print(len(p.slides))"` → 10.
2. Every slide has notes (`slide.notes_slide` present).
3. Run §2's verification command and diff its output against §6 (allowing
   last-digit display rounding only).
4. Open the file visually once: figures not distorted, no text overflow.

Do NOT: add slides, change numbers, add logos/watermarks, or invent content
not in this brief. If the repo is unavailable, STOP and say so — the numbers
above are the fallback source and are final.
