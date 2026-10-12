# =============================================================================
# 05_mv_utility.R -- Mean-variance investor utility (CER gain, Delta U)
# =============================================================================
# Economic evaluation #2, per Campbell & Thompson (2008) / Neely et al.
# (2014) and the proposal draft:
#
#   w_t = (1 / gamma) * forecast_t / sigma2_hat_t,  clamped to [w_min, w_max]
#
# The investor allocates w_t to equities and (1 - w_t) to T-bills.
# sigma2_hat_t = realized variance of equity returns over the previous
# VAR_WINDOW months (information available at time t - h).
#
# Delta U = annualized CER(strategy) - CER(benchmark allocation driven by
# the Prevailing Mean forecast). CER = mean(r) - (gamma/2) * var(r).
#
# UNITS for mv_utility_gain(): equity_ret / tbill_ret / forecast /
# forecast_benchmark are in PERCENT per month and sigma2_hat is in
# PERCENT-squared (Goyal raw-data convention). Internals (mv_weights,
# mv_portfolio_returns, annualized_cer) use decimals; returned CERs are
# decimals per annum (multiply by 100 for percent p.a.).
# =============================================================================

mv_weights <- function(forecast, sigma2_hat, gamma = 3, w_min = 0, w_max = 1.5) {
  # DECIMAL inputs: forecast (per month) and sigma2_hat (variance per month)
  stopifnot(length(forecast) == length(sigma2_hat))
  w <- (1 / gamma) * (forecast / sigma2_hat)
  pmin(w_max, pmax(w_min, w))
}

mv_portfolio_returns <- function(weights, equity_ret, tbill_ret, fee_bps = 10) {
  # DECIMAL returns in, decimal strategy returns out (fees on turnover)
  n <- length(weights)
  stopifnot(length(equity_ret) == n, length(tbill_ret) == n)
  fee <- fee_bps / 1e4
  dw  <- c(weights[1], diff(weights))             # first trade enters the position
  weights * equity_ret + (1 - weights) * tbill_ret - abs(dw) * fee
}

annualized_cer <- function(ret, gamma, periods_per_year = 12) {
  # DECIMAL returns -> decimal CER per annum
  (mean(ret) - (gamma / 2) * var(ret)) * periods_per_year
}

mv_utility_gain <- function(equity_ret, tbill_ret, forecast, forecast_benchmark,
                            sigma2_hat, gamma = 3, w_min = 0, w_max = 1.5,
                            fee_bps = 10, periods_per_year = 12) {
  n <- length(forecast)
  stopifnot(length(equity_ret) == n, length(tbill_ret) == n,
            length(forecast_benchmark) == n, length(sigma2_hat) == n)

  # convert from Goyal percent convention to decimals
  r_eq <- equity_ret / 100
  r_tb <- tbill_ret / 100
  f    <- forecast / 100
  f_b  <- forecast_benchmark / 100
  s2   <- sigma2_hat / 10000                    # percent^2 -> decimal^2

  w_model <- mv_weights(f, s2, gamma, w_min, w_max)
  w_bench <- mv_weights(f_b, s2, gamma, w_min, w_max)

  r_model <- mv_portfolio_returns(w_model, r_eq, r_tb, fee_bps)
  r_bench <- mv_portfolio_returns(w_bench, r_eq, r_tb, fee_bps)

  cer_model <- annualized_cer(r_model, gamma, periods_per_year)
  cer_bench <- annualized_cer(r_bench, gamma, periods_per_year)

  list(
    weights        = w_model,
    returns        = r_model,
    cer_model      = cer_model,
    cer_benchmark  = cer_bench,
    delta_U        = cer_model - cer_bench,
    sharpe_model   = mean(r_model - r_tb) / stats::sd(r_model - r_tb) *
                     sqrt(periods_per_year),
    mean_equity_wt = mean(w_model),
    gamma          = gamma,
    fee_bps        = fee_bps
  )
}

rolling_variance <- function(x, window = 60L) {
  # Realized variance over the PREVIOUS `window` observations, aligned so
  # that value t uses x[(t-window) .. (t-1)] -- only past information.
  # Input units are preserved (percent -> percent^2).
  n <- length(x)
  out <- rep(NA_real_, n)
  if (n <= window) return(out)
  for (t in (window + 1L):n) {
    out[t] <- var(x[(t - window):(t - 1L)])
  }
  out
}
