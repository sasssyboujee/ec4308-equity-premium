# =============================================================================
# 04_switching_strategy.R -- Binary Switching Strategy backtest
# =============================================================================
# Economic evaluation #1 (per Prof. Denis's directive).
# At the end of each month t:
#   * if the forecast of the premium for the target month is POSITIVE,
#     hold 100% S&P 500 for that month;
#   * otherwise hold 100% 3-month T-bills.
# Start in cash; charge the first equity purchase and subsequent switches.
# No terminal liquidation is assumed.
# Each forecast is aligned to its target month's one-month return. The
# portfolio is rebalanced monthly; an h-step forecast is formed h months
# before the month whose return it predicts.
#
# Alignment (IMPORTANT): forecast[t] must be the h-month-ahead forecast of
# the premium EARNED in month t, made with information through month t-h.
# For h = 1, use the output of rolling_oos()/prevailing_mean() directly.
#
# UNITS: equity_ret, tbill_ret and forecast are in PERCENT per month --
# obtained as 100*ret and 100*Rfree from the raw workbook.
#
# Reported: terminal wealth, buy-and-hold terminal wealth, annualized
# Sharpe, max drawdown, number of switches, average equity exposure.
# =============================================================================

monthly_asset_returns <- function(gw, dates) {
  stopifnot(all(c("date", "ret", "Rfree") %in% names(gw)),
            !anyNA(gw$date), !anyDuplicated(gw$date), !anyNA(dates),
            !anyDuplicated(dates))
  idx <- match(as.Date(dates), as.Date(gw$date))
  if (anyNA(idx)) stop("Portfolio dates are missing from the source workbook.",
                       call. = FALSE)
  equity <- 100 * gw$ret[idx]
  cash <- 100 * gw$Rfree[idx]
  stopifnot(all(is.finite(equity)), all(is.finite(cash)),
            all(equity > -100), all(cash > -100))
  list(equity = equity, cash = cash)
}

switching_backtest <- function(equity_ret, tbill_ret, forecast,
                               fee_bps = 10, periods_per_year = 12) {
  n <- length(forecast)
  stopifnot(is.numeric(forecast), is.numeric(equity_ret), is.numeric(tbill_ret),
            length(equity_ret) == n, length(tbill_ret) == n, n >= 2L,
            all(is.finite(forecast)), all(is.finite(equity_ret)),
            all(is.finite(tbill_ret)), all(equity_ret > -100),
            all(tbill_ret > -100), length(fee_bps) == 1L,
            is.finite(fee_bps), fee_bps >= 0,
            length(periods_per_year) == 1L, is.finite(periods_per_year),
            periods_per_year > 0)

  r_eq <- equity_ret / 100                     # percent -> decimal
  r_tb <- tbill_ret / 100
  fee  <- fee_bps / 1e4                        # bps -> decimal

  in_equity <- forecast > 0
  pos       <- as.numeric(in_equity)           # 1 = equity, 0 = T-bill
  switches  <- c(pos[1L] != 0, diff(pos) != 0)
  ret       <- ifelse(in_equity, r_eq, r_tb) - switches * fee
  if (any(ret <= -1)) stop("Switching portfolio loses its entire capital.",
                           call. = FALSE)

  wealth <- cumprod(1 + ret)
  excess <- ret - r_tb                         # strategy return over risk-free
  # A constant excess-return series has no defined Sharpe ratio.
  sharpe <- if (stats::sd(excess) == 0) NA_real_ else
    mean(excess) / stats::sd(excess) * sqrt(periods_per_year)
  max_dd <- min(wealth / cummax(c(1, wealth))[-1L] - 1)

  bh_ret <- r_eq
  bh_ret[1L] <- bh_ret[1L] - fee
  if (any(bh_ret <= -1)) stop("Buy-and-hold portfolio loses its entire capital.",
                             call. = FALSE)
  bh_wealth <- cumprod(1 + bh_ret)

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
