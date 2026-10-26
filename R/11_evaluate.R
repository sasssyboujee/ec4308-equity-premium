# =============================================================================
# 11_evaluate.R -- OOS evaluation: Table 2 (accuracy + DM/CW), Table 3 (economic)
# =============================================================================
# Reads the per-horizon forecast CSVs produced by R/09_run_models.R and
# writes:
#   output/tables/table2_h{1,3,12}.csv  -- RMSE/MAE, R2_OOS (Campbell-
#       Thompson 2008), Diebold-Mariano (RMSE & MAE basis, one-sided),
#       Clark-West (appendix check) of every model vs the Prevailing Mean.
#   output/tables/table3_h{1,3,12}.csv  -- Binary Switching Strategy
#       (terminal wealth, Sharpe, max drawdown, switches, equity exposure)
#       and Mean-Variance utility (CER, Delta U, mean weight, Sharpe) at
#       10 bps, with 5/20 bps sensitivity columns.
#
# Economic-evaluation timing: for month t the investor uses the most recent
# h-month-ahead forecast of y[t] (made at origin t-h); positions/weights are
# recomputed every month. At h = 1 this is exactly the Neely et al. (2014)
# timing.
#
# Usage (repo root):  Rscript R/11_evaluate.R
# =============================================================================

args <- commandArgs(trailingOnly = TRUE)
hs <- if (length(args) >= 1L) as.integer(args) else CONFIG$HORIZONS

suppressMessages({library(readxl)})
source("R/00_config.R")
source("R/03_diebold_mariano.R")
source("R/04_switching_strategy.R")
source("R/05_mv_utility.R")
source("R/12_clark_west.R")

panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)
y <- panel[[CONFIG$TARGET]]

gw <- as.data.frame(read_excel(
  file.path(CONFIG$DATA_RAW, "GoyalWelchZafirov_PredictorData.xlsx"),
  sheet = "Monthly"
))
gw$date <- as.Date(sprintf("%06d01", gw$yyyymm), "%Y%m%d")
gw <- gw[order(gw$date), ]
m <- match(panel$date, gw$date)
equity_ret_pct <- 100 * gw$ret[m]            # total return incl. dividends, % per month
tbill_ret_pct  <- gw$tbl[m] / 12             # t-bill rate, % per month
sigma2_hat_pct2 <- rolling_variance(equity_ret_pct, window = CONFIG$VAR_WINDOW)

MODELS <- c("rlasso", "postlasso", "ridge", "enet", "pcr", "pls", "rf",
            "equal_comb", "gr_comb")

