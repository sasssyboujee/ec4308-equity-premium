# =============================================================================
# 08_models.R -- ML forecasting models for the rolling-window harness
# =============================================================================
# Every model must follow the harness API (see R/01_rolling_window.R):
#
#     model_fn(y, X, X_new, ...)  ->  ONE numeric forecast for month t+h
#
# where y and X are the TRAINING rows only and X_new is the single row of
# predictors observable at the end of month t. All functions here are pure:
# they only use the data they are handed (no lookahead, no global state),
# except the forecast-combination ensembles, which use past OOS forecast
# errors via an explicit closure (see make_ensemble_fn below).
#
# Models (per the approved design):
#   rlasso_forecast_fn        LASSO via hdm::rlasso (theoretical penalty, no CV)
#   postlasso_forecast_fn     Post-LASSO: OLS refit on the selected support
#   ridge_forecast_fn         Ridge (glmnet, lambda by 10-fold CV in-window)
#   enet_forecast_fn          Elastic Net (glmnet, alpha = 0.5)
#   pcr_forecast_fn           Principal Components Regression (pls::pcr)
#   pls_forecast_fn           Partial Least Squares (pls::plsr)
#   rf_forecast_fn            Random Forest (ranger; fixed seed, 1 thread)
#   (+ ensembles live in R/10_combine_forecasts.R as post-hoc combiners)
# =============================================================================

suppressMessages({
  library(hdm)
  library(glmnet)
  library(pls)
  library(ranger)
})

# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

# Drop zero-variance columns (rlasso/glmnet fail on constants) and give
# columns safe unique names. Returns the cleaned training matrix and the
# matching X_new row.
clean_X <- function(X, X_new) {
  X <- as.matrix(X)
  keep <- apply(X, 2L, function(v) length(unique(v)) > 1L)
  Xc <- X[, keep, drop = FALSE]
  Xn <- as.matrix(X_new)[, keep, drop = FALSE]
  colnames(Xc) <- make.unique(if (is.null(colnames(Xc))) {
    paste0("V", seq_len(ncol(Xc)))
  } else {
    colnames(Xc)
  })
  colnames(Xn) <- colnames(Xc)
  list(X = Xc, X_new = Xn)
}

# -----------------------------------------------------------------------------
# 1. LASSO / Post-LASSO (hdm)
# -----------------------------------------------------------------------------
rlasso_forecast_fn <- function(y, X, X_new, post = FALSE, ...) {
  cl <- clean_X(X, X_new)
  fit <- hdm::rlasso(x = cl$X, y = as.numeric(y), post = post)
  # coefficients: named vector, first element "(Intercept)".
  # (Manual computation = identical to hdm's predict method, but transparent.)
  as.numeric(fit$coefficients[1L] + cl$X_new %*% fit$coefficients[-1L])
}

postlasso_forecast_fn <- function(y, X, X_new, ...) {
  rlasso_forecast_fn(y, X, X_new, post = TRUE, ...)
}

# -----------------------------------------------------------------------------
# 2. Ridge / Elastic Net (glmnet, lambda.min from 10-fold CV inside the window)
# -----------------------------------------------------------------------------
glmnet_forecast_fn <- function(y, X, X_new, alpha = 0, seed = 4308L, ...) {
  cl <- clean_X(X, X_new)
  set.seed(seed)                       # deterministic CV folds
  fit <- glmnet::cv.glmnet(x = cl$X, y = as.numeric(y), alpha = alpha,
                           nfolds = 10L)
  b <- as.numeric(stats::coef(fit, s = "lambda.min"))   # first = intercept
  as.numeric(b[1L] + cl$X_new %*% b[-1L])
}

ridge_forecast_fn <- function(y, X, X_new, ...) {
  glmnet_forecast_fn(y, X, X_new, alpha = 0, ...)
}

enet_forecast_fn <- function(y, X, X_new, ...) {
  glmnet_forecast_fn(y, X, X_new, alpha = 0.5, ...)
}

# -----------------------------------------------------------------------------
# 3. PCR / PLS (pls package, 10-fold CV for the number of components)
# -----------------------------------------------------------------------------
pls_forecast_fn <- function(y, X, X_new, method = c("pcr", "plsr"),
                            seed = 4308L, ...) {
  method <- match.arg(method)
  cl <- clean_X(X, X_new)
  n <- nrow(cl$X); p <- ncol(cl$X)
  nmax <- min(20L, p, n - 1L)
  d <- as.data.frame(cl$X)
  d$y <- as.numeric(y)
  set.seed(seed)                       # deterministic CV segments
  fit <- if (method == "pcr") {
    pls::pcr(y ~ ., data = d, ncomp = nmax, validation = "CV",
             segments = min(10L, n), scale = TRUE)
  } else {
    pls::plsr(y ~ ., data = d, ncomp = nmax, validation = "CV",
              segments = min(10L, n), scale = TRUE)
  }
  k <- which.min(fit$validation$PRESS)
  pred <- stats::predict(fit, newdata = as.data.frame(cl$X_new), ncomp = k)
  as.numeric(pred)[1]
}

pcr_forecast_fn <- function(y, X, X_new, ...) {
  pls_forecast_fn(y, X, X_new, method = "pcr", ...)
}

plsr_forecast_fn <- function(y, X, X_new, ...) {
  pls_forecast_fn(y, X, X_new, method = "plsr", ...)
}

# -----------------------------------------------------------------------------
# 4. Random Forest (ranger)
# -----------------------------------------------------------------------------
rf_forecast_fn <- function(y, X, X_new, num.trees = 500L,
                           mtry = NULL, seed = 4308L, ...) {
  cl <- clean_X(X, X_new)
  p <- ncol(cl$X)
  if (is.null(mtry)) mtry <- max(1L, floor(p / 3L))
  fit <- ranger::ranger(y = as.numeric(y), x = cl$X,
                        num.trees = num.trees, mtry = mtry,
                        min.node.size = 5L,
                        seed = seed, num.threads = 1L)
  as.numeric(stats::predict(fit, data = cl$X_new)$predictions)
}

# -----------------------------------------------------------------------------
# 5. Forecast combinations: simple 1/N average and constrained
#    Granger-Ramanathan. Implemented as POST-HOC combiners over the saved
#    base-forecast matrix in R/10_combine_forecasts.R (mathematically the
#    same as recursive in-window combination, but faster and easier to audit:
#    the weights at origin o use only base forecasts of targets <= o, whose
#    errors are known at o -- no lookahead).
# -----------------------------------------------------------------------------

# Convenience registry used by the runner -------------------------------------
model_registry <- function() {
  list(
    prevailing_mean = NULL,               # handled by R/02, not a model_fn
    rlasso         = rlasso_forecast_fn,
    postlasso      = postlasso_forecast_fn,
    ridge          = ridge_forecast_fn,
    enet           = enet_forecast_fn,
    pcr            = pcr_forecast_fn,
    pls            = plsr_forecast_fn,
    rf             = rf_forecast_fn
  )
}
