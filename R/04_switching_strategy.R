# =============================================================================
# 04_switching_strategy.R -- Binary Switching Strategy backtest
# =============================================================================
# Economic evaluation #1 (per Prof. Denis's directive).
# At the end of each month t:
#   * if the h-month-ahead forecast of the equity premium is POSITIVE,
#     hold 100% S&P 500 for month t+1;
#   * otherwise hold 100% 3-month T-bills.
# A transaction cost of fee_bps is paid whenever the position switches.
# (With h = 1 the forecast made at the end of month t-1 drives the position
# that earns the month-t return; h > 1 requires overlapping-position logic
# that we add when running the h = 3, 12 economic evaluations.)
#
# Alignment (IMPORTANT): forecast[t] must be the h-month-ahead forecast of
# the premium EARNED in month t, made with information through month t-h.
# For h = 1, use the output of rolling_oos()/prevailing_mean() directly.
#
# UNITS: equity_ret, tbill_ret and forecast are in PERCENT per month --
# exactly as stored in Goyal's raw data (ret, tbl columns). The function
# converts to decimals internally for compounding.
#
# Reported: terminal wealth, buy-and-hold terminal wealth, annualized
# Sharpe, max drawdown, number of switches, average equity exposure.
# =============================================================================

switching_backtest <- function(equity_ret, tbill_ret, forecast,
                               fee_bps = 10, periods_per_year = 12) {
  n <- length(forecast)
  stopifnot(length(equity_ret) == n, length(tbill_ret) == n, n >= 2L)

  r_eq <- equity_ret / 100                     # percent -> decimal
  r_tb <- tbill_ret / 100
  fee  <- fee_bps / 1e4                        # bps -> decimal

  in_equity <- !is.na(forecast) & forecast > 0
  pos       <- as.numeric(in_equity)           # 1 = equity, 0 = T-bill
  switches  <- c(FALSE, diff(pos) != 0)
  ret       <- ifelse(in_equity, r_eq, r_tb) - switches * fee

  wealth <- cumprod(1 + ret)
  excess <- ret - r_tb                         # strategy return over risk-free
  sharpe <- mean(excess) / stats::sd(excess) * sqrt(periods_per_year)
  max_dd <- min(wealth / cummax(wealth) - 1)

  bh_wealth <- cumprod(1 + r_eq)               # buy-and-hold equity benchmark

  list(
    returns              = ret,
    wealth               = wealth,
    terminal_wealth      = wealth[n],
    terminal_wealth_bh   = bh_wealth[n],
    sharpe_annual        = sharpe,
    max_drawdown         = max_dd,
    n_switches           = sum(switches),
    fee_bps              = fee_bps,
    equity_exposure      = mean(pos)
  )
}
