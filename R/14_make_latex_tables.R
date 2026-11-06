# =============================================================================
# 14_make_latex_tables.R -- CSVs -> .tex fragments for the report
# =============================================================================
# Converts output/tables/table1.csv, table2_h{1,3,12}.csv and
# table3_h{1,3,12}.csv into LaTeX fragments:
#   output/tables/table1_tex.tex
#   output/tables/table2_tex.tex   (blocks per horizon)
#   output/tables/table3_tex.tex   (blocks per horizon)
# Usage (repo root):  Rscript R/14_make_latex_tables.R
# =============================================================================

source("R/00_config.R")

fmt <- function(x, d = 3) formatC(x, format = "f", digits = d)
sig_tex <- function(s) gsub("%", "\\\\%", s)
esc_tex <- function(s) gsub("_", "\\\\_", s)
na_fmt <- function(x, d = 3) ifelse(is.na(x), "", fmt(x, d))
stars <- function(p) ifelse(is.na(p), "",
  ifelse(p < 0.01, "^{***}", ifelse(p < 0.05, "^{**}", ifelse(p < 0.1, "^{*}", ""))))

# ---------------------------------------------------------------- Table 1 ----
t1 <- read.csv(file.path(CONFIG$OUTPUT_TABLES, "table1.csv"))
macro_rows <- t1[t1$Panel == "B: macro predictors (raw)", ]
tech_rows  <- t1[t1$Panel == "C: technical signals", ]
tgt_full   <- t1[t1$Panel == "A: target (full sample)", ]

lines <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Summary statistics and unit-root tests (sample: 1951:02--2025:12).}",
  "\\label{tab:table1}",
  "\\small",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lrrrrrrrc}",
  "\\toprule",
  "Series & Mean & SD & Min & Max & Skew & Kurt & ADF & Sig. \\\\",
  "\\midrule",
  "\\multicolumn{9}{l}{\\emph{Panel A: simple equity premium (\\%, monthly)}} \\\\",
  sprintf("$y_t$ (full sample) & %s & %s & %s & %s & %s & %s & %s & %s \\\\",
          fmt(tgt_full$Mean, 3), fmt(tgt_full$SD, 3), fmt(tgt_full$Min, 2),
          fmt(tgt_full$Max, 2), fmt(tgt_full$Skew, 2), fmt(tgt_full$Kurt, 2),
          fmt(tgt_full$ADF, 2), sig_tex(tgt_full$ADF_sig)),
  "\\midrule",
  "\\multicolumn{9}{l}{\\emph{Panel B: macroeconomic predictors (raw series)}} \\\\"
)
for (i in seq_len(nrow(macro_rows))) {
  r <- macro_rows[i, ]
  lines <- c(lines, sprintf(
    "%s & %s & %s & %s & %s & %s & %s & %s & %s \\\\",
    r$Series, fmt(r$Mean, 3), fmt(r$SD, 3), fmt(r$Min, 2), fmt(r$Max, 2),
    fmt(r$Skew, 2), fmt(r$Kurt, 2), fmt(r$ADF, 2), sig_tex(r$ADF_sig)))
}
lines <- c(lines,
  "\\midrule",
  "\\multicolumn{9}{l}{\\emph{Panel C: technical signals (binary; mean = fraction of months in ``buy'')}} \\\\"
)
for (i in seq_len(nrow(tech_rows))) {
  r <- tech_rows[i, ]
  lines <- c(lines, sprintf("%s & %s & & & & & & & \\\\",
                            esc_tex(r$Series), fmt(r$Mean, 3)))
}
lines <- c(lines,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\footnotesize",
  "\\item ADF: intercept and trend, common-sample BIC lag selection; MacKinnon (2010) asymptotic critical values $-3.959/-3.410/-3.127$ (1\\%/5\\%/10\\%). $T=899$ monthly observations before ADF lags.",
  "\\item Skewness and kurtosis are population moments; kurtosis is NOT excess (a normal distribution has kurtosis 3).",
  "\\item The premium is $100\\,(R^m-R^f)$ using monthly simple returns; macro predictors enter the models with one to six lags; technical signals are the 14 binary rules of Neely et al. (2014).",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)
writeLines(lines, file.path(CONFIG$OUTPUT_TABLES, "table1_tex.tex"))

