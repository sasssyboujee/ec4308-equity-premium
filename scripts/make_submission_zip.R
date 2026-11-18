# Build the replication ZIP; attach the report PDF separately.

raw_files <- file.path("data", "raw", c(
  "GoyalWelchZafirov_PredictorData.xlsx",
  "neely2014_Returns_econ_tech.xls", "neely_signals_published_1950_2011.csv",
  "spx_volume_1950_2011.csv", "spx_volume_2012_2025.csv"
))
required <- c(
  "report/main.tex", "README.md",
  raw_files
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

replication_scripts <- list.files("R", pattern = "\\.R$", full.names = TRUE)
replication_scripts <- replication_scripts[
  !basename(replication_scripts) %in% c(
    "17_switching_overlap.R", "18_figure_wealth_stacked.R",
    "19_figure_r2oos_light.R", "98_smoke_models.R", "99_demo_synthetic.R"
  )
]
data_scripts <- list.files("data", pattern = "\\.R$", full.names = TRUE)
data_scripts <- data_scripts[basename(data_scripts) != "download_goyal_data.R"]

files <- c(
  "report/main.tex",
  "README.md",
  replication_scripts,
  data_scripts,
  raw_files
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
