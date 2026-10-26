# =============================================================================
# 98_smoke_models.R -- fast sanity check of every model function
# =============================================================================
# Synthetic data (n = 150, p = 12) run through the rolling harness with a
# small window so every model_fn is exercised many times. Not for results --
# only to catch API/plumbing errors before the expensive real-data run.
# Usage (repo root):  Rscript R/98_smoke_models.R
# =============================================================================

source("R/00_config.R")
source("R/01_rolling_window.R")
source("R/02_prevailing_mean.R")
source("R/08_models.R")
source("R/10_combine_forecasts.R")

set.seed(4308)
n <- 150; p <- 12
X <- matrix(rnorm(n * p), n, p)
colnames(X) <- paste0("V", seq_len(p))
# two of the columns are pure 0/1 signals (like the technical indicators)
X[, 11] <- rbinom(n, 1, 0.5)
X[, 12] <- rbinom(n, 1, 0.7)
y <- as.vector(X %*% c(0.2, 0.1, -0.15, rep(0, 9)) + rnorm(n, sd = 3))

w <- 60L; h <- 1L
cands <- list(
  rlasso    = rlasso_forecast_fn,
  postlasso = postlasso_forecast_fn,
  ridge     = ridge_forecast_fn,
  enet      = enet_forecast_fn,
  pcr       = pcr_forecast_fn,
  pls       = plsr_forecast_fn,
  rf        = function(y, X, X_new, ...) rf_forecast_fn(y, X, X_new, num.trees = 50L, ...)
)

results <- list()
for (nm in names(cands)) {
  t0 <- Sys.time()
  oos <- rolling_oos(y, X, h = h, w = w, model_fn = cands[[nm]])
  dt <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
  na_n <- sum(is.na(oos$forecast))
  results[[nm]] <- oos
  cat(sprintf("%-10s n_fc=%d NA=%d finite=%s  sd(fc)=%.2f  (%ss)\n",
              nm, nrow(oos), na_n, all(is.finite(oos$forecast)),
              sd(oos$forecast, na.rm = TRUE), dt))
}

# ensembles (post-hoc combiners over the saved base forecasts) --------------
F <- data.frame(target_index = results[[1]]$target_index)
for (nm in names(cands)) F[[nm]] <- results[[nm]]$forecast
for (m in c("equal", "gr")) {
  cb <- combine_forecasts(F, y_full = y, method = m, gr_min_history = 30L, h = 1L)
  cat(sprintf("combine-%-6s n_fc=%d NA=%d finite=%s sd(fc)=%.2f\n",
              m, nrow(cb), sum(is.na(cb$forecast)),
              all(is.finite(cb$forecast)), sd(cb$forecast, na.rm = TRUE)))
}

# benchmark alignment check: same target_index as prevailing_mean
pm <- prevailing_mean(y, h = h, w = w)
stopifnot(identical(results[[1]]$target_index, pm$target_index))
cat("\nAll model functions executed without error. Smoke test passed.\n")
