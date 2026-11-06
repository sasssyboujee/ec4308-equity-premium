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
# Forecast combinations use expanding past OOS errors in R/10.
#
# Models (per the approved design):
#   rlasso_forecast_fn        LASSO via hdm::rlasso (theoretical penalty, no CV)
#   postlasso_forecast_fn     Post-LASSO: OLS refit on the selected support
#   ridge_forecast_fn         Ridge (glmnet, forward validation in-window)
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
  X_new <- as.matrix(X_new)
  stopifnot(is.numeric(X), is.numeric(X_new), all(is.finite(X)),
            all(is.finite(X_new)), ncol(X_new) == ncol(X))
  keep <- apply(X, 2L, function(v) length(unique(v)) > 1L)
  Xc <- X[, keep, drop = FALSE]
  Xn <- as.matrix(X_new)[, keep, drop = FALSE]
  if (ncol(Xc) == 0L) return(list(X = Xc, X_new = Xn))
  colnames(Xc) <- make.unique(if (is.null(colnames(Xc))) {
    paste0("V", seq_len(ncol(Xc)))
  } else {
    colnames(Xc)
  })
  colnames(Xn) <- colnames(Xc)
  list(X = Xc, X_new = Xn)
}

forward_folds <- function(n, h = 1L) {
  stopifnot(length(h) == 1L, is.finite(h), h >= 1L, h == as.integer(h))
  first <- max(floor(n / 2L) + 1L, 20L + h)
  if (n - first + 1L < 3L) {
    stop("Too few observations for three chronological validation blocks.",
         call. = FALSE)
  }
  edges <- floor(seq(first, n + 1L, length.out = 4L))
  lapply(seq_len(3L), function(k) {
    list(train = seq_len(edges[k] - h),
         validation = seq.int(edges[k], edges[k + 1L] - 1L))
  })
}

# glmnet requires two columns even for a one-predictor regression.
glmnet_X <- function(X) {
  if (ncol(X) == 1L) cbind(X, .constant = 0) else X
}

# -----------------------------------------------------------------------------
# 1. LASSO / Post-LASSO (hdm)
# -----------------------------------------------------------------------------
rlasso_forecast_fn <- function(y, X, X_new, post = FALSE, ...) {
  cl <- clean_X(X, X_new)
  if (ncol(cl$X) == 0L || stats::var(y) == 0) return(mean(y))
  fit <- hdm::rlasso(x = cl$X, y = as.numeric(y), post = post)
  # coefficients: named vector, first element "(Intercept)".
  # (Manual computation = identical to hdm's predict method, but transparent.)
  b <- fit$coefficients
  if (all(b[-1L] == 0)) {
    # degenerate window: LASSO selected no variables -> hdm's forecast is
    # the intercept only (= mean(y) for post=FALSE); guard so we never
    # silently return 0. (Never triggered in production, added per audit.)
    return(as.numeric(fit$intercept))
  }
  as.numeric(b[1L] + cl$X_new %*% b[-1L])
}

postlasso_forecast_fn <- function(y, X, X_new, ...) {
  rlasso_forecast_fn(y, X, X_new, post = TRUE, ...)
}

# -----------------------------------------------------------------------------
# 2. Ridge / Elastic Net (three forward validation blocks)
# -----------------------------------------------------------------------------
glmnet_forecast_fn <- function(y, X, X_new, alpha = 0, h = 1L, ...) {
  cl <- clean_X(X, X_new)
  if (ncol(cl$X) == 0L || stats::var(y) == 0) return(mean(y))
  folds <- forward_folds(length(y), h)
  first <- folds[[1L]]$train
  initial <- clean_X(X[first, , drop = FALSE], X[first, , drop = FALSE])
  if (ncol(initial$X) == 0L || stats::var(y[first]) == 0) {
    stop("Initial tuning segment has no varying predictors or response.",
         call. = FALSE)
  }
  # The penalty grid itself must not use later validation observations.
  lambda <- glmnet::glmnet(glmnet_X(initial$X), y[first], alpha = alpha)$lambda
  loss <- rep(0, length(lambda))
  for (fold in folds) {
    tr <- fold$train; va <- fold$validation
    z <- clean_X(X[tr, , drop = FALSE], X[va, , drop = FALSE])
    if (ncol(z$X) == 0L || stats::var(y[tr]) == 0) {
      pred <- matrix(mean(y[tr]), length(va), length(lambda))
    } else {
      fit <- glmnet::glmnet(glmnet_X(z$X), y[tr], alpha = alpha, lambda = lambda)
      pred <- stats::predict(fit, newx = glmnet_X(z$X_new), s = lambda)
    }
    loss <- loss + colSums((y[va] - pred)^2)
  }
  chosen <- lambda[which.min(loss)]
  fit <- glmnet::glmnet(glmnet_X(cl$X), y, alpha = alpha, lambda = lambda)
  as.numeric(stats::predict(fit, newx = glmnet_X(cl$X_new), s = chosen))
}

