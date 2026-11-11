# =============================================================================
# 18_figure_wealth_stacked.R -- dark-theme switching-wealth figure for the deck
# =============================================================================
#   figure1_wealth_stacked.png  Cumulative wealth per $1 (net of 10 bps per
#                               position change), h = 1 / 3 / 12 stacked.
# Lines: buy-and-hold, switching on Ridge, switching on constrained GR.
# The Prevailing Mean forecast is positive in every OOS month at every
# horizon, so PM switching is identical to buy-and-hold; one line shows both
# (the script stops if that ever stops being true).
# Uses switching_backtest() unchanged: the strategy earns the S&P 500 total
# return or the realized T-bill return, so terminal values match Table 3
# (sw_wealth_10bps / sw_wealth_bh). Compounding excess returns with cash at 0
# would give wealth roughly one tenth as large and would not match Table 3.
# Inputs: panel.csv eq_prem = S&P 500 excess return (percent). panel.csv has
# no realized T-bill return (tbl_lag1 is the lagged annual yield), so cash =
# 100 * Rfree from the GWZ workbook; equity = eq_prem + cash, checked against
# monthly_asset_returns().
# Start dates: all panels share an x-axis from 1971-03 (first h=1 OOS month).
# h=3 and h=12 forecasts only exist from 1971-07 and 1973-01, so those paths
# start at $1 there; the strip labels state each start month.
# The report's figure1_wealth.png (R/13_figures.R) is not modified.
# Usage (repo root):  Rscript R/18_figure_wealth_stacked.R
# =============================================================================

suppressMessages({
  library(ggplot2)
  library(readxl)
})
source("R/00_config.R")
source("R/04_switching_strategy.R")

FEE_BPS <- 10
panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
panel$date <- as.Date(panel$date)
gw <- as.data.frame(read_excel(
  file.path(CONFIG$DATA_RAW, "GoyalWelchZafirov_PredictorData.xlsx"),
  sheet = "Monthly"))
gw$date <- as.Date(sprintf("%06d01", gw$yyyymm), "%Y%m%d")
cash <- 100 * gw$Rfree[match(panel$date, gw$date)]
equity <- panel$eq_prem + cash
stopifnot(!anyNA(cash),
          isTRUE(all.equal(equity, monthly_asset_returns(gw, panel$date)$equity)))

LABELS <- c(bh = "Prevailing Mean (= Buy-and-Hold)",
            ridge = "Switching (Ridge)",
            gr_comb = "Switching (Constrained GR)")
COLORS <- setNames(c("#7ed957", "#66dfc1", "#8eacff"), LABELS)

wdf <- do.call(rbind, lapply(CONFIG$HORIZONS, function(h) {
  fc <- read.csv(file.path(CONFIG$DATA_PROCESSED, sprintf("forecasts_h%d.csv", h)))
  idx <- fc$target_index
  stopifnot(all(as.Date(fc$date) == panel$date[idx]))
  run <- function(f) switching_backtest(equity[idx], cash[idx], f,
                                        fee_bps = FEE_BPS)$wealth
  bh <- run(rep(1, length(idx)))
  if (!isTRUE(all.equal(run(fc$pm), bh)))
    stop("PM switching differs from buy-and-hold at h = ", h, call. = FALSE)
  do.call(rbind, lapply(names(LABELS), function(m) {
    w <- if (m == "bh") bh else run(fc[[m]])
    data.frame(horizon = h, date = panel$date[idx], series = LABELS[[m]],
               wealth = w)
  }))
}))
starts <- tapply(wdf$date, wdf$horizon, min)
wdf$horizon <- factor(wdf$horizon, levels = CONFIG$HORIZONS,
                      labels = paste0("h = ", CONFIG$HORIZONS,
                                      ifelse(CONFIG$HORIZONS == 1, " month", " months"),
                                      "  (from ", format(as.Date(starts[as.character(CONFIG$HORIZONS)]), "%Y:%m"), ")"))
wdf$series <- factor(wdf$series, levels = LABELS)

BG <- "#101d34"
p <- ggplot(wdf, aes(date, wealth, colour = series)) +
  geom_line(linewidth = 1) +
  facet_wrap(~horizon, ncol = 1, scales = "free_y") +
  scale_colour_manual(values = COLORS) +
  guides(colour = guide_legend(nrow = 1)) +
  scale_x_date(breaks = as.Date(c("1980-01-01", "2000-01-01", "2020-01-01")),
               date_labels = "%Y", expand = expansion(mult = 0.01),
               limits = as.Date(c("1971-03-01", "2025-12-01"))) +
  scale_y_continuous(labels = function(x) paste0("$", x)) +
  labs(x = NULL, y = "Wealth per $1 invested") +
  theme_minimal(base_size = 15) +
  theme(plot.background = element_rect(fill = BG, colour = NA),
        panel.background = element_rect(fill = BG, colour = NA),
        panel.grid.major = element_line(colour = "#31425c", linewidth = 0.3),
        panel.grid.minor = element_blank(),
        text = element_text(colour = "#ffffff"),
        axis.text = element_text(colour = "#cbd5e1"),
        axis.ticks = element_line(colour = "#cbd5e1"),
        strip.text = element_text(colour = "#ffffff", face = "bold",
                                  hjust = 0, size = 15),
        legend.position = "bottom",
        legend.direction = "horizontal",
        legend.title = element_blank(),
        legend.text = element_text(colour = "#ffffff", size = 12),
        legend.background = element_rect(fill = "transparent", colour = NA),
        legend.key = element_rect(fill = "transparent", colour = NA),
        panel.spacing = unit(1.2, "lines"),
        plot.margin = margin(12, 16, 8, 8))

ggsave(file.path(CONFIG$OUTPUT_FIGURES, "figure1_wealth_stacked.png"), p,
       width = 11, height = 8, dpi = 300, bg = BG)

ends <- aggregate(wealth ~ horizon + series, wdf, function(x) tail(x, 1))
print(ends, digits = 6)