# ------------------------------------------------- Table 2 (accuracy) --------
blocks2 <- list()
for (h in CONFIG$HORIZONS) {
  f2 <- file.path(CONFIG$OUTPUT_TABLES, sprintf("table2_h%d.csv", h))
  if (!file.exists(f2)) stop("Missing required accuracy table: ", f2, call. = FALSE)
  t2 <- read.csv(f2)
  oos_n <- nrow(read.csv(file.path(
    CONFIG$DATA_PROCESSED, sprintf("forecasts_h%d.csv", h)
  )))
  rows <- apply(t2, 1, function(r) {
    sprintf("%s & %s & %s & %s & %s & %s & %s%s & %s%s \\\\",
            esc_tex(r["model"]), fmt(as.numeric(r["RMSE"]), 3), fmt(as.numeric(r["MAE"]), 3),
            fmt(as.numeric(r["R2_OOS_pct"]), 2), fmt(as.numeric(r["HR"]), 2),
            fmt(as.numeric(r["DM_RMSE_stat"]), 2),
            fmt(as.numeric(r["DM_RMSE_p"]), 3), stars(as.numeric(r["DM_RMSE_p"])),
            fmt(as.numeric(r["DM_MAE_p"]), 3), stars(as.numeric(r["DM_MAE_p"])))
  })
  blocks2[[length(blocks2) + 1L]] <- c(
    sprintf("\\multicolumn{8}{l}{\\emph{Panel: $h=%d$ (OOS $n=%d$; PM hit rate %.2f)}} \\\\",
            h, oos_n, t2$HR_pm[1]),
    rows
  )
}
lines2 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Out-of-sample accuracy vs. the prevailing mean benchmark.}",
  "\\label{tab:table2}",
  "\\small",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lccccccc}",
  "\\toprule",
  "Model & RMSE & MAE & $R^2_{OOS}$ (\\%) & HR & $DM_{RMSE}$ & $p_{DM}$ & $p_{MAE}$ \\\\",
  "\\midrule",
  unlist(blocks2),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\footnotesize",
  "\\item $R^2_{OOS}$: Campbell--Thompson (2008), in percent vs. the prevailing mean; negative values mean the model is less accurate than the benchmark. HR: hit rate, the fraction of months in which the forecast sign matches the realized sign (direction-of-change loss).",
  "\\item $DM$: Diebold--Mariano on squared errors, one-sided H1 ``model more accurate''; $p_{MAE}$: absolute-error DM. Bartlett HAC bandwidth is $h-1$, a maintained inference choice. $^{*}/^{**}/^{***}$: 10\\%/5\\%/1\\%.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)
writeLines(lines2, file.path(CONFIG$OUTPUT_TABLES, "table2_tex.tex"))

# ------------------------------------------- Table 3 (economic value) -------
blocks3 <- list()
for (h in CONFIG$HORIZONS) {
  f3 <- file.path(CONFIG$OUTPUT_TABLES, sprintf("table3_h%d.csv", h))
  if (!file.exists(f3)) stop("Missing required economic table: ", f3, call. = FALSE)
  t3 <- read.csv(f3)
  rows <- apply(t3, 1, function(r) {
    sprintf(paste0("%s & %s & %s & %s & %s & %s & %s & %s & %s & %s ",
                   "& %s & %s & %s & %s & %s \\\\"),
            esc_tex(r["model"]),
            na_fmt(as.numeric(r["sw_wealth_10bps"]), 2),
            na_fmt(as.numeric(r["sw_wealth_bh"]), 2),
            na_fmt(as.numeric(r["sw_sharpe_10bps"]), 2),
            na_fmt(as.numeric(r["sw_maxdd_10bps"]), 2),
            ifelse(is.na(r["sw_switches"]), "", r["sw_switches"]),
            na_fmt(as.numeric(r["sw_eq_exposure"]), 2),
            na_fmt(as.numeric(r["sw_wealth_5bps"]), 2),
            na_fmt(as.numeric(r["sw_wealth_20bps"]), 2),
            na_fmt(as.numeric(r["mv_deltaU_10bps_pct"]), 2),
            na_fmt(as.numeric(r["mv_deltaU_5bps_pct"]), 2),
            na_fmt(as.numeric(r["mv_deltaU_20bps_pct"]), 2),
            na_fmt(as.numeric(r["mv_cer_model_10bps_pct"]), 2),
            na_fmt(as.numeric(r["mv_sharpe_10bps"]), 2),
            na_fmt(as.numeric(r["mv_mean_w"]), 2))
  })
  blocks3[[length(blocks3) + 1L]] <- c(
    sprintf("\\multicolumn{15}{l}{\\emph{Panel: $h=%d$}} \\\\", h),
    rows
  )
}
lines3 <- c(
  "\\begin{landscape}",
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Economic strategy outcomes net of transaction costs.}",
  "\\label{tab:table3}",
  "\\footnotesize",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lcccccccccccccc}",
  "\\toprule",
  "& \\multicolumn{6}{c}{Binary switching (10 bps)} & \\multicolumn{2}{c}{Switching wealth} & \\multicolumn{3}{c}{MV $\\Delta U$ (\\% p.a.)} & \\multicolumn{3}{c}{MV (10 bps)} \\\\",
  "\\cmidrule(lr){2-7} \\cmidrule(lr){8-9} \\cmidrule(lr){10-12} \\cmidrule(lr){13-15}",
  "Model & Wealth & Buy-hold & Sharpe & MaxDD & Switch & Exp. & 5 bps & 20 bps & 10 bps & 5 bps & 20 bps & CER & Sharpe & Mean $w$ \\\\",
  "\\midrule",
  unlist(blocks3),
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\footnotesize",
  "\\item Switching: holds equity when the forecast is positive, monthly risk-free cash otherwise. Every strategy starts in cash, pays equity entry and subsequent turnover costs, and has no terminal liquidation. Switch counts include entry. MaxDD = maximum drawdown; Exp. = mean equity exposure; cash uses realized Rfree, not the annual tbl predictor. Each h-step forecast predicts one month's return h months ahead, not a cumulative return.",
  "\\item MV: mean--variance investor with $\\gamma=3$, $w_t\\in[0,1.5]$; $\\Delta U$ = annualized certainty-equivalent gain over the benchmark allocation in percentage points; CER = certainty-equivalent return of the strategy (\\% p.a.).",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}",
  "\\end{landscape}"
)
writeLines(lines3, file.path(CONFIG$OUTPUT_TABLES, "table3_tex.tex"))

