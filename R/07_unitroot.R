# =============================================================================
# 07_unitroot.R -- Augmented Dickey-Fuller test (base R, transparent)
# =============================================================================
# Standard OLS-based ADF regression with intercept and linear trend,
# lag length chosen by BIC over 0..LAGS_MAX:
#
#     dY[t] = a + b*t + (rho-1)*Y[t-1] + sum_{k=1..p} g_k * dY[t-k] + e[t]
#
# H0: rho = 1 (unit root). The statistic is the t-statistic on (rho-1).
# Critical values are MacKinnon (2010), asymptotic, for one series with
# intercept and optional trend; significance is a bin, not an exact p-value.
# Reference coefficients: statsmodels/tsa/adfvalues.py, tau_*_2010 (N=1).
# =============================================================================

adf_test <- function(x, lags_max = 12L, trend = TRUE) {
  x <- as.numeric(x)
  T <- length(x)
  stopifnot(all(is.finite(x)), length(lags_max) == 1L,
            is.finite(lags_max), lags_max >= 0L,
            lags_max == as.integer(lags_max),
            length(trend) == 1L, is.logical(trend), !is.na(trend))
  if (T - 1L - lags_max < 30L || stats::var(x) == 0) {
    stop("adf_test needs a varying series and at least 30 common observations.",
         call. = FALSE)
  }
  dy <- diff(x)

  best <- list(bic = Inf, p = 0L, stat = NA_real_)
  for (p in 0:lags_max) {
    idx <- seq.int(lags_max + 1L, T - 1L)
    n_eff <- length(idx)
    X <- data.frame(intercept = 1, y1 = x[idx])
    if (trend) X$trend <- idx
    if (p > 0) {
      for (k in seq_len(p)) X[[paste0("dy", k)]] <- dy[idx - k]
    }
    yv <- dy[idx]
    fit <- stats::lm.fit(y = yv, x = as.matrix(X))
    if (fit$rank != ncol(X)) stop("adf_test regression is rank deficient.")
    res <- yv - as.matrix(X) %*% fit$coefficients
    sig2 <- sum(res^2) / n_eff
    bic <- log(sig2) + ncol(X) * log(n_eff) / n_eff
    if (bic < best$bic) {
      se <- sqrt(diag(sum(res^2) / (n_eff - ncol(X)) *
                        chol2inv(chol(crossprod(as.matrix(X))))))
      stat <- fit$coefficients["y1"] / se[which(names(X) == "y1")]
      best <- list(bic = bic, p = p, stat = as.numeric(stat))
    }
  }

  critical <- if (trend) c(-3.95877, -3.41049, -3.12705) else
    c(-3.43035, -2.86154, -2.56677)
  sig <- if (best$stat < critical[1L]) "1%" else
    if (best$stat < critical[2L]) "5%" else
    if (best$stat < critical[3L]) "10%" else ">10%"

  list(statistic = best$stat, lag_order = best$p, bic = best$bic,
       critical_10pct = critical[3L], critical_5pct = critical[2L],
       critical_1pct = critical[1L], significance = sig, nobs = n_eff,
       trend = trend)
}
