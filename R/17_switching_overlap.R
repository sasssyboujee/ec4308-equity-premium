# =============================================================================
# 17_switching_overlap.R -- alternative h>1 timing for the switching strategy
# =============================================================================
# The main evaluation (R/11_evaluate.R) uses timing A: the position for month
# t is driven by the most recent forecast OF month t, made h months earlier.
# This file implements timing B, the "freshest h-month-ahead outlook":
#
#     position[m] = sign( forecast made at origin m-1 of target m+h-1 )
#
# i.e. every month the investor re-reads the LATEST h-month-ahead forecast
# and sets the position accordingly. This is the natural alternative when the
# group prefers overlapping, monthly-updated positions for h = 3, 12 (open
# decision #1 in review/CHECKPOINT_R3_SASI.md).
#
# Because the last h-1 target months have no forecast formed at the
# corresponding origin, timing B's position series ends h-1 months earlier
# than timing A's; both are reported on the common wealth path so the two
# are comparable.
#
# Usage (repo root):  Rscript R/17_switching_overlap.R
# Output: output/tables/table3_alt_h{3,12}.csv (switching stats under timing B)
# =============================================================================

source("R/00_config.R")
source("R/04_switching_strategy.R")

panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)
y <- panel[[CONFIG$TARGET]]

suppressMessages(library(readxl))
gw <- as.data.frame(read_excel(
  file.path(CONFIG$DATA_RAW, "GoyalWelchZafirov_PredictorData.xlsx"),
  sheet = "Monthly"))
gw$date <- as.Date(sprintf("%06d01", gw$yyyymm), "%Y%m%d")
m <- match(panel$date, gw$date)
eq_r <- 100 * gw$ret[m]
tb_r <- gw$tbl[m] / 12

MODELS <- c("rlasso", "postlasso", "ridge", "enet", "pcr", "pls", "rf",
            "equal_comb", "gr_comb")

for (h in c(3L, 12L)) {
  fc <- read.csv(file.path(CONFIG$DATA_PROCESSED, sprintf("forecasts_h%d.csv", h)))
  # position for panel-month t uses the forecast of target t+h-1 (made at origin t-1)
  tgt_avail <- fc$target_index
  pos_months <- (tgt_avail[1] - h + 1):(tail(tgt_avail, 1) - h + 1)  # t such that t+h-1 in targets
  fc_sel <- fc$forecast
  rows <- lapply(c(MODELS, "pm"), function(nm) {
    f_series <- fc[[nm]]                              # keyed by target
    f_by_target <- setNames(f_series, tgt_avail)
    pos_fc <- f_by_target[as.character(pos_months + h - 1)]   # fc of target t+h-1
    sw <- switching_backtest(eq_r[pos_months], tb_r[pos_months], pos_fc, fee_bps = 10)
    sw5  <- switching_backtest(eq_r[pos_months], tb_r[pos_months], pos_fc, fee_bps = 5)
    sw20 <- switching_backtest(eq_r[pos_months], tb_r[pos_months], pos_fc, fee_bps = 20)
    data.frame(model = nm, horizon = h, timing = "B: freshest h-month-ahead",
               months = length(pos_months),
               sw_wealth_5bps = round(sw5$terminal_wealth, 3),
               sw_wealth_10bps = round(sw$terminal_wealth, 3),
               sw_wealth_20bps = round(sw20$terminal_wealth, 3),
               sw_sharpe_10bps = round(sw$sharpe_annual, 3),
               sw_maxdd_10bps = round(sw$max_drawdown, 4),
               sw_switches = sw$n_switches,
               sw_eq_exposure = round(sw$equity_exposure, 3))
  })
  tab <- do.call(rbind, rows)
  write.csv(tab, file.path(CONFIG$OUTPUT_TABLES, sprintf("table3_alt_h%d.csv", h)),
            row.names = FALSE)
  cat("Wrote:", file.path(CONFIG$OUTPUT_TABLES, sprintf("table3_alt_h%d.csv", h)), "\n")
  print(tab[, c("model", "sw_wealth_10bps", "sw_sharpe_10bps", "sw_maxdd_10bps")],
        row.names = FALSE)
}
