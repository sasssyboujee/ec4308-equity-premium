# =============================================================================
# data/02_table1.R -- Table 1: summary statistics & unit-root tests
# =============================================================================
# Produces output/tables/table1.csv with three blocks:
#   Panel A: target (log equity premium, %) -- full sample and OOS split
#   Panel B: the raw macro predictors (before lagging)
#   Panel C: the 14 technical signals (fraction of months in "buy" = mean)
#
# Stats: mean, SD, min, max, skewness, kurtosis, ADF statistic (intercept +
# trend, BIC lag selection) and its 1/5/10% significance bin.
# Usage (repo root):  Rscript data/02_table1.R
# =============================================================================

suppressMessages({library(readxl)})
source("R/00_config.R")
source("R/07_unitroot.R")

panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)

skew <- function(x) { x <- x - mean(x); mean(x^3) / mean(x^2)^1.5 }
kurt <- function(x) { x <- x - mean(x); mean(x^4) / mean(x^2)^2 }

adf_row <- function(x) {
  a <- tryCatch(adf_test(x), error = function(e) NULL)
  if (is.null(a)) return(NA_real_)
  a$statistic
}
adf_sig <- function(x) {
  a <- tryCatch(adf_test(x), error = function(e) NULL)
  if (is.null(a)) return(NA_character_)
  a$significance
}

block <- function(name, df, cols, notes = "") {
  rows <- lapply(cols, function(cn) {
    x <- df[[cn]]
    data.frame(
      Panel = name, Series = cn, N = length(x),
      Mean = round(mean(x), 4), SD = round(sd(x), 4),
      Min = round(min(x), 4), Max = round(max(x), 4),
      Skew = round(skew(x), 3), Kurt = round(kurt(x), 3),
      ADF = round(adf_row(x), 3), ADF_sig = adf_sig(x)
    )
  })
  do.call(rbind, rows)
}

gw <- as.data.frame(read_excel(
  file.path(CONFIG$DATA_RAW, "GoyalWelchZafirov_PredictorData.xlsx"),
  sheet = "Monthly"
))
gw$date <- as.Date(sprintf("%06d01", gw$yyyymm), "%Y%m%d")
gw <- gw[order(gw$date), ]

# raw series aligned to the panel period (for Table 1 we report the raw
# predictors over the estimation/OOS split used in the analysis)
sub <- gw[gw$date >= as.Date(CONFIG$SAMPLE_START) &
          gw$date <= as.Date(CONFIG$SAMPLE_END), ]

# OOS split point: first out-of-sample target month (W rolling months in)
W <- CONFIG$W_ROLLING
oos_date <- panel$date[W + 1L]

tabA <- rbind(
  block("A: target (full sample)", panel, CONFIG$TARGET),
  transform(
    block("A: target (in-sample, first W months)", panel[1:W, ], CONFIG$TARGET),
    Panel = "A: target (in-sample)"
  ),
  transform(
    block("A: target (OOS)", panel[panel$date >= oos_date, ], CONFIG$TARGET),
    Panel = "A: target (OOS)"
  )
)

tabB <- block("B: macro predictors (raw)", sub, CONFIG$MACRO_CLASSIC)

tech_panel <- panel[, CONFIG$TECHNICAL_NAMES]
tabC <- data.frame(
  Panel = "C: technical signals", Series = CONFIG$TECHNICAL_NAMES,
  N = nrow(tech_panel),
  Mean = round(colMeans(tech_panel), 4),
  SD = round(apply(tech_panel, 2, sd), 4),
  Min = apply(tech_panel, 2, min), Max = apply(tech_panel, 2, max),
  Skew = NA, Kurt = NA, ADF = NA, ADF_sig = NA
)

table1 <- rbind(tabA, tabB, tabC)
write.csv(table1, file.path(CONFIG$OUTPUT_TABLES, "table1.csv"), row.names = FALSE)
cat("Wrote:", file.path(CONFIG$OUTPUT_TABLES, "table1.csv"), "\n")
cat(sprintf("Panel A target rows: %d | Panel B rows: %d | Panel C rows: %d\n",
            nrow(tabA), nrow(tabB), nrow(tabC)))
cat(sprintf("OOS period begins: %s\n", oos_date))
