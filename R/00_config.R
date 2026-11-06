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
  # Charged per switch (incl. initial equity entry). Assumes trading an S&P 500
  # ETF and T-bills: major US brokers charge $0 online commission (e.g. Schwab
  # pricing page, accessed 2026-11-07) and a one-cent spread on SPY (~$733) is
  # ~0.14 bps, so 10 bps conservatively covers spread, slippage and impact.
  # 20 bps is the stress case for costlier earlier decades.
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
  PACKAGES = c("hdm", "glmnet", "pls", "ranger", "limSolve", "readxl", "ggplot2")
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

# Optional expanded GWZ (Goyal et al. 2024) predictors. Only these 8 have
# complete monthly data over 1950-08..2025-12 (needed for 6 lags from 1951-02)
# and no full-sample warning in the workbook ReadMe. Excluded, per that ReadMe
# and the Monthly sheet:
#   * full-sample constructions (look-ahead): fbm, ogap, sntm, tchi, shtint
#   * no monthly data: eqis, cay, i/k, pce, govik, skew, crdstd, accrul,
#     cfacc, gpce, gip, house
#   * start too late / end early: csp, vp, impvar, vrp, ndrbl, ygap, rsvix, disag
# Enabling them does not shorten the chosen sample; it only widens X.
# Default: OFF (the
# proposal and Neely et al. use the classic 14); see legacy/review/CHECKPOINT_R1_LEON.md.
CONFIG$MACRO_EXPANDED <- c("skvw", "tail", "rdsp", "avgcor",
                           "dtoy", "dtoat", "wtexas", "lzrt")
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

# Target: simple monthly excess return in percentage points.
# Both ret (including dividends) and Rfree are monthly simple decimal returns.
CONFIG$TARGET <- "eq_prem"

# Chosen common sample, not the earliest possible date: technical signals
# are already complete in 1950-12. Preserve the agreed 1951-02 start.
CONFIG$SAMPLE_START <- "1951-02-01"
CONFIG$SAMPLE_END   <- "2025-12-01"

# Make sure the standard folder structure exists
for (d in c(CONFIG$DATA_RAW, CONFIG$DATA_PROCESSED,
            CONFIG$OUTPUT_FIGURES, CONFIG$OUTPUT_TABLES)) {
  dir.create(d, showWarnings = FALSE, recursive = TRUE)
}
