# =============================================================================
# 00_config.R -- Global configuration for the EC4308 project
# =============================================================================
# Module  : EC4308 Machine Learning and Economic Forecasting (AY 2026/2027 S1)
# Project : Forecasting the Equity Risk Premium Out-of-Sample
# Author  : Sasi (Econometrics/Eval) -- shared config for the whole team
# =============================================================================

CONFIG <- list(
  # --- Rolling window scheme (fixed-width, per Prof. Denis's directive) -----
  W_ROLLING  = 240L,              # 20-year fixed rolling window (months)

  # --- Forecast horizons (months) -------------------------------------------
  HORIZONS   = c(1L, 3L, 12L),

  # --- Transaction costs (basis points) for the Binary Switching Strategy ---
  FEE_BPS    = 10,                # baseline: 10 bps
  FEE_SENSITIVITY = c(5, 20),     # robustness checks

  # --- Mean-variance investor ------------------------------------------------
  GAMMA      = 3,                 # coefficient of relative risk aversion
  W_MIN      = 0,                 # no short selling
  W_MAX      = 1.5,               # max 150% leverage
  VAR_WINDOW = 60,                # months of realized variance for sigma2-hat

  # --- Reproducibility ---------------------------------------------------------
  SEED       = 4308,

  # --- Project folders ---------------------------------------------------------
  DATA_RAW       = file.path("data", "raw"),
  DATA_PROCESSED = file.path("data", "processed"),
  OUTPUT_FIGURES = file.path("output", "figures"),
  OUTPUT_TABLES  = file.path("output", "tables"),

  # --- Packages used across the project ----------------------------------------
  # (The evaluation module itself is base-R only; the model packages below
  #  are needed by En Shao's scripts. Install them all once per machine.)
  PACKAGES = c("hdm", "glmnet", "pls", "ranger", "forecast",
               "sandwich", "readxl", "dplyr", "tidyr", "ggplot2")
)

# -----------------------------------------------------------------------------
# Check that required packages are installed; optionally install the missing
# ones with install = TRUE.
# -----------------------------------------------------------------------------
ensure_packages <- function(pkgs = CONFIG$PACKAGES, install = FALSE) {
  missing <- setdiff(pkgs, rownames(installed.packages()))
  if (length(missing) > 0L) {
    msg <- paste0('"', missing, '"', collapse = ", ")
    if (install) {
      install.packages(missing)
    } else {
      stop("Missing R packages: ", msg,
           "\nInstall them with: install.packages(c(", msg, "))",
           call. = FALSE)
    }
  }
  invisible(pkgs)
}

# --- Predictor configuration (agreed design, Phase 1) -----------------------
# Classic Goyal-Welch (2008) macro predictors used by Neely et al. (2014).
# All 14 are complete in the GWZ workbook from 1926-12 onward.
CONFIG$MACRO_CLASSIC <- c("d/p", "d/y", "e/p", "d/e", "svar", "b/m",
                          "ntis", "tbl", "lty", "ltr", "tms", "dfy", "dfr",
                          "infl")

# Optional "expanded" GWZ (2024 RFS) predictors that are complete from ~1927.
# Enabling them does NOT shorten the sample (the technical indicators bind
# at 1951-02), it only widens the predictor matrix. Default: OFF (the
# proposal and Neely et al. use the classic 14); see review/CHECKPOINT_R1.
CONFIG$MACRO_EXPANDED <- c("skvw", "tail", "fbm", "rdsp", "avgcor",
                           "dtoy", "dtoat", "wtexas", "lzrt", "ogap")
CONFIG$USE_EXPANDED <- FALSE

# Lag depth for every macro predictor (Prof. Denis: "up to 6 lags").
CONFIG$MAX_LAG <- 6L

# The 14 Neely et al. (2014) technical indicator signals (binary 0/1):
# 6 moving-average, 2 momentum, 6 on-balance-volume rules.
CONFIG$TECHNICAL_NAMES <- c(
  paste0("MA_", rep(1:3, each = 2), "_", rep(c(9, 12), 3)),
  paste0("MOM_", c(9, 12)),
  paste0("VOL_", rep(1:3, each = 2), "_", rep(c(9, 12), 3))
)

# Target: log equity premium in PERCENT = 100 * (ret - Rfree), where ret is
# the log S&P 500 total return (incl. dividends) and Rfree the log risk-free
# rate. Validated against Neely et al. (2014) eq_prem: cor = 0.9991.
CONFIG$TARGET <- "eq_prem"

# Sample period of the aligned panel: the first month in which every column
# (14 macro x 6 lags + 14 technical signals + y) is non-missing. The
# binding constraint is the VOL signals (volume data start 1950-01 + 12-month
# OBV burn-in), so the start lands at 1951-02, inside Prof. Denis's
# ~1947-1952 target window.
CONFIG$SAMPLE_START <- "1951-02-01"
CONFIG$SAMPLE_END   <- "2025-12-01"

# Make sure the standard folder structure exists
for (d in c(CONFIG$DATA_RAW, CONFIG$DATA_PROCESSED,
            CONFIG$OUTPUT_FIGURES, CONFIG$OUTPUT_TABLES)) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}
