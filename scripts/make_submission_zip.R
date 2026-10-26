# =============================================================================
# scripts/make_submission_zip.R -- Canvas submission package
# =============================================================================
# Builds submission/EC4308_GroupX_Submission.zip containing:
#   * the final report PDF (report/main.pdf)
#   * ALL R scripts (R/, data/, scripts/, deck/make_deck.py)
#   * the raw data files (data/raw/*, including the GWZ workbook and the
#     technical-indicator inputs) so the code runs from scratch
#   * README.md with run instructions
# NOT included: .git, archive/, personal files (per repo .gitignore).
#
# Usage (repo root):  Rscript scripts/make_submission_zip.R
# =============================================================================

stopifnot(file.exists("report/main.pdf"))
out_dir <- "submission"
dir.create(out_dir, showWarnings = FALSE)
zip_path <- file.path(out_dir, "EC4308_Project_Submission.zip")
if (file.exists(zip_path)) file.remove(zip_path)

files <- c(
  "report/main.pdf",
  "report/main.tex",
  "README.md",
  "EC4308_Project.Rproj",
  "EC4308_Project_Guidelines.pdf",
  list.files("R",    pattern = "\\.R$",  full.names = TRUE),
  list.files("data", pattern = "\\.R$",  full.names = TRUE),
  list.files("data", pattern = "\\.md$", full.names = TRUE),
  list.files("data/raw", full.names = TRUE, all.files = TRUE, recursive = TRUE),
  list.files("scripts", pattern = "\\.R$", full.names = TRUE),
  "deck/make_deck.py"
)
files <- files[file.exists(files) & !dir.exists(files)]
files <- unique(files)

# zip from the repo root so paths inside the archive are repo-relative
utils::zip(zip_path, files = files, flags = "-q")
cat("Wrote", normalizePath(zip_path), "\n")
cat(length(files), "files\n")
