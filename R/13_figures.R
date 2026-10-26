# =============================================================================
# 13_figures.R -- report figures (ggplot2)
# =============================================================================
#   figure1_wealth.png    Binary Switching Strategy cumulative wealth per $1:
#                         Prevailing Mean, best model (highest R2_OOS), and
#                         buy-and-hold, at 10 bps, panels for h = 1, 3, 12.
#   figure2_r2oos.png     Out-of-sample R^2 (%) by model and horizon.
#   figure3_gr_weights.png  Granger-Ramanathan combination weights over time
#                           (h = 1), estimated from past OOS errors.
# Usage (repo root):  Rscript R/13_figures.R
# =============================================================================

suppressMessages(library(ggplot2))
source("R/00_config.R")
source("R/04_switching_strategy.R")
source("R/10_combine_forecasts.R")

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
theme_set(theme_bw(base_size = 11) +
          theme(legend.position = "bottom", legend.title = element_blank()))

# ---- Figure 1: switching strategy wealth ------------------------------------
wealth_list <- list()
for (h in CONFIG$HORIZONS) {
  fc <- read.csv(file.path(CONFIG$DATA_PROCESSED, sprintf("forecasts_h%d.csv", h)))
  idx <- fc$target_index
  # best model by R2_OOS
  r2 <- sapply(MODELS, function(nm) {
    1 - sum((y[idx] - fc[[nm]])^2) / sum((y[idx] - fc$pm)^2)
  })
  best <- MODELS[which.max(r2)]
  sw_best <- switching_backtest(eq_r[idx], tb_r[idx], fc[[best]], fee_bps = 10)
  sw_pm   <- switching_backtest(eq_r[idx], tb_r[idx], fc$pm,     fee_bps = 10)
  wealth_list[[length(wealth_list) + 1L]] <- rbind(
    data.frame(horizon = h, date = panel$date[idx], strategy = "buy-and-hold",
               wealth = cumprod(1 + eq_r[idx] / 100)),
    data.frame(horizon = h, date = panel$date[idx], strategy = "Prevailing Mean",
               wealth = sw_pm$wealth),
    data.frame(horizon = h, date = panel$date[idx], strategy = paste0("Switching (", best, ")"),
               wealth = sw_best$wealth)
  )
}
wdf <- do.call(rbind, wealth_list)
wdf$horizon <- factor(paste0("h = ", wdf$horizon))
p1 <- ggplot(wdf, aes(date, wealth, color = strategy)) +
  geom_line(linewidth = 0.5) +
  facet_wrap(~horizon, scales = "free_y") +
  labs(x = NULL, y = "Wealth per $1 invested",
       title = "Binary Switching Strategy: cumulative wealth (net of 10 bps costs)") +
  theme(legend.position = "bottom")
ggsave(file.path(CONFIG$OUTPUT_FIGURES, "figure1_wealth.png"), p1,
       width = 10, height = 4.2, dpi = 300)

# ---- Figure 2: OOS R2 by model x horizon ------------------------------------
r2df <- do.call(rbind, lapply(CONFIG$HORIZONS, function(h) {
  fc <- read.csv(file.path(CONFIG$DATA_PROCESSED, sprintf("forecasts_h%d.csv", h)))
  idx <- fc$target_index
  data.frame(horizon = h,
             model = MODELS,
             R2_OOS = 100 * sapply(MODELS, function(nm) {
               1 - sum((y[idx] - fc[[nm]])^2) / sum((y[idx] - fc$pm)^2)
             }))
}))
r2df$model <- factor(r2df$model, levels = MODELS)
p2 <- ggplot(r2df, aes(model, R2_OOS, fill = model)) +
  geom_col() + geom_hline(yintercept = 0, linewidth = 0.3) +
  facet_grid(horizon ~ ., labeller = label_bquote(h == .(horizon))) +
  scale_fill_viridis_d(option = "D", guide = "none") +
  labs(x = NULL, y = expression(R^2 ~ OOS ~ "(%) vs Prevailing Mean"),
       title = "Out-of-sample predictive accuracy by model and horizon") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(file.path(CONFIG$OUTPUT_FIGURES, "figure2_r2oos.png"), p2,
       width = 7, height = 6, dpi = 300)

# ---- Figure 3: GR combination weights over time (h = 1) ---------------------
h <- 1L
fc <- read.csv(file.path(CONFIG$DATA_PROCESSED, sprintf("forecasts_h%d.csv", h)))
idx <- fc$target_index
F <- fc[, c("target_index", MODELS[1:7])]
wdf3 <- data.frame()
for (i in seq_len(nrow(F))) {
  o <- F$target_index[i] - h
  hist <- which(F$target_index <= o)
  if (length(hist) >= 60L) {
    Fh <- as.matrix(F[hist, -1, drop = FALSE])
    yh <- y[F$target_index[hist]]
    ok <- complete.cases(Fh) & !is.na(yh)
    if (sum(ok) >= 60L) {
      sol <- gr_weights(Fh[ok, , drop = FALSE], yh[ok])
      if (!is.null(sol)) {
        wdf3 <- rbind(wdf3, data.frame(date = panel$date[idx[i]], t(sol)))
      }
    }
  }
}
names(wdf3)[-1] <- MODELS[1:7]
wdf3_long <- reshape(wdf3, direction = "long",
                     varying = list(names(wdf3)[-1]), v.names = "weight",
                     timevar = "model", times = MODELS[1:7], idvar = "date")
p3 <- ggplot(wdf3_long, aes(date, weight, fill = model)) +
  geom_area(position = "stack", alpha = 0.85) +
  labs(x = NULL, y = "Combination weight",
       title = "Granger-Ramanathan combination weights (h = 1)",
       subtitle = "Estimated from past OOS forecast errors; weights sum to 1, non-negative") +
  scale_fill_viridis_d(option = "D") +
  theme(legend.position = "bottom")
ggsave(file.path(CONFIG$OUTPUT_FIGURES, "figure3_gr_weights.png"), p3,
       width = 8, height = 4.5, dpi = 300)

cat("Wrote figures to", CONFIG$OUTPUT_FIGURES, "\n")
cat("Best model by horizon (R2_OOS):\n")
print(do.call(rbind, lapply(split(r2df, r2df$horizon),
                            function(d) d[which.max(d$R2_OOS), ])),
      row.names = FALSE)
