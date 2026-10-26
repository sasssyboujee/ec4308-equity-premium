# =============================================================================
# data/03_validate_signals.R -- replicate Neely et al. (2014) signals check
# =============================================================================
# Compares OUR computed 14 technical signals against the published ones of
# Neely et al. (2014) (shipped in data/raw/neely_signals_published_1950_2011.csv)
# over their 1950-12 .. 2011-12 sample.
#
# Expected result (regenerated here, not hard-coded):
#   12 of 14 signals match 100%; MOM_12 and VOL_2_9 match 99.9% (one month
#   each, due to minor data revisions in the 1968 price and 1980 volume).
#
# Output: output/tables/signal_validation.csv
# Usage (repo root):  Rscript data/03_validate_signals.R
# =============================================================================

suppressMessages({library(readxl)})
source("R/00_config.R")
source("R/06_technical_indicators.R")

gw <- as.data.frame(read_excel(
  file.path(CONFIG$DATA_RAW, "GoyalWelchZafirov_PredictorData.xlsx"),
  sheet = "Monthly"
))
gw$date <- as.Date(sprintf("%06d01", gw$yyyymm), "%Y%m%d")
gw <- gw[order(gw$date), ]

v1 <- read.csv(file.path(CONFIG$DATA_RAW, "spx_volume_1950_2011.csv"))
v2 <- read.csv(file.path(CONFIG$DATA_RAW, "spx_volume_2012_2025.csv"))
vol <- rbind(v1[, c("date", "volume_avg_daily")],
             v2[, c("date", "volume_avg_daily")])
vol$date <- as.Date(vol$date)
vol <- vol[order(vol$date), ]

p <- merge(gw[, c("date", "price")], vol, by = "date", all.x = TRUE)
p <- p[order(p$date), ]
vol_start <- which(p$date == as.Date("1950-01-01"))

calc <- neely_signals(p$price, p$volume_avg_daily, vol_start)
calc$date <- p$date

pub <- read.csv(file.path(CONFIG$DATA_RAW, "neely_signals_published_1950_2011.csv"))
pub$date <- as.Date(pub$date)

m <- merge(calc, pub[, setdiff(names(pub), "eq_prem")], by = "date",
           suffixes = c(".calc", ".pub"))

res <- data.frame(signal = CONFIG$TECHNICAL_NAMES, months_compared = NA_integer_,
                  mismatches = NA_integer_, match_pct = NA_real_,
                  first_mismatch_date = NA_character_)
for (i in seq_along(CONFIG$TECHNICAL_NAMES)) {
  s <- CONFIG$TECHNICAL_NAMES[i]
  a <- m[[paste0(s, ".calc")]]; b <- m[[paste0(s, ".pub")]]
  ok <- !is.na(a) & !is.na(b)
  mm <- sum(ok & a != b)
  fd <- m$date[ok & a != b][1]
  res$months_compared[i] <- sum(ok)
  res$mismatches[i] <- mm
  res$match_pct[i] <- round(100 * (1 - mm / sum(ok)), 3)
  res$first_mismatch_date[i] <- if (is.na(fd)) "" else as.character(fd)
}

write.csv(res, file.path(CONFIG$OUTPUT_TABLES, "signal_validation.csv"),
          row.names = FALSE)
print(res, row.names = FALSE)
cat("\nOverall signal-month match:",
    round(100 * (1 - sum(res$mismatches) / sum(res$months_compared)), 4), "%\n")
cat("Wrote:", file.path(CONFIG$OUTPUT_TABLES, "signal_validation.csv"), "\n")
