# =============================================================================
# 16_neely_replication.R -- Neely et al. (2014) replication & extension
# =============================================================================
# Reproduces the original design of Neely et al. (2014): EXPANDING-window
# bivariate predictive regressions of the one-month-ahead premium on each of
# the 14 technical signals, benchmark = prevailing mean, Clark-West test.
# Their published sample: estimation start 1950-12 (R = 181), OOS 1966-01 ..
# 2011-12. Our panel starts 1951-02, so the replication window uses R = 179
# and OOS 1966-01 .. 2011-12 (identical OOS months, estimation window 11
# months shorter).
#
# Also reports the same design on the post-sample extension (2012-01 ..
# 2025-12) and on the pooled OOS (1966-01 .. 2025-12).
#
# Output: output/tables/table5_neely_replication.csv
# Usage (repo root):  Rscript R/16_neely_replication.R
# =============================================================================

source("R/00_config.R")
source("R/12_clark_west.R")

panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)
y <- panel[[CONFIG$TARGET]]
S <- as.matrix(panel[, CONFIG$TECHNICAL_NAMES])
T <- length(y)

R <- 179L                                  # 1951-02 .. 1965-12
origins <- seq.int(R, T - 1)
targets <- origins + 1
pm_fc <- vapply(origins, function(o) mean(y[1:o]), numeric(1))

run_bivariate <- function(k) {
  fc <- vapply(seq_along(origins), function(i) {
    o <- origins[i]; tr <- 1:o
    fit <- stats::lm.fit(x = cbind(1, S[tr, k]), y = y[tr])
    as.numeric(cbind(1, S[o, k]) %*% fit$coefficients)
  }, numeric(1))
  data.frame(target = targets, fc = fc, pm = pm_fc)
}

res <- lapply(seq_len(14), run_bivariate)

block <- function(name, from, to) {
  keep <- panel$date[targets] >= as.Date(from) &
          panel$date[targets] <= as.Date(to)
  rows <- lapply(seq_len(14), function(k) {
    d <- res[[k]][keep, ]
    actual <- y[d$target]
    e <- actual - d$fc; epm <- actual - d$pm
    r2 <- 100 * (1 - sum(e^2) / sum(epm^2))
    cw <- cw_test(actual, d$pm, d$fc, h = 1)
    data.frame(sample = name, signal = CONFIG$TECHNICAL_NAMES[k],
               n = sum(keep), R2_OOS_pct = round(r2, 3),
               CW_stat = round(cw$statistic, 3), CW_p = round(cw$p.value, 4))
  })
  do.call(rbind, rows)
}

tab5 <- rbind(
  block("Neely sample 1966-2011", "1966-01-01", "2011-12-01"),
  block("Extension 2012-2025",  "2012-01-01", "2025-12-01"),
  block("Pooled 1966-2025",     "1966-01-01", "2025-12-01")
)
write.csv(tab5, file.path(CONFIG$OUTPUT_TABLES, "table5_neely_replication.csv"),
          row.names = FALSE)
print(tab5, row.names = FALSE)
