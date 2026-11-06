# EC4308 Report — Plain-English Explainer (for the group, pre-presentation)

> **Historical explanation:** do not use its numbers or methods for the corrected
> analysis. Report/presentation interpretation is deferred to the group after
> reviewing [README](../README.md) and regenerated numerical outputs.

Read this once (10 minutes) and you'll understand everything you're about to
present or defend. Each section: what it says in one paragraph + the one
question a skeptical person would ask.

---

## The whole paper in 5 sentences

We ask whether machine-learning forecasts of the US equity premium beat the
prevailing historical mean. After correcting the predictor/target timing,
none of the nine forecast models has positive out-of-sample R² at any
horizon, and the one-sided accuracy tests show no significant improvement.
The corrected expanding-window estimates do not reproduce 5% significance
for the selected Neely volume signals in 1966–2011, so the results do not
show that predictability later disappeared. At h=1, forecast-based
mean-variance utility differences are negative; the LASSO switching
strategy has lower terminal wealth and only modestly smaller drawdown than
buy-and-hold.

## Section by section

**Abstract & Introduction.** Sets up the puzzle (Goyal–Welch: nothing beats
the historical average) and states our three findings: (1) no model beats
the benchmark on the extended sample, (2) the corrected time-aligned
Neely estimates are not significant at 5% for selected volume signals, and
(3) the h=1 economic strategy results do not show positive utility gains.
*Skeptic's question:* "So you found nothing?" → Answer: the results are
negative under the stated out-of-sample design; they do not prove that the
original paper's results were wrong.

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

**Section 4.1 — Statistical results.** All model R² point estimates are
negative, ranging from −15.49% to −0.38% across horizons. The lowest
one-sided DM p-value is 0.677, so the tests do not show significant
improvement over the benchmark; they also do not establish that the models
are significantly worse. Hit rates are close to the prevailing-mean rates
(53.5–60.1% versus 59.7–59.9%).
*Skeptic's question:* "Does a negative R² prove statistical inferiority?" →
No; it is a relative point-estimate measure. The reported tests do not show
significant improvement.

**Section 4.2 — Replication.** With predictors dated before their target
returns, the selected 1966–2011 volume estimates are +0.19%, +0.11%, and
+0.53%; their Clark–West p-values are 0.193, 0.247, and 0.077. None is
significant at 5%. The selected extension estimates are negative and
insignificant. This timing-corrected analysis does not reproduce the
published significance.
*Skeptic's question:* "Maybe the signal data are wrong?" → The computed
signal series match 99.98% of published signal-months; matching the signal
series does not imply reproducing the regression results.

**Section 4.3 — Economic value.** At h=1, the LASSO switching strategy
ends with $232.7 per dollar invested versus $341.9 for buy-and-hold, with
maximum drawdown −44.4% versus −50.2% and Sharpe 0.767 versus 0.776.
Mean-variance ΔU is negative for every forecast model at the reported fee
levels (LASSO −0.39% p.a. at 10 bps).
*Skeptic's question:* "Do these outcomes establish economic value?" → No;
they are sample strategy outcomes, and the measured h=1 utility differences
are negative.

**Section 4.4 — Sample comparisons.** Subperiod and predictor-set results
are descriptive; they cannot identify why forecast performance differs.
The analysis does not test explanations involving crises, passive flows, or
arbitrage speed.

**Conclusion.** The corrected analysis does not reproduce the selected
volume-signal significance and finds no point-forecast or h=1 mean-variance
utility improvement over the benchmark. Limitations include the US-only
sample, monthly data, and the specified transaction-cost model.

**Appendix.** A1 compares full, technical-only, and macro-only predictors;
all nine h=1 out-of-sample R² estimates are negative for each set. The
Clark–West values are reported as a nested-model check.

---

## The 3 numbers to have in your head for Q&A
- **99.98%** — the computed technical signals match the published signal series.
- **−15.49% to −0.38%** — the full-sample range of model R² point estimates across horizons.
- **−0.39% p.a.** — h=1 LASSO mean-variance ΔU at 10 bps; it is negative.
