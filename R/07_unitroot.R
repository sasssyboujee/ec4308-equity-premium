# =============================================================================
# 07_unitroot.R -- Augmented Dickey-Fuller test (base R, transparent)
# =============================================================================
# Standard OLS-based ADF regression with intercept and linear trend,
# lag length chosen by BIC over 0..LAGS_MAX:
#
#     dY[t] = a + b*t + (rho-1)*Y[t-1] + sum_{k=1..p} g_k * dY[t-k] + e[t]
#
# H0: rho = 1 (unit root). The statistic is the t-statistic on (rho-1).
# The 1/5/10% critical values are the MacKinnon (1996) asymptotic response
# surface values for the intercept+trend specification (-4.04/-3.45/-3.15);
# significance is reported as a bin against those values.
# =============================================================================

adf_test <- function(x, lags_max = 12L, trend = TRUE) {
  x <- as.numeric(x)
  T <- length(x)
  if (anyNA(x)) stop("adf_test: NAs in series")
  dy <- diff(x)

  best <- list(bic = Inf, p = 0L, stat = NA_real_)
  for (p in 0:lags_max) {
    n_eff <- T - 1 - p                  # usable observations after p lags
    if (n_eff < 30) next
    idx <- (p + 1):(T - 1)
    X <- data.frame(intercept = 1, trend = seq_len(n_eff), y1 = x[idx])
    if (p > 0) {
      for (k in seq_len(p)) X[[paste0("dy", k)]] <- dy[idx - k]
    }
    yv <- dy[idx]
    fit <- stats::lm.fit(y = yv, x = as.matrix(X))
    res <- yv - as.matrix(X) %*% fit$coefficients
    sig2 <- sum(res^2) / n_eff
    bic <- log(sig2) + ncol(X) * log(n_eff) / n_eff
    if (bic < best$bic) {
      se <- sqrt(diag(sig2 * chol2inv(chol(crossprod(as.matrix(X))))))
      stat <- fit$coefficients[3L] / se[3L]     # 3rd coefficient = y1 (rho-1)
      best <- list(bic = bic, p = p, stat = as.numeric(stat))
    }
  }

  sig <- if (is.na(best$stat)) NA_character_ else
    if (best$stat < -4.04) "1%" else
    if (best$stat < -3.45) "5%" else
    if (best$stat < -3.15) "10%" else ">10%"

  list(statistic = best$stat, lag_order = best$p, bic = best$bic,
       critical_10pct = -3.15, critical_5pct = -3.45, critical_1pct = -4.04,
       significance = sig, nobs = T)
}