ridge_forecast_fn <- function(y, X, X_new, ...) {
  glmnet_forecast_fn(y, X, X_new, alpha = 0, ...)
}

enet_forecast_fn <- function(y, X, X_new, ...) {
  glmnet_forecast_fn(y, X, X_new, alpha = 0.5, ...)
}

# -----------------------------------------------------------------------------
# 3. PCR / PLS (three forward validation blocks, including the intercept model)
# -----------------------------------------------------------------------------
pls_forecast_fn <- function(y, X, X_new, method = c("pcr", "plsr"),
                            h = 1L, ...) {
  method <- match.arg(method)
  cl <- clean_X(X, X_new)
  if (ncol(cl$X) == 0L || stats::var(y) == 0) return(mean(y))
  folds <- forward_folds(length(y), h)
  nmax <- min(20L, ncol(cl$X), vapply(folds, function(f) {
    z <- clean_X(X[f$train, , drop = FALSE], X[f$train, , drop = FALSE])
    if (ncol(z$X) == 0L) return(0L)
    qr(scale(z$X))$rank
  }, integer(1)))
  fit_model <- function(y, X, k) {
    d <- as.data.frame(X)
    d$y <- as.numeric(y)
    if (method == "pcr") {
      pls::pcr(y ~ ., data = d, ncomp = k, validation = "none", scale = TRUE)
    } else {
      pls::plsr(y ~ ., data = d, ncomp = k, validation = "none", scale = TRUE)
    }
  }
  if (nmax == 0L) return(mean(y))
  loss <- rep(0, nmax + 1L)
  for (fold in folds) {
    tr <- fold$train; va <- fold$validation
    z <- clean_X(X[tr, , drop = FALSE], X[va, , drop = FALSE])
    loss[1L] <- loss[1L] + sum((y[va] - mean(y[tr]))^2)
    if (stats::var(y[tr]) == 0) {
      loss[-1L] <- loss[-1L] + sum((y[va] - mean(y[tr]))^2)
    } else {
      fit <- fit_model(y[tr], z$X, nmax)
      pred <- stats::predict(fit, newdata = as.data.frame(z$X_new),
                             ncomp = seq_len(nmax))
      pred <- matrix(pred, nrow = length(va), ncol = nmax)
      loss[-1L] <- loss[-1L] + colSums((y[va] - pred)^2)
    }
  }
  k <- which.min(loss) - 1L
  if (k == 0L) return(mean(y))
  fit <- fit_model(y, cl$X, k)
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
  if (p == 0L || stats::var(y) == 0) return(mean(y))
  if (is.null(mtry)) mtry <- max(1L, floor(p / 3L))
  fit <- ranger::ranger(y = as.numeric(y), x = cl$X,
                        num.trees = num.trees, mtry = mtry,
                        min.node.size = 5L,
                        seed = seed, num.threads = 1L)
  as.numeric(stats::predict(fit, data = cl$X_new)$predictions)
}

# -----------------------------------------------------------------------------
# 5. Forecast combinations: simple 1/N average and constrained
#    Granger-Ramanathan. R/10 combines saved base forecasts using only
#    target errors known at the origin; its history is expanding.
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
