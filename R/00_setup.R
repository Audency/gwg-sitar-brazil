# =============================================================================
# 00_setup.R
# -----------------------------------------------------------------------------
# Loads all packages required for the analysis pipeline, sets global options,
# and defines paths used by the subsequent scripts.
# =============================================================================

# ---- 1. Required packages ---------------------------------------------------
required_pkgs <- c(
  # SITAR and mixed-effects framework
  "sitar",
  "nlme",

  # Data manipulation
  "dplyr",
  "tidyr",
  "purrr",
  "stringr",
  "readr",

  # Visualisation
  "ggplot2",
  "patchwork",
  "cowplot",
  "RColorBrewer",

  # Robust standard errors and inference
  "sandwich",
  "lmtest",

  # Tabular output
  "gtsummary",
  "flextable"
)

# Install any missing packages, then load all of them
missing_pkgs <- required_pkgs[!(required_pkgs %in% installed.packages()[, "Package"])]
if (length(missing_pkgs) > 0) {
  install.packages(missing_pkgs, dependencies = TRUE)
}
invisible(lapply(required_pkgs, library, character.only = TRUE))

# ---- 2. Global options ------------------------------------------------------
options(
  stringsAsFactors = FALSE,
  scipen = 999,             # avoid scientific notation in numeric output
  digits = 4,
  warn = 1                  # show warnings as they occur
)

# ---- 3. Project paths -------------------------------------------------------
# Adapt these paths to your local setup before running the scripts
paths <- list(
  data   = file.path(getwd(), "data"),     # raw and processed data
  output = file.path(getwd(), "output"),   # figures and tables
  docs   = file.path(getwd(), "docs")      # documentation
)

# Create output directory if it does not exist
if (!dir.exists(paths$output)) dir.create(paths$output, recursive = TRUE)

# ---- 4. Reproducibility -----------------------------------------------------
set.seed(20260101)

message("Setup complete. R version: ", R.version.string)
message("All required packages loaded successfully.")