# ------------------------------- Table A1: spec variants at h = 1 ------------
specs <- c(full = "forecasts_h1.csv", tech = "forecasts_h1_tech.csv",
           macro = "forecasts_h1_macro.csv")
MODELS2 <- c("rlasso", "postlasso", "ridge", "enet", "pcr", "pls", "rf",
             "equal_comb", "gr_comb")
panel <- read.csv(file.path(CONFIG$DATA_PROCESSED, "panel.csv"))
y <- panel[[CONFIG$TARGET]]
r2mat <- sapply(names(specs), function(sp) {
  fc <- read.csv(file.path(CONFIG$DATA_PROCESSED, specs[[sp]]))
  sapply(MODELS2, function(nm) {
    100 * (1 - sum((y[fc$target_index] - fc[[nm]])^2) /
               sum((y[fc$target_index] - fc$pm)^2))
  })
})
a1_rows <- sapply(MODELS2, function(nm) {
  sprintf("%s & %s & %s & %s \\\\", esc_tex(nm),
          fmt(r2mat[nm, "full"], 2), fmt(r2mat[nm, "tech"], 2),
          fmt(r2mat[nm, "macro"], 2))
})
linesA1 <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Out-of-sample $R^2$ (\\%) at $h=1$ by predictor set: full set (98 columns), technical signals only (14), and macro lags only (84).}",
  "\\label{tab:tableA1}",
  "\\small",
  "\\begin{tabular}{lccc}",
  "\\toprule",
  "Model & Full & Technical & Macro \\\\",
  "\\midrule",
  a1_rows,
  "\\bottomrule",
  "\\end{tabular}",
  "\\end{table}"
)
writeLines(linesA1, file.path(CONFIG$OUTPUT_TABLES, "tableA1_tex.tex"))

# ------------------------------------------- h=1 subperiod results -----------
subperiods <- read.csv(file.path(CONFIG$OUTPUT_TABLES,
                                 "table_subperiods_h1.csv"))
subperiod_rows <- apply(subperiods, 1, function(r) {
  sprintf("%s & %s & %s & %s & %s \\\\",
          esc_tex(r["block"]), r["n"],
          r["first_target"], r["last_target"],
          fmt(as.numeric(r["R2"]), 2))
})
lines_subperiods <- c(
  "\\begin{table}[htbp]",
  "\\centering",
  "\\caption{Descriptive LASSO out-of-sample accuracy by subperiod ($h=1$).}",
  "\\label{tab:subperiods}",
  "\\small",
  "\\begin{threeparttable}",
  "\\begin{tabular}{lrllr}",
  "\\toprule",
  "Subperiod & $n$ & First target & Last target & $R^2_{OOS}$ (\\%) \\\\",
  "\\midrule",
  subperiod_rows,
  "\\bottomrule",
  "\\end{tabular}",
  "\\begin{tablenotes}",
  "\\footnotesize",
  "\\item $R^2_{OOS}$ is computed against the prevailing mean within each subperiod. These comparisons are descriptive and not causal.",
  "\\item Source files: \\texttt{forecasts\\_h1.csv} and \\texttt{panel.csv}. Generated by \\texttt{R/13\\_figures.R}.",
  "\\end{tablenotes}",
  "\\end{threeparttable}",
  "\\end{table}"
)
writeLines(lines_subperiods,
           file.path(CONFIG$OUTPUT_TABLES, "table_subperiods_h1_tex.tex"))

cat("Wrote table1_tex.tex, table2_tex.tex, table3_tex.tex, tableA1_tex.tex,",
    "and table_subperiods_h1_tex.tex to", CONFIG$OUTPUT_TABLES, "\n")
