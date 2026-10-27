# EC4308 Report — Plain-English Explainer (for the group, pre-presentation)

Read this once (10 minutes) and you'll understand everything you're about to
present or defend. Each section: what it says in one paragraph + the one
question a skeptical person would ask.

---

## The whole paper in 5 sentences

We ask: can any machine-learning model, using economic data + stock-market
"technical signals," forecast next month's stock-market premium (how much
stocks beat cash) better than just assuming "next month will be like the
historical average"? Answer on modern data (1971–2025): **no.** But we
*proved our methods work* by reproducing a famous 2014 paper's positive
findings on its own old sample (1966–2011) — the predictability was real
back then and disappeared after 2012. The forecasts still have one practical
use: they cut the worst crash from −50% to −23% and give a cautious investor
~+1.3% per year extra, net of fees.

## Section by section

**Abstract & Introduction.** Sets up the puzzle (Goyal–Welch: nothing beats
the historical average) and states our three findings: (1) no model beats
the benchmark on the extended sample, (2) the 2014 technical-signal
predictability is real but vanished post-2012, (3) forecasts still help with
risk management.
*Skeptic's question:* "So you found nothing?" → Answer: a clean negative
result with a replication that proves we'd have found something if it
existed. Prof. Denis's guidelines say exactly this is a valuable result.

**Section 2 — Data.** The target: monthly S&P 500 return over T-bills, in
percent. Predictors: 14 classic economic ratios/rates (each with 1–6 months
of history) + 14 yes/no technical signals (is the market trending up?
volume confirming?). Sample: Feb 1951 – Dec 2025, 899 months. The key
discipline: at each month we only use info available at that moment — no
cheating with the future. We validated our signals against the published
2014 data: 99.98% identical.
*Skeptic's question:* "How do I know the data's right?" → We match the
published series almost exactly, and Table 1 reports standard summary stats.

**Section 3 — Methods.** A fixed 20-year window of history is used to
forecast each next month (1, 3, or 12 months ahead). Seven models are
re-fitted every month: LASSO/post-LASSO, Ridge, Elastic Net, PCR, PLS, and
a random forest — plus two ways to combine them (simple average and a
"learn who's been right lately" weighted average that can't go negative and
must sum to 100%). Benchmark: the historical average. Tests: Diebold–
Mariano (is one forecast significantly better?), Clark–West (appendix),
plus two trading simulations with real transaction costs (5/10/20 bps).
*Skeptic's question:* "Why seven models?" → Because no one knows in advance
which would work; the discipline is that everything is decided on past data
only.

**Section 4.1 — Statistical results.** Every model is *worse* than the
historical average: out-of-sample R² from −8% (LASSO, best) to −50%. Even
guessing the *direction* (up/down) fails (53–58% vs the benchmark's 60%).
This holds at all three horizons.
*Skeptic's question:* "Worse than doing nothing?" → Yes, and that's the
Goyal–Welch finding reproduced with modern ML — the honest headline.

**Section 4.2 — Replication.** Running the 2014 paper's exact design on
1966–2011: three volume signals are positive and statistically significant
(+0.36%/+0.66%/+0.76% out-of-sample R²). Same design on 2012–2025: all
negative, nothing significant. Conclusion: the signal was real, then died.
*Skeptic's question:* "Maybe your code is broken?" → The fact that we
reproduce the published positive results on their sample is the strongest
possible evidence the code works.

**Section 4.3 — Economic value.** A strategy that holds stocks when the
forecast is positive and cash otherwise: ends with less wealth than
buy-and-hold (because it sits out of bull markets) but cuts the maximum
drawdown from −50% to −23% at the same risk-adjusted return (Sharpe 0.767
vs 0.777). A mean-variance investor using the forecasts earns +1.2–1.3%
per year net of fees.
*Skeptic's question:* "Less money but you call it value?" → Risk management
is the point: halving your worst loss at market-level Sharpe is the value;
the utility gain is positive *net* of costs.

**Section 4.4 — Why predictability decayed.** The signals only earned their
keep in crisis decades: LASSO's R² is −10.5% in 1971–99, improves to −1.2%
in 2000–11 (the two crashes), then −13.5% after 2012. Passive investing and
faster arbitrage of published signals likely killed it.

**Conclusion.** Replication works; extension shows decay; forecasts still
earn their keep as risk signals. Limitations: US only, monthly data, simple
costs model.

**Appendix.** A1: predictor-set variants (macro-only LASSO gets closest to
the benchmark at −0.9% — the technical signals dilute the joint fit).
Clark–West appendix test confirms the DM verdict.

---

## The 3 numbers to have in your head for Q&A
- **99.98%** — our technical signals match the published ones (pipeline works).
- **−8% to −50%** — every model loses to the historical average (honest result).
- **−50% → −23%** — drawdown halved; **+1.3% p.a.** — net utility gain (economic value).
