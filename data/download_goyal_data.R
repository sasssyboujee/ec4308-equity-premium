# =============================================================================
# download_goyal_data.R -- fetch the Goyal, Welch & Zafirov dataset
# =============================================================================
# Source: Amit Goyal's website (https://sites.google.com/view/agoyal145)
#
# The EXPANDED monthly dataset (monthly 1871:01 through the latest update,
# ~57 predictors, with ReadMe / Monthly / Quarterly / Annual sheets) is
# hosted as a public Google Sheet. This script exports the whole workbook
# to data/raw/ so every teammate has an identical copy.
#
# Usage (from the repo root):
#     Rscript data/download_goyal_data.R
#
# Output: data/raw/GoyalWelchZafirov_PredictorData.xlsx
# =============================================================================

SHEET_ID <- "17mw_IpaiLFDrGnrPRQ2o1ugV5nJsZuD1"   # expanded GWZ dataset
url  <- sprintf("https://docs.google.com/spreadsheets/d/%s/export?format=xlsx",
                SHEET_ID)
dest <- file.path("data", "raw", "GoyalWelchZafirov_PredictorData.xlsx")

dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)
cat("Downloading Goyal, Welch & Zafirov dataset ...\n")
download.file(url, dest, mode = "wb")
cat("Saved:", normalizePath(dest), "\n")

if (requireNamespace("readxl", quietly = TRUE)) {
  sheets <- readxl::excel_sheets(dest)
  cat("Sheets:", paste(sheets, collapse = ", "), "\n")
  monthly <- readxl::read_excel(dest, sheet = "Monthly")
  cat("Monthly rows:", nrow(monthly), "| columns:", ncol(monthly), "\n")
  cat("Date range:", monthly$yyyymm[1], "to", monthly$yyyymm[nrow(monthly)], "\n")
} else {
  cat("Tip: install readxl to inspect the workbook: install.packages('readxl')\n")
}
