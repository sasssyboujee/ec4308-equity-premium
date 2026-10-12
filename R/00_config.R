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

# Make sure the standard folder structure exists
for (d in c(CONFIG$DATA_RAW, CONFIG$DATA_PROCESSED,
            CONFIG$OUTPUT_FIGURES, CONFIG$OUTPUT_TABLES)) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}
