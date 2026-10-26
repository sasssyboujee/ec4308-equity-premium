# =============================================================================
# 09_run_models.R -- rolling OOS forecasts for all models x horizons
# =============================================================================
# Runs the Prevailing Mean benchmark and the seven ML models through the
# fixed 240-month rolling harness at h = 1, 3, 12 on the real panel, then
# computes the two forecast combinations (1/N equal weight, constrained
# Granger-Ramanathan) as post-hoc combiners.
#
# Output (one wide CSV per horizon):
#   data/processed/forecasts_h1.csv  columns: target_index, date, pm,
#                                    rlasso, postlasso, ridge, enet, pcr,
#                                    pls, rf, equal_comb, gr_comb
#
# Parallelized over (horizon, model) with parallel::mclapply; every model
# is deterministic (fixed seeds, num.threads = 1 for ranger), so re-runs
# reproduce identical outputs.
#
# Usage (repo root):  Rscript R/09_run_models.R [n_cores]
# =============================================================================

args <- commandArgs(trailingOnly = TRUE)
n_cores <- if (length(args) >= 1L) as.integer(args[1]) else
  min(6L, parallel::detectCores() - 1L)

source("R/00_config.R")
source("R/01_rolling_window.R")
source("R/02_prevailing_mean.R")
source("R/08_models.R")
source("R/10_combine_forecasts.R")

panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)
y <- panel[[CONFIG$TARGET]]
X <- as.matrix(panel[, setdiff(names(panel), c("date", CONFIG$TARGET))])

cat(sprintf("Panel: %d rows | X: %d columns | running on %d cores\n",
            nrow(panel), ncol(X), n_cores))

BASE <- c("rlasso", "postlasso", "ridge", "enet", "pcr", "pls", "rf")
fn <- list(
  rlasso    = rlasso_forecast_fn,
  postlasso = postlasso_forecast_fn,
  ridge     = ridge_forecast_fn,
  enet      = enet_forecast_fn,
  pcr       = pcr_forecast_fn,
  pls       = plsr_forecast_fn,
  rf        = rf_forecast_fn
)

t_start <- Sys.time()
for (h in CONFIG$HORIZONS) {
  cat(sprintf("\n=== h = %d ===\n", h))
  jobs <- lapply(BASE, function(nm) list(h = h, nm = nm))
  res <- parallel::mclapply(jobs, function(jb) {
    t0 <- Sys.time()
    oos <- rolling_oos(y, X, h = jb$h, w = CONFIG$W_ROLLING,
                       model_fn = fn[[jb$nm]])
    list(nm = jb$nm, oos = oos,
         secs = as.numeric(difftime(Sys.time(), t0, units = "secs")))
  }, mc.cores = n_cores)

  out <- data.frame(target_index = res[[1]]$oos$target_index)
  out$date <- panel$date[out$target_index]
  for (r in res) {
    out[[r$nm]] <- r$oos$forecast
    cat(sprintf("  %-10s NA=%d  (%0.1fs)\n", r$nm,
                sum(is.na(r$oos$forecast)), r$secs))
  }

  # benchmark (not parallelized; it is instantaneous)
  pm <- prevailing_mean(y, h = h, w = CONFIG$W_ROLLING)
  stopifnot(identical(pm$target_index, out$target_index))
  out$pm <- pm$forecast

  # combinations over the base models only (pm is the benchmark, not a member)
  F <- out[, c("target_index", BASE)]
  out$equal_comb <- combine_forecasts(F, y_full = y, method = "equal",
                                      h = h)$forecast
  out$gr_comb    <- combine_forecasts(F, y_full = y, method = "gr",
                                      gr_min_history = CONFIG$W_ROLLING / 4L,
                                      h = h)$forecast

  dest <- file.path(CONFIG$DATA_PROCESSED, sprintf("forecasts_h%d.csv", h))
  write.csv(out, dest, row.names = FALSE)
  cat(sprintf("Wrote: %s (%d OOS months)\n", dest, nrow(out)))
}

cat(sprintf("\nTotal wall time: %0.1f min\n",
            as.numeric(difftime(Sys.time(), t_start, units = "mins"))))
