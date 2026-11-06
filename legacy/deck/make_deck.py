#!/usr/bin/env python3
# =============================================================================
# deck/make_deck.py -- 10-minute presentation deck (EC4308, Week 13)
# =============================================================================
# Builds deck/EC4308_Presentation.pptx from the computed results:
# figures (output/figures/figure*.png) and tables (output/tables/table*_h1.csv).
# Speaker notes are embedded per slide; each of the four members speaks.
# Run AFTER R/11_evaluate.R and R/13_figures.R:
#     python3 deck/make_deck.py
# =============================================================================
import csv, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FIG = os.path.join(ROOT, "output", "figures")
TAB = os.path.join(ROOT, "output", "tables")

def load_table(name):
    with open(os.path.join(TAB, name), newline="") as f:
        return list(csv.DictReader(f))

t2 = load_table("table2_h1.csv")
t3 = load_table("table3_h1.csv")
t5 = load_table("table5_neely_replication.csv")
if not t2 or not t5 or "CW_p" not in t2[0] or "CW_p" not in t5[0]:
    raise SystemExit(
        "Presentation generation is deferred: the corrected analysis removed "
        "unsupported CW p-values. Review the simple-return target, chronological "
        "tuning and updated results before revising this legacy slide template. "
        "No presentation has been saved."
    )

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN

DARK = RGBColor(0x1F, 0x36, 0x5C)
ACC  = RGBColor(0xC0, 0x50, 0x2D)

prs = Presentation()
prs.slide_width  = Inches(13.333)
prs.slide_height = Inches(7.5)
BLANK = prs.slide_layouts[6]

def add_title(slide, text, sub=None):
    tb = slide.shapes.add_textbox(Inches(0.5), Inches(0.25), Inches(12.3), Inches(1.0))
    tf = tb.text_frame; tf.word_wrap = True
    p = tf.paragraphs[0]; r = p.add_run(); r.text = text
    r.font.size = Pt(30); r.font.bold = True; r.font.color.rgb = DARK
    if sub:
        p2 = tf.add_paragraph(); r2 = p2.add_run(); r2.text = sub
        r2.font.size = Pt(14); r2.font.color.rgb = RGBColor(0x60, 0x60, 0x60)

def add_bullets(slide, items, size=16, left=0.7, top=1.4, width=11.9, height=5.4):
    tb = slide.shapes.add_textbox(Inches(left), Inches(top), Inches(width), Inches(height))
    tf = tb.text_frame; tf.word_wrap = True
    for i, (txt, lvl) in enumerate(items):
        p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
        p.text = txt; p.level = lvl
        for r in p.runs: r.font.size = Pt(size)

def add_pic(slide, path, left, top, width=None, height=None):
    slide.shapes.add_picture(path, Inches(left), Inches(top),
                             Inches(width) if width else None,
                             Inches(height) if height else None)

def add_notes(slide, text):
    slide.notes_slide.notes_text_frame.text = text

# ---- key numbers -------------------------------------------------------------
gr = next(r for r in t2 if r["model"] == "gr_comb")
rl = next(r for r in t2 if r["model"] == "rlasso")
hr_range = (min(float(r["HR"]) for r in t2),
            max(float(r["HR"]) for r in t2))
hr_pm = float(t2[0]["HR_pm"])
min_dm_p = min(float(r["DM_RMSE_p"]) for r in t2)
min_cw_p = min(float(r["CW_p"]) for r in t2)
pm_rmse = float(t2[0]["RMSE_pm"])
bh = next(r for r in t3 if r["model"] == "Buy-and-Hold")
pm = next(r for r in t3 if r["model"] == "Prevailing Mean")
gr3 = next(r for r in t3 if r["model"] == "gr_comb")
post = next(r for r in t3 if r["model"] == "postlasso")
rl_econ = next(r for r in t3 if r["model"] == "rlasso")
vol212 = next(r for r in t5 if r["sample"] == "Neely sample 1966-2011" and r["signal"] == "VOL_2_12")
vol29 = next(r for r in t5 if r["sample"] == "Neely sample 1966-2011" and r["signal"] == "VOL_2_9")
vol312 = next(r for r in t5 if r["sample"] == "Neely sample 1966-2011" and r["signal"] == "VOL_3_12")
ext29 = next(r for r in t5 if r["sample"] == "Extension 2012-2025" and r["signal"] == "VOL_2_9")
ext212 = next(r for r in t5 if r["sample"] == "Extension 2012-2025" and r["signal"] == "VOL_2_12")
ext = next(r for r in t5 if r["sample"] == "Extension 2012-2025" and r["signal"] == "VOL_3_12")

