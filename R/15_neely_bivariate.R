# =============================================================================
# 15_neely_bivariate.R -- Neely et al. (2014) bivariate replication (h = 1)
# =============================================================================
# Neely et al. forecast the premium with ONE technical indicator at a time:
#
#     r_{t+1} = a + b * S_t + e_t          (S_t in {0,1})
#
# estimated on the same fixed 240-month rolling window as the main models,
# then combine the 14 bivariate forecasts with the equal-weight average and
# a constrained Granger-Ramanathan regression. This is the design in which
# the original paper finds technical indicators beat the prevailing mean;
# we re-run it on the extended 1971-2025 out-of-sample period.
#
# Output: data/processed/forecasts_h1_neely_biv.csv (14 signal forecasts +
#         equal/gr combinations) and output/tables/table4_h1.csv (accuracy
#         vs prevailing mean: R2_OOS, DM RMSE, CW).
# Usage (repo root):  Rscript R/15_neely_bivariate.R
# =============================================================================

source("R/00_config.R")
source("R/01_rolling_window.R")
source("R/02_prevailing_mean.R")
source("R/03_diebold_mariano.R")
source("R/12_clark_west.R")
source("R/10_combine_forecasts.R")

panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)
y <- panel[[CONFIG$TARGET]]
S <- as.matrix(panel[, CONFIG$TECHNICAL_NAMES])
h <- 1L; w <- CONFIG$W_ROLLING

# bivariate OLS model_fn: r_{t+1} = a + b * s_t
biv_fn <- function(which_sig) {
  force(which_sig)
  function(y, X, X_new, ...) {
    s  <- X[, which_sig]
    sN <- X_new[, which_sig]
    fit <- stats::lm.fit(x = cbind(1, s), y = y)
    as.numeric(cbind(1, sN) %*% fit$coefficients)
  }
}

out <- data.frame(target_index = rolling_oos(y, S, h = h, w = w,
                                             model_fn = biv_fn(1L))$target_index)
out$date <- panel$date[out$target_index]

for (i in seq_along(CONFIG$TECHNICAL_NAMES)) {
  oos <- rolling_oos(y, S, h = h, w = w, model_fn = biv_fn(i))
  out[[CONFIG$TECHNICAL_NAMES[i]]] <- oos$forecast
}

pm <- prevailing_mean(y, h = h, w = w)
out$pm <- pm$forecast

F <- out[, c("target_index", CONFIG$TECHNICAL_NAMES)]
out$equal_comb <- combine_forecasts(F, y, method = "equal", h = h)$forecast
out$gr_comb    <- combine_forecasts(F, y, method = "gr",
                                    gr_min_history = w / 4L, h = h)$forecast

write.csv(out, file.path(CONFIG$DATA_PROCESSED, "forecasts_h1_neely_biv.csv"),
          row.names = FALSE)

# accuracy table vs prevailing mean ------------------------------------------
idx <- out$target_index; actual <- y[idx]
rows <- lapply(c(CONFIG$TECHNICAL_NAMES, "equal_comb", "gr_comb"), function(nm) {
  f <- out[[nm]]
  e <- actual - f; epm <- actual - pm$forecast
  r2 <- 100 * (1 - sum(e^2) / sum(epm^2))
  dm <- dm_test(actual, f, pm$forecast, power = 2L, h = h, alternative = "less")
  cw <- cw_test(actual, pm$forecast, f, h = h)
  data.frame(predictor = nm, RMSE = sqrt(mean(e^2)),
             R2_OOS_pct = round(r2, 3),
             DM_RMSE_stat = round(dm$statistic, 3),
             DM_RMSE_p = round(dm$p.value, 4),
             CW_stat = round(cw$statistic, 3),
             CW_p = round(cw$p.value, 4))
})
tab4 <- do.call(rbind, rows)
write.csv(tab4, file.path(CONFIG$OUTPUT_TABLES, "table4_h1.csv"), row.names = FALSE)
print(tab4, row.names = FALSE)
