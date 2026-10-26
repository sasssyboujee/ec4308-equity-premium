# =============================================================================
# 01_rolling_window.R -- Fixed-width rolling out-of-sample forecast harness
# =============================================================================
# Standard scheme per Goyal & Welch (2008) / Neely et al. (2014) and Prof.
# Denis's feedback: estimate each model on a FIXED window of W months,
# produce an h-month-ahead forecast, roll the window forward one month, repeat.
#
# Alignment convention (IMPORTANT -- read before using):
#   * y[t]    = return / equity premium EARNED in month t.
#   * X[t, ]  = predictors OBSERVABLE at the END of month t (Leon's lagged
#               panel must already be aligned this way).
#   * The forecast for month t+h is made at the end of month t using only
#     y[1..t] and X[1..t]; nothing from months t+1 .. t+h is ever used.
#
# Output: data.frame(target_index, forecast) where target_index is the index
# of the month being forecast. Identical alignment to prevailing_mean() so
# the two are directly comparable in the Diebold-Mariano test.
# =============================================================================

rolling_oos <- function(y, X, h = 1L, w = 240L, model_fn, ...) {
  T <- length(y)
  stopifnot(
    is.matrix(X) || is.data.frame(X),
    nrow(X) == T,
    w >= 10L, w + h <= T,
    is.function(model_fn)
  )

  origins    <- seq.int(w, T - h)   # index of the last month in each training window
  target_idx <- origins + h         # index of the month being forecast
  n_oos      <- length(origins)
  fc         <- rep(NA_real_, n_oos)

  for (i in seq_len(n_oos)) {
    o     <- origins[i]
    tr    <- seq.int(o - w + 1L, o)              # training rows
    X_new <- X[o, , drop = FALSE]                # predictors known at end of month o
    fc[i] <- as.numeric(model_fn(y = y[tr], X = X[tr, , drop = FALSE],
                                 X_new = X_new,
                                 origin = o, target_index = target_idx[i],
                                 ...))
  }

  data.frame(target_index = target_idx, forecast = fc)
}

# -----------------------------------------------------------------------------
# Toy OLS model -- for plumbing tests ONLY.
# OLS is used here purely to validate the harness. Per Prof. Denis, OLS is
# NOT an admissible benchmark for the paper: the benchmark is the Prevailing
# Mean (see 02_prevailing_mean.R). Replace with En Shao's model functions
# (rlasso, ridge, PCR, PLS, random forest, ...) once they exist.
# A model_fn must accept (y, X, X_new, ...) and return ONE numeric forecast.
# -----------------------------------------------------------------------------
ols_forecast_fn <- function(y, X, X_new, ...) {
  fit <- stats::lm.fit(x = cbind(1, as.matrix(X)), y = as.matrix(y))
  as.numeric(cbind(1, as.matrix(X_new)) %*% fit$coefficients)
}