# ---- 1. title -----------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
tb = s.shapes.add_textbox(Inches(0.8), Inches(2.0), Inches(11.7), Inches(2.4))
tf = tb.text_frame; tf.word_wrap = True
p = tf.paragraphs[0]; r = p.add_run()
r.text = "Forecasting the Equity Risk Premium Out-of-Sample:\nRegularized ML, Technical Indicators & Tactical Asset Allocation"
r.font.size = Pt(32); r.font.bold = True; r.font.color.rgb = DARK
p2 = tf.add_paragraph(); r2 = p2.add_run()
r2.text = "EC4308 Machine Learning and Economic Forecasting — Group Project (Week 13)"
r2.font.size = Pt(18); r2.font.color.rgb = ACC
p3 = tf.add_paragraph(); r3 = p3.add_run()
r3.text = "Leon • En Shao • Sasinthiran Kannan • Vienna"
r3.font.size = Pt(18)
add_notes(s, "Vienna (0:45): title, the Goyal-Welch puzzle in one sentence, roadmap of the talk.")

# ---- 2. motivation ------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "Motivation: Can anything beat the historical average?", "Goyal–Welch (2008, 2024) vs Neely, Rapach, Tu & Zhou (2014)")
add_bullets(s, [
    ("The equity premium is the single most important input for portfolio choice — 1 month of lead time is economically valuable.", 0),
    ("Goyal & Welch: essentially no macro fundamental beats the prevailing mean out-of-sample; Goyal–Welch–Zafirov (2024) reach the same conclusion with an expanded dataset of 57 monthly series.", 0),
    ("Neely et al. (2014): 14 technical indicators (MA, MOM, OBV) DO predict the premium out-of-sample on 1966–2011.", 0),
    ("Our question: with modern regularized ML, do technical indicators + macro lags beat the prevailing mean on the extended 1951–2025 sample?", 0),
    ("We match 99.98% of published signal-months; the time-aligned Neely regression has 178 initial pairs versus 181 months in the original design.", 0),
])
add_notes(s, "Vienna (1:00): set up the puzzle. Emphasise: replication first, extension second.")

# ---- 3. data ------------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "Data: 899 months, 98 predictors, zero lookahead")
add_bullets(s, [
    ("Target: monthly log equity premium (%), y = 100·(ln(1+Rᵐ) − ln(1+Rᶠ)), S&P 500 over the risk-free rate.", 0),
    ("Macro: the 14 Goyal–Welch predictors, each with lags 1–6  →  84 columns.", 0),
    ("Technical: 14 binary Neely signals — 6 MA, 2 MOM, 6 OBV — computed from raw index level + S&P 500 volume.", 0),
    ("Sample: 1951-02 → 2025-12; predictors aligned to 'observable at end of month t' — no lookahead leakage.", 0),
    ("Validation: our computed signals match the published Neely series in 99.98% of signal-months (12/14 exact).", 0),
    ("Fixed 240-pair rolling window; first h=1 forecast targets 1971-03; n = 658 OOS months.", 0),
])
add_notes(s, "Leon (1:15): data sources, alignment convention, the 99.98% validation number, sample dates.")

# ---- 4. methods ----------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "Methods: 7 models + 2 combinations vs the prevailing mean")
add_bullets(s, [
    ("Benchmark: prevailing (historical) mean — the only admissible benchmark.", 0),
    ("Models (same 98-predictor matrix, re-estimated every window):", 0),
    ("LASSO (hdm, theoretical penalty — no CV) & post-LASSO", 1),
    ("Ridge and Elastic Net (glmnet, 10-fold CV inside the window)", 1),
    ("PCR & PLS (CV-selected components) • Random Forest (500 trees, fixed seed)", 1),
    ("Combinations: equal-weight 1/N and constrained Granger–Ramanathan (Σw=1, w≥0, weights from past OOS errors only).", 0),
    ("Horizons h ∈ {1, 3, 12}; DM (1995) tests with HAC lag h−1; Clark–West as appendix check.", 0),
])
add_notes(s, "En Shao (1:30): one line per method, stress the no-lookahead CV protocol and the GR constraint.")

# ---- 5. replication -------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "Time-aligned Neely et al. (2014) estimates",
          "Expanding-window bivariate regressions, one signal at a time, Clark–West test")
add_bullets(s, [
    (f"1966–2011: VOL_2_9 R²_OOS = {vol29['R2_OOS_pct']}% (CW p = {vol29['CW_p']}), "
     f"VOL_2_12 = {vol212['R2_OOS_pct']}% (p = {vol212['CW_p']}), "
     f"VOL_3_12 = {vol312['R2_OOS_pct']}% (p = {vol312['CW_p']}).", 0),
    ("These are three focal estimates; none of the six volume rules is significant at 5%.", 0),
    ("The corrected expanding-window estimates use signal-month predictors to forecast the following month's return.", 0),
    (f"Extension 2012–2025: selected VOL estimates are {ext29['R2_OOS_pct']}%, {ext212['R2_OOS_pct']}%, and {ext['R2_OOS_pct']}%.", 0),
])
add_notes(s, "Sasi (1:15): explain the predictor/target timing change and report the recalculated estimates and tests.")

