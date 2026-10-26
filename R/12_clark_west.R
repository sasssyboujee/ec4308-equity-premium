# =============================================================================
# 12_clark_west.R -- Clark & West (2007) adjusted MSPE test (APPENDIX only)
# =============================================================================
# The DM test is the project's primary test (Prof. Denis's directive);
# Clark-West is reported as an appendix check for NESTED comparisons
# (every model is nested in the Prevailing Mean, which is a regression on
# a constant only). H0: equal MSPE; H1 (one-sided): the model has smaller
# MSPE than the benchmark.
#
# Adjusted loss differential (CW 2007, eq. 2.3):
#     f_t = (y_t - f1_t)^2 - [ (y_t - f2_t)^2 - (f1_t - f2_t)^2 ]
# with f1 = benchmark forecast, f2 = alternative (model) forecast.
# The test statistic is the HAC-robust t-statistic of mean(f) (Newey-West,
# lag = h - 1), compared against standard normal critical values.
# =============================================================================

source("R/03_diebold_mariano.R")   # for hac_var_mean

cw_test <- function(actual, f_benchmark, f_model, h = 1L) {
  stopifnot(length(actual) == length(f_benchmark),
            length(actual) == length(f_model))
  f <- (actual - f_benchmark)^2 -
       ((actual - f_model)^2 - (f_benchmark - f_model)^2)
  T <- length(f)
  if (T < 2L) stop("CW test needs at least 2 observations.", call. = FALSE)
  stat <- mean(f) / sqrt(hac_var_mean(f, lag = h - 1L))
  p <- stats::pnorm(stat, lower.tail = FALSE)   # one-sided: model better
  structure(list(statistic = stat, p.value = p, n = T, horizon = h,
                 mean_adjusted_diff = mean(f),
                 h0 = "equal MSPE (nested)"),
            class = "cw_test")
}

print.cw_test <- function(x, ...) {
  cat("Clark-West (2007) adjusted MSPE test (HAC lag", x$horizon - 1L, ")\n")
  cat("  CW statistic:", format(x$statistic, digits = 4), "\n")
  cat("  p-value (one-sided, model better):", format(x$p.value, digits = 4), "\n")
  cat("  n:", x$n, "\n")
  invisible(x)
}
