# =============================================================================
# 03_diebold_mariano.R -- Diebold-Mariano (1995) test of equal predictive
# accuracy, HAC (Newey-West) robust
# =============================================================================
# Loss differential:  d_t = |e1_t|^p - |e2_t|^p
#   p = 2  -> RMSE basis (squared-error loss)
#   p = 1  -> MAE basis (absolute-error loss)
#
# H0: E[d_t] = 0 (equal predictive accuracy)
# H1 (one-sided, "less"): E[d_t] < 0  ->  f1 is MORE accurate than f2
#
# The long-run variance of d_t is estimated with a Newey-West (Bartlett)
# kernel using lag = h - 1, because h-step-ahead forecast errors follow an
# MA(h-1) process. Implemented in base R so the evaluation module has zero
# package dependencies.
#
# Cross-check note: at h = 1 our statistic equals forecast::dm.test's up to
# the variance denominator (we use the T-normalized Newey-West convention;
# forecast uses the unbiased (T-1) variance at lag 0 -- a 0.08% difference
# at T = 659). At h > 1 the two implementations also differ by kernel
# weighting (we use Bartlett weights; forecast sums the raw
# autocovariances). Both are consistent HAC estimators; no inference in
# this project is affected (verified).
# =============================================================================

hac_var_mean <- function(x, lag = 0L) {
  # Newey-West variance of the SAMPLE MEAN of a series (LRV / T).
  T  <- length(x)
  xc <- x - mean(x)
  g0 <- sum(xc^2) / T
  if (lag <= 0L || T < lag + 1L) return(g0 / T)

  s <- 0
  for (k in seq_len(lag)) {
    gk <- sum(xc[(k + 1L):T] * xc[seq_len(T - k)]) / T
    s  <- s + (1 - k / (lag + 1)) * 2 * gk
  }
  (g0 + s) / T
}

dm_test <- function(actual, f1, f2, power = 2L, h = 1L,
                    alternative = c("two.sided", "less", "greater")) {
  alternative <- match.arg(alternative)
  stopifnot(length(actual) == length(f1), length(actual) == length(f2))

  e1 <- actual - f1
  e2 <- actual - f2
  d  <- abs(e1)^power - abs(e2)^power
  T  <- length(d)
  if (T < 2L) stop("DM test needs at least 2 observations.", call. = FALSE)

  dbar <- mean(d)
  if (all(d == 0)) {
    # identical forecasts: no loss differential, zero statistic
    stat <- 0
  } else {
    stat <- dbar / sqrt(hac_var_mean(d, lag = h - 1L))
  }

  p <- switch(
    alternative,
    two.sided = 2 * stats::pnorm(-abs(stat)),
    less      = stats::pnorm(stat),      # H1: f1 more accurate (d < 0)
    greater   = 1 - stats::pnorm(stat)   # H1: f2 more accurate (d > 0)
  )

  structure(
    list(statistic     = stat,
         p.value       = p,
         alternative   = alternative,
         loss          = if (power == 2L) "squared (RMSE basis)" else "absolute (MAE basis)",
         mean_loss_diff = dbar,
         n             = T,
         horizon       = h,
         h0            = "equal predictive accuracy"),
    class = "dm_test"
  )
}

print.dm_test <- function(x, ...) {
  cat("Diebold-Mariano test (HAC, Newey-West lag", x$horizon - 1L, ")\n")
  cat("  Loss:", x$loss, "\n")
  cat("  DM statistic:", format(x$statistic, digits = 4), "\n")
  cat("  p-value (", x$alternative, "): ", format(x$p.value, digits = 4),
      "\n", sep = "")
  cat("  n:", x$n, "| mean loss diff:", format(x$mean_loss_diff, digits = 4), "\n")
  invisible(x)
}
