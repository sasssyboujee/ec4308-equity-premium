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
  stopifnot(nrow(oos) == n - w - 2L * h + 1L,
            all(is.finite(oos$forecast)))
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
  stopifnot(all(is.finite(cb$forecast)),
            identical(cb$target_index, F$target_index))
  cat(sprintf("combine-%-6s n_fc=%d NA=%d finite=%s sd(fc)=%.2f\n",
              m, nrow(cb), sum(is.na(cb$forecast)),
              all(is.finite(cb$forecast)), sd(cb$forecast, na.rm = TRUE)))
}

# benchmark alignment check: same target_index as prevailing_mean
pm <- prevailing_mean(y, h = h, w = w)
stopifnot(identical(results[[1]]$target_index, pm$target_index))

for (h in c(1L, 3L, 12L)) {
  for (fold in forward_folds(w, h)) {
    stopifnot(max(fold$train) + h <= min(fold$validation))
  }
  end <- w + 2L * h
  origin <- w + h
  changed_y <- y[seq_len(end)]
  changed_X <- X[seq_len(end), , drop = FALSE]
  changed_y[(origin + 1L):end] <- 1000
  changed_X[(origin + 1L):end, ] <- 1000
  for (nm in names(cands)) {
    a <- rolling_oos(y[seq_len(end)], X[seq_len(end), , drop = FALSE],
                     h = h, w = w, model_fn = cands[[nm]])
    b <- rolling_oos(changed_y, changed_X, h = h, w = w, model_fn = cands[[nm]])
    stopifnot(isTRUE(all.equal(a$forecast, b$forecast, tolerance = 1e-12)))
  }
}
constant_X <- matrix(0, w, p)
for (fn in cands) {
  stopifnot(isTRUE(all.equal(fn(y[seq_len(w)], constant_X,
                               constant_X[1L, , drop = FALSE]),
                            mean(y[seq_len(w)]))))
}
stopifnot(is.finite(ridge_forecast_fn(y[seq_len(w)],
                                     X[seq_len(w), 1L, drop = FALSE],
                                     X[1L, 1L, drop = FALSE])))
F_bad <- F
F_bad[1L, 2L] <- NA_real_
stopifnot(inherits(try(combine_forecasts(F_bad, y), silent = TRUE), "try-error"))
rank_deficient <- cbind(X[1:60, 1], X[1:60, 1], X[1:60, 2])
weights <- gr_weights(rank_deficient, y[1:60])
stopifnot(all(is.finite(weights)), all(weights >= 0),
          abs(sum(weights) - 1) < 1e-8)
near_collinear <- cbind(rank_deficient, rank_deficient[, 1L] + 1e-8,
                       rank_deficient[, 3L] - 1e-8)
rounded <- matrix(as.numeric(format(near_collinear, digits = 15L,
                                    scientific = TRUE)),
                  nrow = nrow(near_collinear))
for (history in list(near_collinear, rounded)) {
  weights <- gr_weights(history, y[1:60])
  stopifnot(all(is.finite(weights)), all(weights >= 0),
            abs(sum(weights) - 1) < 1e-12)
}
for (h in c(1L, 3L, 12L)) {
  known <- F$target_index[50L] - h
  altered <- y
  altered[(known + 1L):length(y)] <- 1e6
  a <- combine_forecasts(F, y, "gr", gr_min_history = 30L, h = h)
  b <- combine_forecasts(F, altered, "gr", gr_min_history = 30L, h = h)
  stopifnot(isTRUE(all.equal(a$forecast[1:50], b$forecast[1:50])))
}
cat("\nAll model functions executed without error. Smoke test passed.\n")
