# =============================================================================
# data/01_build_panel.R -- aligned, model-ready panel (Phase 1 core artifact)
# =============================================================================
# Builds data/processed/panel.csv and data/processed/codebook.csv following
# the alignment convention in data/README.md:
#
#   * Row t of y      = log equity premium EARNED in month t, in percent:
#                       y[t] = 100 * (ret[t] - Rfree[t]).
#   * Row t of X       = predictors OBSERVABLE at the END of month t.
#   * Macro lag k column:  x_lagk[t] = x[t-k]     (k = 1..MAX_LAG)
#   * Technical signals at row t use price/volume data through month t only.
#
# Sample: SAMPLE_START .. SAMPLE_END from R/00_config.R (no NAs anywhere
# after the start date -- asserted).
#
# Usage (repo root):  Rscript data/01_build_panel.R
#                     Rscript data/01_build_panel.R expanded [out_file]
#        (second form builds the panel with the 10 expanded GWZ-2024
#         predictors enabled, optionally to a custom output path)
# =============================================================================

suppressMessages({library(readxl)})
source("R/00_config.R")
source("R/06_technical_indicators.R")

args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 1L && args[1] == "expanded") {
  CONFIG$USE_EXPANDED <- TRUE
}
panel_out <- if (length(args) >= 2L) args[2] else
  file.path(CONFIG$DATA_PROCESSED, "panel.csv")
codebook_out <- sub("panel", "codebook", panel_out)

cat("== Build aligned panel ==\n")

# -----------------------------------------------------------------------------
# 1. Goyal-Welch-Zafirov monthly workbook
# -----------------------------------------------------------------------------
gw <- as.data.frame(read_excel(
  file.path(CONFIG$DATA_RAW, "GoyalWelchZafirov_PredictorData.xlsx"),
  sheet = "Monthly"
))
gw$date <- as.Date(sprintf("%06d01", gw$yyyymm), "%Y%m%d")
gw <- gw[order(gw$date), ]

y <- 100 * (gw$ret - gw$Rfree)          # log equity premium, percent

macro_names <- c(CONFIG$MACRO_CLASSIC,
                 if (CONFIG$USE_EXPANDED) CONFIG$MACRO_EXPANDED else NULL)

# -----------------------------------------------------------------------------
# 2. Technical indicators (price from GWZ, volume from the spliced chain)
# -----------------------------------------------------------------------------
v1 <- read.csv(file.path(CONFIG$DATA_RAW, "spx_volume_1950_2011.csv"))
v2 <- read.csv(file.path(CONFIG$DATA_RAW, "spx_volume_2012_2025.csv"))
vol <- rbind(v1[, c("date", "volume_avg_daily")],
             v2[, c("date", "volume_avg_daily")])
vol$date <- as.Date(vol$date)
vol <- vol[order(vol$date), ]

p <- merge(gw[, c("date", "price")], vol, by = "date", all.x = TRUE)
p <- p[order(p$date), ]
vol_start <- which(p$date == as.Date("1950-01-01"))
stopifnot(length(vol_start) == 1L)

tech <- neely_signals(price = p$price, volume = p$volume_avg_daily,
                      vol_start = vol_start)

# -----------------------------------------------------------------------------
# 3. Macro lags (alignment convention: x_lagk[t] = x[t-k])
# -----------------------------------------------------------------------------
shift_k <- function(x, k) c(rep(NA_real_, k), head(x, -k))

macro_lag_cols <- list()
codebook <- data.frame()
for (v in macro_names) {
  x <- as.numeric(gw[[v]])
  for (k in seq_len(CONFIG$MAX_LAG)) {
    cn <- sprintf("%s_lag%d", gsub("[^a-z0-9]", "", v), k)
    macro_lag_cols[[cn]] <- shift_k(x, k)
    codebook <- rbind(codebook, data.frame(
      column = cn, group = "macro", variable = v, lag = k,
      definition = sprintf("raw GWZ column '%s' shifted: x_lag%d[t] = x[t-%d]",
                           v, k, k),
      alignment = "observable at end of month t"))
  }
}
macro_X <- as.data.frame(macro_lag_cols)

# -----------------------------------------------------------------------------
# 4. Assemble, trim to sample, assert integrity
# -----------------------------------------------------------------------------
panel <- cbind(date = gw$date,
               y = y,
               macro_X,
               tech)
names(panel)[names(panel) == "y"] <- CONFIG$TARGET

start_d <- as.Date(CONFIG$SAMPLE_START); end_d <- as.Date(CONFIG$SAMPLE_END)
panel <- panel[panel$date >= start_d & panel$date <= end_d, ]

# (a) no NAs after the start date
stopifnot(all(complete.cases(panel)))
# (b) spot-check the lag construction on random rows (x_lagk[t] == x[t-k])
set.seed(CONFIG$SEED)
for (v in macro_names) {
  raw_v <- as.numeric(gw[[v]])
  d_idx <- match(panel$date, gw$date)
  for (k in seq_len(CONFIG$MAX_LAG)) {
    cn <- sprintf("%s_lag%d", gsub("[^a-z0-9]", "", v), k)
    for (t in sample(seq_along(panel$date), 5L)) {
      stopifnot(isTRUE(all.equal(panel[[cn]][t], raw_v[d_idx[t] - k],
                                 tolerance = 1e-12)))
    }
  }
}
cat("Lag spot-checks passed (5 random rows per macro column)\n")

# (c) technical signal availability: first row where every signal is non-NA
first_tech <- min(which(complete.cases(tech)))
cat(sprintf("Technical signals available from %s\n", p$date[first_tech]))

# -----------------------------------------------------------------------------
# 5. Codebook + write artifacts
# -----------------------------------------------------------------------------
tech_cb <- data.frame(column = CONFIG$TECHNICAL_NAMES, group = "technical",
                      variable = CONFIG$TECHNICAL_NAMES, lag = 0,
                      definition = "binary Neely et al. (2014) signal (1 = buy equity)",
                      alignment = "computed from price/volume through end of month t")
cb <- rbind(
  data.frame(column = CONFIG$TARGET, group = "target",
             variable = "eq_prem", lag = 0,
             definition = "100*(ret - Rfree): log S&P 500 total return minus log risk-free, in percent",
             alignment = "earned in month t"),
  codebook, tech_cb
)

write.csv(panel, panel_out, row.names = FALSE)
write.csv(cb, codebook_out, row.names = FALSE)

cat(sprintf("Panel: %d rows (%s .. %s), %d columns\n",
            nrow(panel), panel$date[1], tail(panel$date, 1), ncol(panel)))
cat(sprintf("Target sd: %.2f pp | macro lag cols: %d | technical cols: %d\n",
            sd(panel[[CONFIG$TARGET]]), nrow(codebook), length(CONFIG$TECHNICAL_NAMES)))
cat("Wrote:", panel_out, "\n")
cat("Wrote:", codebook_out, "\n")
