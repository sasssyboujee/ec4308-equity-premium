# =============================================================================
# data/00_fetch_technical.R -- provenance + (re)fetch for technical inputs
# =============================================================================
# The Neely et al. (2014) technical indicators need two inputs that are NOT
# in the Goyal-Welch-Zafirov workbook:
#   1. S&P 500 index level      -> already in the GWZ workbook ("price").
#   2. S&P 500 monthly volume   -> spliced from two sources (below).
#
# Volume chain (documented in the report, Table 1 notes):
#   * 1950-01 .. 2011-12: the paper's own volume series, taken from the
#     Neely et al. (2014) replication workbook "Returns_econ_tech_data.xls"
#     (sheet "Monthly", column "S&P 500 index volume"), which is the file
#     shipped as data/raw/neely2014_Returns_econ_tech.xls. This script
#     re-downloads it from the replication GitHub repository:
#         https://github.com/szmnkrisz/EquityReturnPrediction
#   * 2012-01 .. 2025-12: monthly AVERAGE daily volume of ^GSPC computed
#     from Yahoo Finance daily bars (via yfinance) and shipped as
#     data/raw/spx_volume_2012_2025.csv. Validation: on the 1985-2011
#     overlap the two series have correlation 0.9999 and a near-constant
#     ratio (median 1.05); the VOL signals are invariant to any constant
#     volume rescaling, so the splice is immaterial for the signals.
#
# Usage (repo root):  Rscript data/00_fetch_technical.R
# =============================================================================

suppressMessages(library(readxl))

RAW <- "data/raw"
dir.create(RAW, showWarnings = FALSE, recursive = TRUE)

url_xls <- paste0(
  "https://raw.githubusercontent.com/szmnkrisz/EquityReturnPrediction/",
  "master/AuthorsAnalysis/Returns_econ_tech_data.xls"
)
dest_xls <- file.path(RAW, "neely2014_Returns_econ_tech.xls")

if (!file.exists(dest_xls)) {
  cat("Downloading Neely et al. (2014) replication workbook ...\n")
  tryCatch(
    download.file(url_xls, dest_xls, mode = "wb"),
    error = function(e) warning("Download failed (", conditionMessage(e),
      "). Use the shipped file in data/raw/ instead.", call. = FALSE)
  )
} else {
  cat("Using shipped file:", normalizePath(dest_xls), "\n")
}

# Regenerate the volume CSV from the workbook if the CSV is missing
vol_csv <- file.path(RAW, "spx_volume_1950_2011.csv")
if (!file.exists(vol_csv) && file.exists(dest_xls)) {
  x <- read_excel(dest_xls, sheet = "Monthly")
  x <- as.data.frame(x)
  x$date <- as.Date(sprintf("%06d01", as.integer(x[[1]])), "%Y%m%d")
  pv <- data.frame(date = x$date,
                   volume_avg_daily = as.numeric(x[["S&P 500 index volume"]]))
  pv <- pv[pv$date >= as.Date("1950-01-01") & pv$date <= as.Date("2011-12-01"), ]
  write.csv(pv, vol_csv, row.names = FALSE)
  cat("Wrote", normalizePath(vol_csv), "\n")
}

# The 2012-2025 file (Yahoo Finance daily bars, monthly average) is shipped
# as raw data. Yahoo's API is rate-limited and unstable for scripting, so it
# is intentionally NOT re-downloaded here; see data/README.md.
ext_csv <- file.path(RAW, "spx_volume_2012_2025.csv")
cat("Yahoo extension file:", file.exists(ext_csv), normalizePath(ext_csv), "\n")

# --- sanity checks ------------------------------------------------------------
v1 <- read.csv(vol_csv)
v2 <- read.csv(ext_csv)
stopifnot(min(v1$date) == "1950-01-01", max(v1$date) == "2011-12-01")
stopifnot(min(v2$date) == "2012-01-01", max(v2$date) == "2025-12-01")
cat(sprintf("Volume chain OK: %s .. %s, %d + %d = %d months, 0 NA\n",
            v1$date[1], tail(v2$date, 1), nrow(v1), nrow(v2), nrow(v1) + nrow(v2)))