# ---- 6. statistical results ------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "Result 1: nothing beats the prevailing mean on the extended sample",
          "Main ML OOS targets: h=1 Mar 1971–Dec 2025; h=3 Jul 1971–Dec 2025; h=12 Jan 1973–Dec 2025")
add_pic(s, os.path.join(FIG, "figure2_r2oos.png"), 0.6, 1.35, width=6.4)
add_bullets(s, [
    ("All models show NEGATIVE R²_OOS at every horizon: the Goyal–Welch result, reproduced with modern ML.", 0),
    (f"At h=1: LASSO R²_OOS = {rl['R2_OOS_pct']}%; GR = {gr['R2_OOS_pct']}% (PM RMSE {pm_rmse:.3f}).", 0),
    (f"h=1 hit rates: {hr_range[0]:.1%}–{hr_range[1]:.1%} vs PM {hr_pm:.1%}.", 0),
    (f"One-sided h=1 tests show no significant improvement (minimum DM p={min_dm_p:.3f}; CW p={min_cw_p:.3f}).", 0),
    ("R²_OOS is a descriptive comparison with the prevailing-mean benchmark; it does not establish a causal mechanism.", 0),
], left=7.3, top=1.35, width=5.6, height=5.0)
add_notes(s, "Sasi (1:15): negative results are results — correct execution matters more than a positive sign. Walk through the bar chart.")

# ---- 7. economic results -----------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "Economic strategies: negative h=1 utility gains")
add_pic(s, os.path.join(FIG, "figure1_wealth.png"), 0.6, 1.4, width=7.2)
add_bullets(s, [
    (f"Switching (LASSO, 10 bps): max drawdown {float(rl_econ['sw_maxdd_10bps'])*100:.1f}% vs buy-and-hold {float(bh['sw_maxdd_10bps'])*100:.1f}%; terminal wealth ${float(rl_econ['sw_wealth_10bps']):.1f} vs ${float(bh['sw_wealth_bh']):.1f}.", 0),
    (f"At h=1, 10 bps net, mean–variance ΔU: LASSO {float(rl_econ['mv_deltaU_10bps_pct']):+.2f}%, post-LASSO {float(post['mv_deltaU_10bps_pct']):+.2f}%, GR {float(gr3['mv_deltaU_10bps_pct']):+.2f}% p.a.", 0),
    ("All h=1 forecast-based mean–variance utility differences are negative; fee sensitivity is reported in the paper.", 0),
], left=8.0, top=1.4, width=4.9, height=5.0)
add_notes(s, "Sasi (1:15): report the forecast-strategy results as sample estimates; distinguish wealth, drawdown, and utility.")

# ---- 8. subperiod comparisons ------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "How do results vary across subperiods?")
add_pic(s, os.path.join(FIG, "figure4_subperiods.png"), 0.6, 1.5, width=6.2)
add_bullets(s, [
    ("Subperiod R² comparisons are descriptive; they do not show that recessions cause changes in forecast performance.", 0),
    ("This design does not test explanations involving passive flows or arbitrage speed.", 0),
    ("The corrected Neely replication does not find 5% significance for the selected volume signals.", 0),
    ("Macro-only and technical-only predictor-set comparisons are reported in the appendix.", 0),
], left=7.0, top=1.5, width=5.9, height=5.0)
add_notes(s, "Vienna (1:00): describe the subperiod comparisons without presenting them as causal evidence.")

# ---- 9. conclusion -------------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_title(s, "Conclusion")
add_bullets(s, [
    ("We match Neely et al.'s published signals in 99.98% of signal-months; none of the six time-aligned volume rules is significant at 5%.", 0),
    ("Extended to 2025, all model R² estimates are negative; one-sided tests show no significant accuracy improvement, and hit rates are close to but not uniformly below the benchmark.", 0),
    ("At h=1, the LASSO switching strategy has lower terminal wealth than buy-and-hold and a modestly smaller maximum drawdown; mean-variance ΔU is negative.", 0),
    ("The corrected results do not support claiming that forecast-based strategies improve point accuracy or mean-variance utility.", 0),
])
add_notes(s, "Vienna (0:45): wrap-up, hand over to Q&A.")

# ---- 10. Q&A ---------------------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
tb = s.shapes.add_textbox(Inches(1), Inches(2.6), Inches(11.3), Inches(1.5))
tf = tb.text_frame
p = tf.paragraphs[0]; p.alignment = PP_ALIGN.CENTER
r = p.add_run(); r.text = "Thank you — questions?"
r.font.size = Pt(40); r.font.bold = True; r.font.color.rgb = DARK
add_notes(s, "All four members (2:00): En Shao on model choices, Sasi on evaluation details, Leon on data, Vienna on interpretation.")

out = os.path.join(ROOT, "deck", "EC4308_Presentation.pptx")
prs.save(out)
print("Wrote", out)
