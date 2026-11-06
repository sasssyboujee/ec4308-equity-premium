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
# Uses parallel::mclapply where supported; Windows runs one core because
# forked workers are unavailable. Models are deterministic, so outputs match.
#
# Usage (repo root):  Rscript R/09_run_models.R [n_cores]
# =============================================================================

source("R/00_config.R")
source("R/01_rolling_window.R")
source("R/02_prevailing_mean.R")
source("R/08_models.R")
source("R/10_combine_forecasts.R")

args <- commandArgs(trailingOnly = TRUE)
requested_cores <- if (length(args) >= 1L) as.numeric(args[1]) else 6L
if (!is.finite(requested_cores) || requested_cores < 1L ||
    requested_cores != as.integer(requested_cores)) {
  stop("n_cores must be a positive integer.", call. = FALSE)
}
detected_cores <- parallel::detectCores()
if (is.na(detected_cores)) detected_cores <- 1L
max_cores <- if (.Platform$OS.type == "windows") 1L else
  max(1L, min(6L, detected_cores - 1L))
n_cores <- min(requested_cores, max_cores)
spec <- if (length(args) >= 2L) args[2] else "full"
hs <- if (length(args) >= 3L) as.numeric(strsplit(args[3], ",")[[1]]) else CONFIG$HORIZONS
stopifnot(length(hs) >= 1L, !anyNA(hs), all(hs %in% CONFIG$HORIZONS),
          !anyDuplicated(hs))
hs <- as.integer(hs)
panel_file <- if (length(args) >= 4L) args[4] else
  file.path(CONFIG$DATA_PROCESSED, "panel.csv")
out_suffix <- if (length(args) >= 5L) args[5] else
  (if (spec == "full") "" else paste0("_", spec))

panel <- read.csv(panel_file)
panel$date <- as.Date(panel$date)
stopifnot(!anyNA(panel$date), !anyDuplicated(panel$date),
          identical(panel$date, seq(min(panel$date), max(panel$date), by = "month")),
          all(is.finite(as.matrix(panel[, -1L]))))
y <- panel[[CONFIG$TARGET]]

# predictor-set variants (spec argument):
#   full  -> 84 macro-lag columns + 14 technical signals (baseline design)
#   tech  -> 14 technical signals only (Neely et al. 2014 bivariate-style set)
#   macro -> 84 macro-lag columns only
macro_cols <- setdiff(names(panel),
                      c("date", CONFIG$TARGET, CONFIG$TECHNICAL_NAMES))
tech_cols <- CONFIG$TECHNICAL_NAMES
spec_cols <- switch(spec,
  full  = c(macro_cols, tech_cols),
  tech  = tech_cols,
  macro = macro_cols,
  stop("Unknown spec: ", spec)
)
X <- as.matrix(panel[, spec_cols])


cat(sprintf("Panel: %d rows | spec=%s | X: %d columns | %d cores | h in %s\n",
            nrow(panel), spec, ncol(X), n_cores, paste(hs, collapse = ",")))
if (n_cores < requested_cores) {
  cat(sprintf("Using %d core(s); this platform supports at most %d here.\n",
              n_cores, max_cores))
}

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
for (h in hs) {
  cat(sprintf("\n=== h = %d ===\n", h))
  jobs <- lapply(BASE, function(nm) list(h = h, nm = nm))
  res <- parallel::mclapply(jobs, function(jb) {
    t0 <- Sys.time()
    oos <- rolling_oos(y, X, h = jb$h, w = CONFIG$W_ROLLING,
                       model_fn = fn[[jb$nm]])
    list(nm = jb$nm, oos = oos,
         secs = as.numeric(difftime(Sys.time(), t0, units = "secs")))
  }, mc.cores = n_cores)
  if (any(vapply(res, inherits, logical(1), "try-error"))) {
    stop("A forecast worker failed; forecasts were not saved.", call. = FALSE)
  }

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

  dest <- file.path(CONFIG$DATA_PROCESSED,
                    sprintf("forecasts_h%d%s.csv", h, out_suffix))
  write.csv(out, dest, row.names = FALSE)
  cat(sprintf("Wrote: %s (%d OOS months)\n", dest, nrow(out)))
}

if (out_suffix == "_expanded") {
  summary_rows <- lapply(hs, function(h) {
    fc <- read.csv(file.path(CONFIG$DATA_PROCESSED,
                            sprintf("forecasts_h%d_expanded.csv", h)))
    actual <- y[fc$target_index]
    models <- c(BASE, "equal_comb", "gr_comb")
    data.frame(model = models, spec = sprintf("expanded (%d cols)", ncol(X)),
               horizon = h, R2_OOS_pct = round(vapply(models, function(nm) {
                 100 * (1 - sum((actual - fc[[nm]])^2) /
                          sum((actual - fc$pm)^2))
               }, numeric(1)), 3))
  })
  write.csv(do.call(rbind, summary_rows),
            file.path(CONFIG$DATA_PROCESSED, "expanded_variant_summary.csv"),
            row.names = FALSE)
}

cat(sprintf("\nTotal wall time: %0.1f min\n",
            as.numeric(difftime(Sys.time(), t_start, units = "mins"))))
