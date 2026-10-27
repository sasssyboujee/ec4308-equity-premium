# EC4308 Presentation — Per-Speaker Scripts & Timing (10 minutes)

Deck: `deck/EC4308_Presentation.pptx` (10 slides, speaker notes embedded).
Total: 8:30 of talking + buffer. Target ~45–60 s per speaker slot.
Rehearse the hand-offs: each speaker ends by introducing the next.

---

## Vienna — Slides 1–2 (1:45)

**Slide 1 (0:20)** — "Good morning. We're presenting our project on forecasting
the equity risk premium out-of-sample, combining regularized machine learning
with the technical indicators of Neely, Rapach, Tu and Zhou, published in
Management Science 2014. My teammates and I will take you through the data,
the methods, the results and what we learned."

**Slide 2 (1:00)** — "Here's the puzzle. Goyal and Welch showed that
essentially no macroeconomic variable beats the historical average out of
sample — and their 2024 update with 57 predictors reaches the same verdict.
Neely et al. found an exception: technical indicators, especially volume-based
ones, did predict the premium from 1966 to 2011. Our question: once you feed
the macro variables and the technical signals through modern regularized ML,
does anything beat the prevailing mean on data extended to 2025? We start by
replicating Neely exactly, then extend. Leon will walk you through the data."

---

## Leon — Slide 3 (1:15)

"The target is the monthly log equity premium — the S&P 500 return including
dividends minus the risk-free rate. Predictors: the fourteen Goyal–Welch macro
variables, each with one to six monthly lags, plus the fourteen binary
technical signals — six moving-average rules, two momentum rules, and six
on-balance-volume rules. The sample runs February 1951 to December 2025, 899
months. The critical part is alignment: row t only contains information
observable at the end of month t, so there is no lookahead. To validate the
pipeline, we recomputed the signals from raw price and volume data: 99.98
percent of signal-months match the published series exactly. The fixed
240-month rolling window gives 659 out-of-sample months starting February
1971. En Shao will cover the models."

---

## En Shao — Slide 4 (1:30)

"We estimate seven models inside every window: LASSO with the theoretical
penalty from the hdm package — no cross-validation needed — and post-LASSO;
Ridge and Elastic Net with the penalty selected by ten-fold cross-validation
strictly inside the training window; PCR and PLS with cross-validated
component counts; and a random forest with a fixed seed so the whole pipeline
is exactly reproducible. On top, we combine the seven forecasts two ways: a
simple equal-weight average, and a constrained Granger–Ramanathan regression —
weights non-negative, summing to one, estimated only from past out-of-sample
errors, so no future information enters the weights. Everything is benchmarked
against the prevailing mean at one-, three- and twelve-month horizons, with
Diebold–Mariano tests and Clark–West as an appendix check. Sasi will show the
results."

---

## Sasi — Slides 5–7 (3:45)

**Slide 5 (1:15)** — "Before we show our headline results, here's our
credibility check. We re-ran Neely et al.'s exact design — expanding-window
bivariate regressions, one technical signal at a time — on their 1966 to 2011
sample. The volume signals come out positive and significant: VOL-2-12 gives
0.66 percent out-of-sample R-squared — same sign and significance as the
published paper's 0.33 — and VOL-3-12 gives 0.76. So our pipeline finds
predictability where the literature found it. But on the 2012 to 2025
extension, every single signal turns negative and insignificant."

**Slide 6 (1:15)** — "Now the main results on the extended sample. Nothing
beats the prevailing mean at any horizon. The best model, LASSO, has an
out-of-sample R-squared of minus 8.8 percent at one month; the worst, random
forest, minus 48. The ranking is stable across horizons, and the
Diebold–Mariano tests say the models are significantly worse. Hit rates —
the fraction of months with the right sign — are 54 to 58 percent versus 60
for the benchmark, which just bets on positive every month. This is Goyal and
Welch's result, reproduced with modern machine learning."

**Slide 7 (1:15)** — "Yet the forecasts still have economic value. The
switching strategy — hold equities when the forecast is positive, T-bills
otherwise — cuts the maximum drawdown from minus 50 percent to minus 23
percent at a Sharpe ratio essentially equal to the market's. And the
mean-variance investor earns certainty-equivalent gains of 1.2 to 1.3 percent
per annum, net of transaction costs, with results stable at five and twenty
basis points. The forecasts earn their keep as risk-management signals, not
as point forecasts. Vienna will interpret."

---

## Vienna — Slides 8–10 (2:15)

**Slide 8 (1:00)** — "Why did predictability decay? First, the technical
signals earn their keep almost entirely in crisis months — 2000 to 2002 and
2008 to 2009 — and the post-2011 sample simply lacks comparable episodes.
Our subperiod split shows this directly: LASSO's out-of-sample R-squared is
minus 10.5 percent in 1971 to 1999, improves to minus 1.2 percent in the
crisis decade 2000 to 2011, then drops to minus 13.4 percent after 2012.
Second, a market dominated by passive flows arbitrages published signals
faster. Third, joint multivariate fits dilute the bivariate information: with
only macro predictors, LASSO is much closer to the benchmark at minus 0.9
percent. Our evidence lines up with Goyal, Welch and Zafirov 2024: any
predictability is episodic, not structural."

**Slide 9 (0:45)** — "To conclude: we replicate Neely et al. faithfully — on
their sample, the volume signals work. On the extended sample, no model beats
the historical mean on accuracy, but the forecasts still deliver drawdown
control and positive mean-variance gains. The lesson: honest evaluation,
disciplined windows and transaction costs matter more than model complexity."

**Slide 10 (0:15)** — "Thank you — we're happy to take questions."

---

## Q&A prep (shared)

- **En Shao**: why CV inside the window is leakage-free; the GR constraint.
- **Sasi**: DM vs CW; the h>1 switching timing; fee assumptions.
- **Leon**: the volume splice (paper series 1950–2011 + Yahoo 2012–2025);
  the two mismatching signal-months.
- **Vienna**: interpretation — negative results are results; economic value
  story; the macro-only variant.
