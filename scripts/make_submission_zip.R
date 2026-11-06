# =============================================================================
# scripts/make_submission_zip.R -- Canvas submission package
# =============================================================================
# Builds submission/EC4308_GroupX_Submission.zip containing:
#   * report LaTeX source (PDF is a separate deferred deliverable)
#   * ALL R scripts (R/, data/, scripts/, deck/make_deck.py)
#   * the raw data files (data/raw/*, including the GWZ workbook and the
#     technical-indicator inputs) so the code runs from scratch
#   * README.md with run instructions
# NOT included: .git, archive/, personal files (per repo .gitignore).
#
# Usage (repo root):  Rscript scripts/make_submission_zip.R
# =============================================================================

required <- c(
  "README.md", "data/README.md", "R/00_config.R", "R/09_run_models.R",
  "R/11_evaluate.R", "R/14_make_latex_tables.R",
  "data/01_build_panel.R", "scripts/make_submission_zip.R",
  file.path("data", "raw", c("GoyalWelchZafirov_PredictorData.xlsx",
    "neely2014_Returns_econ_tech.xls", "neely_signals_published_1950_2011.csv",
    "spx_volume_1950_2011.csv", "spx_volume_2012_2025.csv"))
)
if (!all(file.exists(required))) {
  stop("Required code/data inputs are missing:\n",
       paste(required[!file.exists(required)], collapse = "\n"), call. = FALSE)
}
out_dir <- "submission"
dir.create(out_dir, showWarnings = FALSE)
zip_path <- file.path(out_dir, "EC4308_Project_Submission.zip")
zip_tmp <- tempfile(pattern = "EC4308_Project_Submission-",
                    tmpdir = out_dir, fileext = ".zip")

files <- c(
  # NOTE: report/main.pdf is uploaded to Canvas separately (see
  # SUBMISSION_CHECKLIST.md); the zip carries the LaTeX SOURCE + data + code.
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
if (!all(file.exists(files))) {
  stop("Submission input is missing:\n",
       paste(files[!file.exists(files)], collapse = "\n"), call. = FALSE)
}
files <- files[!dir.exists(files)]
files <- unique(files)

validate_archive <- function(path, expected_files) {
  check_dir <- tempfile("submission-zip-check-")
  dir.create(check_dir)
  on.exit(unlink(check_dir, recursive = TRUE), add = TRUE)

  expected <- gsub("\\\\", "/", expected_files)
  members <- utils::unzip(path, list = TRUE)$Name
  if (!all(expected %in% members)) {
    stop("Submission archive is missing expected files:\n",
         paste(setdiff(expected, members), collapse = "\n"), call. = FALSE)
  }
  utils::unzip(path, exdir = check_dir)
  if (!all(file.exists(file.path(check_dir, expected)))) {
    stop("Submission archive failed extraction validation.",
         call. = FALSE)
  }
  if (!identical(unname(tools::md5sum(expected_files)),
                 unname(tools::md5sum(file.path(check_dir, expected))))) {
    stop("Extracted archive contents differ from source files.", call. = FALSE)
  }
  invisible(TRUE)
}

# Archive from the repo root so paths inside remain repo-relative.
zip_exe <- Sys.which("zip")
if (nzchar(zip_exe)) {
  utils::zip(zip_tmp, files = files, flags = "-q")
} else if (.Platform$OS.type == "windows") {
  python <- Sys.which("python3")
  if (!nzchar(python)) python <- Sys.which("python")
  if (!nzchar(python)) {
    stop("Neither 'zip' nor Python is available to build the submission archive.",
         call. = FALSE)
  }
  py_code <- paste(
    "import sys, zipfile",
    "with zipfile.ZipFile(sys.argv[1], 'w', zipfile.ZIP_DEFLATED) as z:",
    "    [z.write(path, arcname=path) for path in sys.argv[2:]]",
    sep = "\n"
  )
  result <- system2(python, c("-c", shQuote(py_code, type = "cmd"), zip_tmp, files),
                    stdout = TRUE, stderr = TRUE)
  status <- attr(result, "status")
  if (!is.null(status) && status != 0L) {
    stop("Python archive creation failed:\n",
         paste(result, collapse = "\n"), call. = FALSE)
  }
} else {
  stop("The 'zip' executable is required to build the submission archive.",
       call. = FALSE)
}

if (!file.exists(zip_tmp) || file.info(zip_tmp)$size <= 0) {
  stop("Submission archive was not created; the existing archive was preserved.",
       call. = FALSE)
}
validate_archive(zip_tmp, files)
zip_backup <- NULL
if (file.exists(zip_path)) {
  zip_backup <- tempfile(pattern = "EC4308_Project_Submission-backup-",
                         tmpdir = out_dir, fileext = ".zip")
  if (!file.copy(zip_path, zip_backup) || !file.remove(zip_path)) {
    unlink(zip_backup)
    stop("Could not prepare the existing submission archive for replacement.",
         call. = FALSE)
  }
}
if (!file.rename(zip_tmp, zip_path)) {
  if (!is.null(zip_backup) && !file.copy(zip_backup, zip_path)) {
    warning("Could not restore the previous submission archive from ",
            zip_backup, call. = FALSE)
  } else if (!is.null(zip_backup)) {
    unlink(zip_backup)
  }
  stop("Could not move the validated archive into place.", call. = FALSE)
}
if (!is.null(zip_backup)) unlink(zip_backup)
cat("Wrote", normalizePath(zip_path), "\n")
cat(length(files), "files\n")
