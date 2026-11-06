# =============================================================================
# 16_neely_replication.R -- Neely et al. (2014) replication & extension
# =============================================================================
# Adapts the design of Neely et al. (2014): EXPANDING-window
# bivariate predictive regressions of the one-month-ahead premium on each of
# the 14 technical signals, benchmark = prevailing mean. Accuracy is compared
# with a one-sided Diebold-Mariano test on squared errors (h = 1, so no HAC lag).
# Their published sample uses an initial window of 181 months and OOS
# 1966-01 .. 2011-12. With predictors lagged one month relative to returns,
# our panel starting in 1951-02 provides 178 training pairs at the first
# forecast origin; the first OOS month remains 1966-01.
#
# Also reports the same design on the post-sample extension (2012-01 ..
# 2025-12) and on the pooled OOS (1966-01 .. 2025-12).
#
# Output: output/tables/table5_neely_replication.csv
# Usage (repo root):  Rscript R/16_neely_replication.R
# =============================================================================

source("R/00_config.R")
source("R/03_diebold_mariano.R")

panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)
y <- panel[[CONFIG$TARGET]]
S <- as.matrix(panel[, CONFIG$TECHNICAL_NAMES])
T <- length(y)

first_origin <- match(as.Date("1965-12-01"), panel$date)
stopifnot(length(first_origin) == 1L, !is.na(first_origin))
origins <- seq.int(first_origin, T - 1L)
targets <- origins + 1
stopifnot(panel$date[targets[1L]] == as.Date("1966-01-01"),
          first_origin - 1L == 178L)
pm_fc <- vapply(origins, function(o) mean(y[seq_len(o)]), numeric(1))

run_bivariate <- function(k) {
  fc <- vapply(seq_along(origins), function(i) {
    o <- origins[i]
    tr_x <- seq_len(o - 1L)
    tr_y <- tr_x + 1L
    if (length(unique(S[tr_x, k])) == 1L) return(mean(y[tr_y]))
    fit <- stats::lm.fit(x = cbind(1, S[tr_x, k]), y = y[tr_y])
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
    dm <- dm_test(actual, d$fc, d$pm, power = 2L, h = 1L, alternative = "less")
    data.frame(sample = name, signal = CONFIG$TECHNICAL_NAMES[k],
               n = sum(keep), R2_OOS_pct = round(r2, 3),
               DM_RMSE_stat = round(dm$statistic, 3),
               DM_RMSE_p = round(dm$p.value, 4))
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
