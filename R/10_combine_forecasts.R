# =============================================================================
# 10_combine_forecasts.R -- forecast combinations (1/N and Granger-Ramanathan)
# =============================================================================
# Post-hoc combiners over a matrix of base-model OOS forecasts.
#
# Constrained Granger-Ramanathan (per the approved design): at each OOS
# month (target) o+h, the combination weights solve
#
#     min_w  || y - F w ||^2   s.t.   sum(w) = 1,  w >= 0          (lsei)
#
# using ONLY base forecasts of targets <= o -- i.e. forecast errors that
# are already known at the time the combination forecast is formed. Until
# `gr_min_history` usable observations exist, equal weights are used.
# Combination history expands over past OOS errors; it is not the fixed
# rolling estimation sample used to fit each base model.
#
# `F` is a data.frame with columns `target_index` and one column per base
# model (rows ordered by target_index). `y_full` is the full target vector
# (indexed by target_index). Returns a data.frame(target_index, forecast).
# =============================================================================

suppressMessages(library(limSolve))

gr_weights <- function(Fm, yh) {
  # Fm: history matrix of base forecasts (rows = known targets),
  # yh: actuals for those targets. Solves constrained GR or fails explicitly.
  K <- ncol(Fm)
  stopifnot(is.matrix(Fm), is.numeric(Fm), all(is.finite(Fm)),
            is.numeric(yh), all(is.finite(yh)), nrow(Fm) == length(yh))
  # Rank-deficient QP histories can accumulate constraint roundoff above sqrt(eps).
  tolerance <- 1e-7
  fit <- tryCatch(
    limSolve::lsei(A = Fm, B = yh,
                   E = matrix(1, 1, K), F = 1,
                   G = diag(K), H = rep(0, K), type = 2, tol = tolerance),
    error = function(e) stop(
      "Constrained Granger-Ramanathan fit failed: ",
      conditionMessage(e), call. = FALSE
    )
  )
  sol <- as.numeric(fit$X)
  if (isTRUE(fit$IsError) || length(sol) != K || any(!is.finite(sol)) ||
      any(sol < -tolerance) || abs(sum(sol) - 1) > tolerance) {
    stop("Constrained Granger-Ramanathan fit returned invalid weights.",
         call. = FALSE)
  }
  sol <- pmax(0, sol)
  sol / sum(sol)
}

combine_forecasts <- function(F, y_full, method = c("equal", "gr"),
                              gr_min_history = 60L, h = 1L) {
  method <- match.arg(method)
  stopifnot("target_index" %in% names(F))
  tgt <- F$target_index
  Fc <- as.matrix(F[, setdiff(names(F), "target_index"), drop = FALSE])
  K <- ncol(Fc)
  stopifnot(K >= 2L, nrow(Fc) >= 1L, is.numeric(Fc), all(is.finite(Fc)),
            is.numeric(y_full), all(is.finite(y_full)),
            all(tgt == as.integer(tgt)),
            length(h) == 1L, is.finite(h), h >= 1L, h == as.integer(h),
            length(gr_min_history) == 1L, is.finite(gr_min_history),
            gr_min_history >= 1L, gr_min_history == as.integer(gr_min_history),
            all(tgt > h & tgt <= length(y_full)),
            all(diff(tgt) == 1L))          # contiguous OOS targets

  n <- nrow(Fc)
  out <- rep(NA_real_, n)
  for (i in seq_len(n)) {
    # The forecast of target tgt[i] is formed at origin tgt[i] - h; only
    # targets <= that origin have known errors at formation time.
    o <- tgt[i] - h
    if (method == "equal") {
      w <- rep(1 / K, K)
    } else {
      w <- rep(1 / K, K)
      hist <- which(tgt <= o)              # errors known at origin o
      if (length(hist) >= gr_min_history) {
        Fh <- Fc[hist, , drop = FALSE]
        yh <- y_full[tgt[hist]]
        ok <- stats::complete.cases(Fh) & !is.na(yh)
        if (sum(ok) >= gr_min_history) {
          sol <- gr_weights(Fh[ok, , drop = FALSE], yh[ok])
          w <- sol
        }
      }
    }
    out[i] <- sum(w * Fc[i, ])
  }
  data.frame(target_index = tgt, forecast = out)
}
