# =============================================================================
# 19_figure_r2oos_light.R -- light-theme OOS R^2 figure for the deck
# =============================================================================
#   figure2_r2oos_light.png  OOS R^2 (%) vs prevailing mean, by model, with
#                            h = 1 / 3 / 12 stacked top to bottom.
# Values are read from output/tables/table2_h*.csv (R2_OOS_pct), so run
# R/11_evaluate.R first. Colours match the deck's light slides (#f6f5ef
# background, #0f1c33 text). The report's figure2_r2oos.png (R/13_figures.R)
# is not modified.
# Usage (repo root):  Rscript R/19_figure_r2oos_light.R
# =============================================================================

suppressMessages(library(ggplot2))
source("R/00_config.R")

MODEL_LABELS <- c(rlasso = "LASSO", postlasso = "Post-LASSO", ridge = "Ridge",
                  enet = "Elastic\nnet", pcr = "PCR", pls = "PLS",
                  rf = "Random\nforest", equal_comb = "Equal-weight\ncomb.",
                  gr_comb = "Constrained\nGR comb.")

r2df <- do.call(rbind, lapply(CONFIG$HORIZONS, function(h) {
  t2 <- read.csv(file.path(CONFIG$OUTPUT_TABLES, sprintf("table2_h%d.csv", h)))
  stopifnot(setequal(t2$model, names(MODEL_LABELS)))
  data.frame(horizon = h, model = t2$model, R2 = t2$R2_OOS_pct)
}))
r2df$model <- factor(r2df$model, levels = names(MODEL_LABELS),
                     labels = MODEL_LABELS)
r2df$horizon <- factor(r2df$horizon, levels = CONFIG$HORIZONS,
                       labels = paste0("h = ", CONFIG$HORIZONS,
                                       ifelse(CONFIG$HORIZONS == 1, " month", " months")))
r2df$group <- ifelse(r2df$R2 > 0, "Beats prevailing mean",
                     ifelse(grepl("comb", r2df$model), "Combination", "Single model"))
r2df$label <- sprintf("%+.2f", r2df$R2)

BG <- "#f6f5ef"; NAVY <- "#0f1c33"
FILL <- c("Single model" = "#7a879c", "Combination" = "#ff7a4d",
          "Beats prevailing mean" = "#1fa37f")

p <- ggplot(r2df, aes(model, R2, fill = group)) +
  geom_col(width = 0.72) +
  geom_hline(yintercept = 0, colour = NAVY, linewidth = 0.5) +
  geom_text(aes(label = label, vjust = ifelse(R2 > 0, -0.4, 1.3)),
            colour = NAVY, size = 3.4) +
  facet_wrap(~horizon, ncol = 1) +
  scale_fill_manual(values = FILL, breaks = names(FILL)) +
  scale_y_continuous(limits = c(-18.5, 2.5), breaks = seq(-15, 0, 5)) +
  labs(x = NULL, y = expression(OOS ~ R^2 ~ "(%) vs prevailing mean")) +
  theme_minimal(base_size = 14) +
  theme(plot.background = element_rect(fill = BG, colour = NA),
        panel.background = element_rect(fill = BG, colour = NA),
        panel.grid.major.y = element_line(colour = "#d9d7cf", linewidth = 0.4),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        text = element_text(colour = NAVY),
        axis.text = element_text(colour = NAVY),
        axis.text.x = element_text(size = 11.5, lineheight = 0.9),
        strip.text = element_text(colour = NAVY, face = "bold", hjust = 0,
                                  size = 14),
        legend.position = "bottom",
        legend.title = element_blank(),
        legend.text = element_text(size = 12),
        panel.spacing = unit(1, "lines"),
        plot.margin = margin(10, 14, 8, 8))

ggsave(file.path(CONFIG$OUTPUT_FIGURES, "figure2_r2oos_light.png"), p,
       width = 10, height = 7.5, dpi = 240, bg = BG)
print(r2df[order(r2df$horizon, r2df$model), c("horizon", "model", "R2")],
      row.names = FALSE)
