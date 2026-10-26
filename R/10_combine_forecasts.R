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
# This is the same information set as recursive in-window combination, but
# computed after the base runs; results are identical and the code is
# simpler to audit (no lookahead: verified by construction and asserted).
#
# `F` is a data.frame with columns `target_index` and one column per base
# model (rows ordered by target_index). `y_full` is the full target vector
# (indexed by target_index). Returns a data.frame(target_index, forecast).
# =============================================================================

suppressMessages(library(limSolve))

gr_weights <- function(Fm, yh) {
  # Fm: history matrix of base forecasts (rows = known targets),
  # yh: actuals for those targets. Solves constrained GR; NULL on failure.
  K <- ncol(Fm)
  tryCatch(
    limSolve::lsei(A = Fm, B = yh,
                   E = matrix(1, 1, K), F = 1,
                   G = diag(K), H = rep(0, K))$X,
    error = function(e) NULL
  )
}

combine_forecasts <- function(F, y_full, method = c("equal", "gr"),
                              gr_min_history = 60L, h = 1L) {
  method <- match.arg(method)
  stopifnot("target_index" %in% names(F))
  tgt <- F$target_index
  Fc <- as.matrix(F[, setdiff(names(F), "target_index"), drop = FALSE])
  K <- ncol(Fc)
  stopifnot(K >= 2L, all(tgt >= 1L & tgt <= length(y_full)),
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
          if (!is.null(sol) && all(is.finite(sol))) w <- sol
        }
      }
    }
    ok_i <- !is.na(Fc[i, ])
    out[i] <- sum(w[ok_i] * Fc[i, ok_i]) / sum(w[ok_i])
  }
  data.frame(target_index = tgt, forecast = out)
}
