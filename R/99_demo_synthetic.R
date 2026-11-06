# =============================================================================
# 99_demo_synthetic.R -- end-to-end smoke test of the evaluation module
# =============================================================================
# Runs the full Sasi-owned pipeline on SYNTHETIC data so the harness can be
# validated before Leon's real data and En Shao's model forecasts arrive.
#
# Run from the repo root:
#     Rscript R/99_demo_synthetic.R
#
# Zero package dependencies: base R only.
# NOTE: the OLS model used here is a plumbing test ONLY -- the real models
# (rlasso, ridge, PCR, PLS, random forest) come from En Shao's scripts, and
# the benchmark against which everything is judged is the Prevailing Mean.
# =============================================================================

src <- function(f) source(file.path("R", f))
src("00_config.R")
src("01_rolling_window.R")
src("02_prevailing_mean.R")
src("03_diebold_mariano.R")
src("04_switching_strategy.R")
src("05_mv_utility.R")
src("07_unitroot.R")

must_fail <- function(expr) {
  stopifnot(inherits(try(force(expr), silent = TRUE), "try-error"))
}
must_fail(switching_backtest(c(1, 1), c(0, 0), c(NA_real_, 1)))
must_fail(mv_weights(1, 0))
must_fail(rolling_oos(1:30, matrix(1:30, ncol = 1), w = 10,
                      model_fn = function(...) c(1, 2)))
must_fail(rolling_oos(1:30, matrix(1:30, ncol = 1), w = 10,
                      model_fn = function(...) Inf))
entry <- switching_backtest(c(0, 0), c(0, 0), c(1, 1), fee_bps = 10)
stopifnot(abs(entry$terminal_wealth - 0.999) < 1e-12,
          entry$n_switches == 1L,
          entry$terminal_wealth == entry$terminal_wealth_bh,
          abs(prod(1 + mv_portfolio_returns(c(1, 1), c(0, 0), c(0, 0))) -
                entry$terminal_wealth) < 1e-12)
cash <- switching_backtest(c(1, 1), c(0.1, 0.1), c(-1, -1))
stopifnot(cash$n_switches == 0L, abs(cash$terminal_wealth - 1.001^2) < 1e-12,
          is.na(cash$sharpe_annual))
g <- data.frame(date = as.Date(c("2025-11-01", "2025-12-01")),
                ret = c(0.01, 0.02), Rfree = c(0.003, 0.0034),
                tbl = c(0.0378, 0.0359))
assets <- monthly_asset_returns(g, g$date)
stopifnot(isTRUE(all.equal(assets$equity, c(1, 2))),
          isTRUE(all.equal(assets$cash, c(0.3, 0.34))))

# Independent intercept-only Bartlett covariance matrix calculation.
a <- sin(seq_len(40)) + seq_len(40) / 30
f1 <- cos(seq_len(40)) / 3
f2 <- rep(0.2, 40)
for (h in c(1L, 3L, 12L)) for (power in 1:2) {
  d <- abs(a - f1)^power - abs(a - f2)^power
  distance <- abs(outer(seq_along(d), seq_along(d), "-"))
  kernel <- 1 - distance / h
  kernel[kernel < 0] <- 0
  variance <- drop(crossprod(d - mean(d), kernel %*% (d - mean(d)))) / length(d)^2
  reference <- mean(d) / sqrt(variance)
  test <- dm_test(a, f1, f2, power = power, h = h, alternative = "less")
  stopifnot(abs(test$statistic - reference) < 1e-10,
            abs(test$p.value - pnorm(reference)) < 1e-12)
}
stopifnot(dm_test(a, f1, f1)$p.value == 1)
must_fail(dm_test(a, f1, replace(f2, 1, NA_real_)))

# Check ADF t-statistics against stats::lm, not the implementation's SE code.
x <- sin(seq_len(100)) + cos(seq_len(100) / 4) + seq_len(100) / 100
for (trend in c(FALSE, TRUE)) {
  d <- data.frame(dy = diff(x), level = head(x, -1), time = 1:99)
  ref <- if (trend) lm(dy ~ level + time, d) else lm(dy ~ level, d)
  test <- adf_test(x, lags_max = 0L, trend = trend)
  stopifnot(abs(test$statistic - summary(ref)$coefficients["level", "t value"]) <
              1e-8, test$nobs == 99L)
}
must_fail(adf_test(rep(1, 100)))

# Training inputs must pair X[s] with y[s+h], using only targets observed at origin.
alignment_y <- seq_len(30L)
alignment_X <- matrix(101:130, ncol = 1L)
alignment_probe <- function(y, X, X_new, origin, ...) {
  if (origin == 12L) {
    stopifnot(isTRUE(all.equal(as.numeric(y), 3:12)))
    stopifnot(isTRUE(all.equal(as.numeric(X[, 1L]), 101:110)))
    stopifnot(isTRUE(all.equal(as.numeric(X_new[1L, 1L]), 112)))
  }
  0
}
aligned_oos <- rolling_oos(alignment_y, alignment_X, h = 2L, w = 10L,
                           model_fn = alignment_probe)
stopifnot(aligned_oos$target_index[1L] == 14L)

# A loss in the first period must be measured from initial wealth of 1.
first_loss <- switching_backtest(c(-10, 0), c(0, 0), c(1, 1), fee_bps = 0)
stopifnot(isTRUE(all.equal(first_loss$max_drawdown, -0.1)))

