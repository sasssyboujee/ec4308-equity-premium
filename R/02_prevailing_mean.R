# =============================================================================
# 02_prevailing_mean.R -- Goyal-Welch Historical Prevailing Mean benchmark
# =============================================================================
# The ONLY admissible benchmark for this project (Prof. Denis: OLS fails
# out-of-sample; the Prevailing Mean is the benchmark to beat).
#
#   Y_hat[t+h | t] = (1 / t) * sum_{s = 1}^{t} Y_s
#
# The forecast is an EXPANDING mean of all history through month t, exactly
# as in Goyal & Welch (2008). The parameter `w` does not change the benchmark
# value. Its first origin is delayed by h months to align the evaluation
# sample with models trained on w valid X[s] -> y[s+h] pairs.
# =============================================================================

prevailing_mean <- function(y, h = 1L, w = 240L) {
  T <- length(y)
  stopifnot(is.numeric(y), all(is.finite(y)),
            length(w) == 1L, is.finite(w), w == as.integer(w),
            length(h) == 1L, is.finite(h), h == as.integer(h),
            w >= 1L, h >= 1L, w + 2L * h <= T)

  origins    <- seq.int(w + h, T - h)
  target_idx <- origins + h
  fc <- vapply(origins, function(o) mean(y[seq_len(o)]), numeric(1))

  data.frame(target_index = target_idx, forecast = fc)
}
