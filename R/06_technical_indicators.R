# =============================================================================
# 06_technical_indicators.R -- Neely et al. (2014) technical indicators
# =============================================================================
# Reproduces the 14 binary technical indicator signals of Neely, Rapach, Tu &
# Zhou (2014, Management Science 60(7), 1772-1791):
#
#   MA(j,m):  1 if SMA(j) of the S&P 500 index level > SMA(m) of the index,
#             j in {1,2,3}, m in {9,12}                       (6 signals)
#   MOM(m):   1 if index level > index level m months ago, m in {9,12}   (2)
#   VOL(j,m): 1 if SMA(j) of on-balance volume > SMA(m) of on-balance volume,
#             j in {1,2,3}, m in {9,12}                       (6 signals)
#
# On-balance volume: OBV[t] = OBV[t-1] + volume[t] * sign(price[t]-price[t-1]).
# The VOL signals are invariant to any CONSTANT rescaling of volume, because
# they compare moving averages of the same OBV series.
#
# VALIDATION (reproducible via data/03_validate_signals.R):
# against the published signals of Neely et al. (1950-12 .. 2011-12, 733
# months), 12 of the 14 signals match 100% and the other 2 match 99.9%
# (one month each: MOM_12 at 1968-03, VOL_2_9 at 1980-04).
# =============================================================================

# Simple moving average (trailing, sides = 1): SMA(k)[t] = mean(x[t-k+1..t]).
sma_trail <- function(x, k) {
  stats::filter(x, rep(1 / k, k), sides = 1)
}

# Cumulative on-balance volume from a start index. Returns NA before `start`.
obv_series <- function(price, volume, start) {
  n <- length(price)
  obv <- rep(NA_real_, n)
  obv[start] <- volume[start] * sign(price[start] - price[start - 1])
  if (n > start) {
    for (t in (start + 1):n) {
      obv[t] <- obv[t - 1] + volume[t] * sign(price[t] - price[t - 1])
    }
  }
  obv
}

# Full set of 14 signals. `price` and `volume` are monthly vectors of equal
# length. `vol_start` is the index of the first month with volume data (the
# row from which OBV accumulates). Returns a data.frame with columns
# MA_j_m, MOM_m, VOL_j_m (binary 0/1; NA where undefined).
neely_signals <- function(price, volume, vol_start) {
  n <- length(price)
  stopifnot(length(volume) == n, vol_start >= 2L, vol_start <= n)

  out <- list()
  # --- moving average rules (use index level only) ---------------------------
  for (j in 1:3) {
    for (m in c(9, 12)) {
      out[[sprintf("MA_%d_%d", j, m)]] <-
        as.integer(sma_trail(price, j) > sma_trail(price, m))
    }
  }
  # --- momentum rules ---------------------------------------------------------
  for (m in c(9, 12)) {
    lagged <- c(rep(NA_real_, m), head(price, -m))
    out[[sprintf("MOM_%d", m)]] <- as.integer(price > lagged)
  }
  # --- on-balance volume rules ------------------------------------------------
  obv <- obv_series(price, volume, start = vol_start)
  for (j in 1:3) {
    for (m in c(9, 12)) {
      out[[sprintf("VOL_%d_%d", j, m)]] <-
        as.integer(sma_trail(obv, j) > sma_trail(obv, m))
    }
  }
  as.data.frame(out)
}
