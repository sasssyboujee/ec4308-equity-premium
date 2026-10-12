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
cat(sprintf("  Max drawdown: %.1f%%\n", 100 * sw$max_dd))
cat(sprintf("  Switches: %d | Avg equity exposure: %.0f%%\n",
            sw$n_switches, 100 * sw$equity_exposure))

# --- 4. Mean-variance investor (h = 1) ----------------------------------------
bench1 <- prevailing_mean(y, h = 1L, w = CONFIG$W_ROLLING)
sig2   <- rolling_variance(equity, CONFIG$VAR_WINDOW)[idx]   # percent^2 units

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