for (h in hs) {
  fc <- read.csv(file.path(CONFIG$DATA_PROCESSED,
                           sprintf("forecasts_h%d.csv", h)))
  idx <- fc$target_index
  actual <- y[idx]

  # ---- Table 2: statistical accuracy ---------------------------------------
  rows <- lapply(MODELS, function(nm) {
    f <- fc[[nm]]
    e <- actual - f; epm <- actual - fc$pm
    r2oos <- 100 * (1 - sum(e^2) / sum(epm^2))
    dm2 <- dm_test(actual, f1 = f, f2 = fc$pm, power = 2L, h = h,
                   alternative = "less")
    dm1 <- dm_test(actual, f1 = f, f2 = fc$pm, power = 1L, h = h,
                   alternative = "less")
    cw  <- cw_test(actual, f_benchmark = fc$pm, f_model = f, h = h)
    data.frame(
      model = nm, horizon = h,
      RMSE = sqrt(mean(e^2)), RMSE_pm = sqrt(mean(epm^2)),
      MAE = mean(abs(e)), MAE_pm = mean(abs(epm)),
      R2_OOS_pct = round(r2oos, 3),
      HR = round(mean(sign(f) == sign(actual)), 3),        # direction of change
      HR_pm = round(mean(sign(fc$pm) == sign(actual)), 3),
      DM_RMSE_stat = round(dm2$statistic, 3), DM_RMSE_p = round(dm2$p.value, 4),
      DM_MAE_stat = round(dm1$statistic, 3), DM_MAE_p = round(dm1$p.value, 4),
      CW_stat = round(cw$statistic, 3), CW_p = round(cw$p.value, 4)
    )
  })
  tab2 <- do.call(rbind, rows)

  # benchmark row (for the table footnote)
  e_pm <- actual - fc$pm
  cat(sprintf("\n=== h=%d | n OOS = %d | RMSE(pm)=%.3f MAE(pm)=%.3f ===\n",
              h, length(actual), sqrt(mean(e_pm^2)), mean(abs(e_pm))))

  # ---- Table 3: economic value ---------------------------------------------
  eq_r <- equity_ret_pct[idx]; tb_r <- tbill_ret_pct[idx]
  s2 <- sigma2_hat_pct2[idx]
  econ <- lapply(MODELS, function(nm) {
    f <- fc[[nm]]; fpm <- fc$pm
    sw10 <- switching_backtest(eq_r, tb_r, f, fee_bps = 10)
    sw5  <- switching_backtest(eq_r, tb_r, f, fee_bps = 5)
    sw20 <- switching_backtest(eq_r, tb_r, f, fee_bps = 20)
    mv10 <- mv_utility_gain(eq_r, tb_r, f, fpm, s2,
                            gamma = CONFIG$GAMMA, w_min = CONFIG$W_MIN,
                            w_max = CONFIG$W_MAX, fee_bps = 10)
    mv5  <- mv_utility_gain(eq_r, tb_r, f, fpm, s2,
                            gamma = CONFIG$GAMMA, w_min = CONFIG$W_MIN,
                            w_max = CONFIG$W_MAX, fee_bps = 5)
    mv20 <- mv_utility_gain(eq_r, tb_r, f, fpm, s2,
                            gamma = CONFIG$GAMMA, w_min = CONFIG$W_MIN,
                            w_max = CONFIG$W_MAX, fee_bps = 20)
    data.frame(
      model = nm, horizon = h,
      sw_wealth_5bps = round(sw5$terminal_wealth, 3),
      sw_wealth_10bps = round(sw10$terminal_wealth, 3),
      sw_wealth_20bps = round(sw20$terminal_wealth, 3),
      sw_wealth_bh = round(sw10$terminal_wealth_bh, 3),
      sw_sharpe_10bps = round(sw10$sharpe_annual, 3),
      sw_maxdd_10bps = round(sw10$max_drawdown, 4),
      sw_switches = sw10$n_switches,
      sw_eq_exposure = round(sw10$equity_exposure, 3),
      mv_deltaU_5bps_pct = round(100 * mv5$delta_U, 2),
      mv_deltaU_10bps_pct = round(100 * mv10$delta_U, 2),
      mv_deltaU_20bps_pct = round(100 * mv20$delta_U, 2),
      mv_cer_model_10bps_pct = round(100 * mv10$cer_model, 2),
      mv_sharpe_10bps = round(mv10$sharpe_model, 3),
      mv_mean_w = round(mv10$mean_equity_wt, 3)
    )
  })
  tab3 <- do.call(rbind, econ)

  # ---- reference rows: buy-and-hold and the PM-driven strategies -------------
  bh <- switching_backtest(eq_r, tb_r, rep(1, length(eq_r)), fee_bps = 10)
  sw_pm <- switching_backtest(eq_r, tb_r, fc$pm, fee_bps = 10)
  mv_pm <- mv_utility_gain(eq_r, tb_r, fc$pm, fc$pm, s2,
                           gamma = CONFIG$GAMMA, w_min = CONFIG$W_MIN,
                           w_max = CONFIG$W_MAX, fee_bps = 10)
  ref_rows <- rbind(
    data.frame(model = "Buy-and-Hold", horizon = h,
      sw_wealth_5bps = NA, sw_wealth_10bps = bh$terminal_wealth,
      sw_wealth_20bps = NA, sw_wealth_bh = bh$terminal_wealth_bh,
      sw_sharpe_10bps = round(bh$sharpe_annual, 3),
      sw_maxdd_10bps = round(bh$max_drawdown, 4),
      sw_switches = 0, sw_eq_exposure = 1,
      mv_deltaU_5bps_pct = NA, mv_deltaU_10bps_pct = NA,
      mv_deltaU_20bps_pct = NA, mv_cer_model_10bps_pct = NA,
      mv_sharpe_10bps = NA, mv_mean_w = NA),
    data.frame(model = "Prevailing Mean", horizon = h,
      sw_wealth_5bps = NA, sw_wealth_10bps = round(sw_pm$terminal_wealth, 3),
      sw_wealth_20bps = NA, sw_wealth_bh = round(sw_pm$terminal_wealth_bh, 3),
      sw_sharpe_10bps = round(sw_pm$sharpe_annual, 3),
      sw_maxdd_10bps = round(sw_pm$max_drawdown, 4),
      sw_switches = sw_pm$n_switches, sw_eq_exposure = round(sw_pm$equity_exposure, 3),
      mv_deltaU_5bps_pct = 0, mv_deltaU_10bps_pct = 0, mv_deltaU_20bps_pct = 0,
      mv_cer_model_10bps_pct = round(100 * mv_pm$cer_model, 2),
      mv_sharpe_10bps = round(mv_pm$sharpe_model, 3),
      mv_mean_w = round(mv_pm$mean_equity_wt, 3))
  )
  tab3 <- rbind(tab3, ref_rows)

  write.csv(tab2, file.path(CONFIG$OUTPUT_TABLES, sprintf("table2_h%d.csv", h)),
            row.names = FALSE)
  write.csv(tab3, file.path(CONFIG$OUTPUT_TABLES, sprintf("table3_h%d.csv", h)),
            row.names = FALSE)
  cat("Wrote:", file.path(CONFIG$OUTPUT_TABLES, sprintf("table2_h%d.csv", h)),
      "and", sprintf("table3_h%d.csv", h), "\n")
  print(tab2[, c("model", "RMSE", "R2_OOS_pct", "DM_RMSE_p", "DM_MAE_p")],
        row.names = FALSE)
}

cat("\nEvaluation complete.\n")
