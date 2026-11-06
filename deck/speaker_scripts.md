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
sample — and their 2024 update with an expanded dataset of 57 monthly
series reaches the same verdict.
Neely et al. reported an exception: technical indicators, especially
volume-based ones, predicted the premium from 1966 to 2011. Our corrected
time-aligned replication does not find 5-percent significance for any of the
six volume rules. Our question: once you feed
the macro variables and the technical signals through modern regularized ML,
does anything beat the prevailing mean on data extended to 2025? We use the
same expanding-window design as Neely, then extend. Our technical signals
match 99.98 percent of published signal-months. Correct predictor/target
timing leaves 178 paired observations before the January 1966 forecast,
compared with 181 months in the original design. Leon will walk you through
the data."

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
240 valid predictor-target pairs give 658 out-of-sample months starting March
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

**Slide 5 (1:15)** — "We re-estimated expanding-window bivariate regressions,
one technical signal at a time, on the 1966 to 2011 sample. Aligning each
signal with the following month's return leaves 178 correctly timed pairs
before the January 1966 forecast. The selected volume-signal estimates are
positive but not significant at 5%: VOL(2,9) is 0.19 percent (Clark-West
p = 0.193), VOL(2,12) is 0.11 percent (p = 0.247), and VOL(3,12) is 0.53
percent (p = 0.077). These are three focal signals; none of the six volume
rules is significant at 5%. The three focal estimates are negative and not
significant in the 2012 to 2025 extension. This timing correction changes
the replication result, so we do not claim to recover the published
significance."

**Slide 6 (1:15)** — "No model has positive out-of-sample R-squared against
the prevailing mean at any horizon. The main ML evaluation targets run
March 1971 to December 2025 at h=1, July 1971 to December 2025 at h=3, and
January 1973 to December 2025 at h=12; this is distinct from the 2012–2025
Neely replication extension. At one month, the benchmark RMSE is 4.403;
LASSO has R-squared minus 1.06 percent, while random forest is minus
15.49 percent. Post-LASSO is closest at three months, minus 0.38 percent,
and twelve months, minus 0.52 percent. The one-sided Diebold–Mariano and
Clark–West tests do not show significant improvement over the benchmark;
they also do not show that the models are significantly worse. One-month
hit rates range from 53.5 to 59.7 percent versus 59.9 percent for the
benchmark."

**Slide 7 (1:15)** — "The corrected one-month forecasts do not improve on the
prevailing mean in RMSE, and the mean-variance utility differences are
negative across models. At h=1 with 10 basis points in transaction costs,
ΔU is minus 0.39 percent per year for LASSO and minus 2.07 percent for
post-LASSO. For the LASSO-driven switching strategy, maximum
drawdown is minus 44.4 percent versus minus 50.2 percent for buy-and-hold,
but terminal wealth is lower: 232.7 dollars versus 341.9 dollars per dollar
invested. These are sample outcomes, not evidence that the forecasts add
economic value. Vienna will interpret."

---

## Vienna — Slides 8–10 (2:15)

**Slide 8 (1:00)** — "The subperiod R-squared comparisons are descriptive:
they do not show that recessions cause changes in forecast performance. Our
design also does not test explanations involving passive flows or faster
arbitrage. The corrected Neely replication does not find 5-percent
significance for the selected volume signals. Macro-only and technical-only
predictor-set comparisons are reported in the appendix; these comparisons
should not be interpreted as causal evidence."

**Slide 9 (0:45)** — "To conclude: after aligning predictors with the returns
they precede, our three focal volume-signal estimates are positive but not
significant at 5% on Neely et al.'s sample; none of the six volume rules is
significant at that level. We have 178 initial pairs, rather
than the original 181-month window. On the extended sample, no model beats
the historical mean on point-forecast accuracy. The corrected h=1
mean-variance utility differences are negative, and the LASSO switching
strategy trades lower terminal wealth for a modestly smaller drawdown. The
lesson: honest evaluation, disciplined windows and transaction costs matter
more than model complexity."

**Slide 10 (0:15)** — "Thank you — we're happy to take questions."

---

## Q&A prep (shared)

- **En Shao**: why CV inside the window is leakage-free; the GR constraint.
- **Sasi**: DM vs CW; the h>1 switching timing; fee assumptions.
- **Leon**: the volume splice (paper series 1950–2011 + Yahoo 2012–2025);
  the two mismatching signal-months.
- **Vienna**: interpretation — negative results are results; economic value
  story; the macro-only variant.
