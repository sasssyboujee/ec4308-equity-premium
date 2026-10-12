# =============================================================================
# 02_prevailing_mean.R -- Goyal-Welch Historical Prevailing Mean benchmark
# =============================================================================
# The ONLY admissible benchmark for this project (Prof. Denis: OLS fails
# out-of-sample; the Prevailing Mean is the benchmark to beat).
#
#   Y_hat[t+h | t] = (1 / t) * sum_{s = 1}^{t} Y_s
#
# The forecast is an EXPANDING mean of all history through month t, exactly
# as in Goyal & Welch (2008). The parameter `w` does not change the
# benchmark value -- it only aligns the evaluation sample with the
# rolling-window models so that Diebold-Mariano comparisons use identical
# out-of-sample months.
# =============================================================================

prevailing_mean <- function(y, h = 1L, w = 240L) {
  T <- length(y)
  stopifnot(w + h <= T, w >= 1L)

  origins    <- seq.int(w, T - h)
  target_idx <- origins + h
  fc <- vapply(origins, function(o) mean(y[seq_len(o)]), numeric(1))

  data.frame(target_index = target_idx, forecast = fc)
}