# Variance at an origin must not change when later returns change.
variance_probe <- c(1, 4, 2, 8, 7, 3)
variance_at_origin <- rolling_variance(variance_probe, window = 2L)[5L]
stopifnot(isTRUE(all.equal(variance_at_origin, var(variance_probe[3:4]))))
variance_probe[5:6] <- 1000
stopifnot(identical(
  variance_at_origin,
  rolling_variance(variance_probe, window = 2L)[5L]
))

set.seed(CONFIG$SEED)

cat("=== EC4308 evaluation-module smoke test (synthetic data) ===\n\n")

# --- 1. synthetic data (percent units, Goyal convention) ----------------------
T <- 600L                                   # 50 years of monthly data
P <- 8L                                     # predictors
# Persistent (AR(1)) predictors -- real macro predictors persist, which is
# what makes multi-horizon forecasting possible. Purely iid predictors would
# leave nothing to forecast beyond h = 1.
X <- matrix(0, T, P)
for (k in seq_len(P)) {
  X[, k] <- as.numeric(stats::arima.sim(model = list(ar = 0.9), n = T))
}
colnames(X) <- paste0("x", seq_len(P))
beta   <- c(0.9, -0.7, 0.5, 0.3, 0, 0, 0, -0.5)     # 4 predictors carry signal
# DGP mimics the real Goyal-Welch setup: month-t premium is predictable from
# the PREVIOUS month's predictors, i.e. signal[t] = X[t-1, ] %*% beta.
# (A contemporaneous DGP would be unforecastable without lookahead.)
signal <- c(0, as.numeric(X[seq_len(T - 1L), , drop = FALSE] %*% beta))

premium <- 0.10 + signal + stats::rnorm(T, sd = 2.0)   # monthly equity premium (%)
tbill   <- 0.04 + stats::rnorm(T, sd = 0.03)           # monthly T-bill return (%)
equity  <- premium + tbill                             # monthly S&P return (%)

y <- premium                                           # the target being forecast

# --- 2. rolling OOS forecasts for every horizon + DM tests --------------------
cat("Horizon |  n OOS  |   DM RMSE: stat / p    |   DM MAE: stat / p\n")
cat("--------|---------|-----------------------|----------------------\n")
for (h in CONFIG$HORIZONS) {
  oos_model <- rolling_oos(y, X, h = h, w = CONFIG$W_ROLLING,
                           model_fn = ols_forecast_fn)
  oos_bench <- prevailing_mean(y, h = h, w = CONFIG$W_ROLLING)
  stopifnot(identical(oos_model$target_index, oos_bench$target_index))
  stopifnot(oos_model$target_index[1L] == CONFIG$W_ROLLING + 2L * h)
  stopifnot(nrow(oos_model) == T - CONFIG$W_ROLLING - 2L * h + 1L)

  actual <- y[oos_model$target_index]
  dm2 <- dm_test(actual, oos_model$forecast, oos_bench$forecast,
                 power = 2, h = h, alternative = "less")
  dm1 <- dm_test(actual, oos_model$forecast, oos_bench$forecast,
                 power = 1, h = h, alternative = "less")
  cat(sprintf("  h = %2d | %7d | %9.3f / %.3f        | %9.3f / %.3f\n",
              h, length(actual), dm2$statistic, dm2$p.value,
              dm1$statistic, dm1$p.value))
}

# --- 3. Binary Switching Strategy (h = 1) -------------------------------------
oos1 <- rolling_oos(y, X, h = 1L, w = CONFIG$W_ROLLING, model_fn = ols_forecast_fn)
idx  <- oos1$target_index

sw <- switching_backtest(equity_ret = equity[idx], tbill_ret = tbill[idx],
                         forecast = oos1$forecast, fee_bps = CONFIG$FEE_BPS)
cat("\n--- Binary Switching Strategy (h = 1,", sw$fee_bps, "bps) ---\n")
cat(sprintf("  Terminal wealth: $%.2f  (buy-and-hold: $%.2f)\n",
            sw$terminal_wealth, sw$terminal_wealth_bh))
cat(sprintf("  Annualized Sharpe: %.3f\n", sw$sharpe_annual))
cat(sprintf("  Max drawdown: %.1f%%\n", 100 * sw$max_drawdown))
cat(sprintf("  Switches: %d | Avg equity exposure: %.0f%%\n",
            sw$n_switches, 100 * sw$equity_exposure))

# --- 4. Mean-variance investor (h = 1) ----------------------------------------
bench1 <- prevailing_mean(y, h = 1L, w = CONFIG$W_ROLLING)
sig2   <- rolling_variance(equity, CONFIG$VAR_WINDOW)[idx]  # includes the h=1 forecast-origin return

mv <- mv_utility_gain(equity_ret = equity[idx], tbill_ret = tbill[idx],
                      forecast = oos1$forecast,
                      forecast_benchmark = bench1$forecast,
                      sigma2_hat = sig2, gamma = CONFIG$GAMMA,
                      w_min = CONFIG$W_MIN, w_max = CONFIG$W_MAX,
                      fee_bps = CONFIG$FEE_BPS)
cat("\n--- Mean-Variance investor (gamma =", CONFIG$GAMMA, ") ---\n")
cat(sprintf("  CER (model) = %.2f%% | CER (prevailing mean) = %.2f%% | Delta U = %.2f%% p.a.\n",
            100 * mv$cer_model, 100 * mv$cer_benchmark, 100 * mv$delta_U))
cat(sprintf("  Mean equity weight: %.2f | Sharpe: %.3f\n",
            mv$mean_equity_wt, mv$sharpe_model))

cat("\nSmoke test finished without errors.\n")
