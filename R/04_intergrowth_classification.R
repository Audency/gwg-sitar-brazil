# =============================================================================
# 04_intergrowth_classification.R
# -----------------------------------------------------------------------------
# Classifies SITAR-derived size and velocity at week 36 against the
# INTERGROWTH-21st GWG standard for women with normal pre-pregnancy BMI
# (Cheikh Ismail et al., BMJ 2016). Each participant is classified into
# one of three categories: <P25, P25-P75, or >P75.
#
# The 25th and 75th centiles were selected because they align with the IOM
# recommendations for women with normal pre-pregnancy weight (Bodnar et al.,
# Am J Clin Nutr 2024; IOM 2009) and with the optimal GWG range reported
# in the INTERBIO-21st Fetal Study (Jabin et al., Am J Clin Nutr 2025).
#
# INPUT:
#   data/sitar_predictions.rds  - predicted size and velocity at week 36
#   data/wide_format.rds        - participant-level data
#
# OUTPUT:
#   data/analytic_dataset.rds   - merged dataset ready for Poisson regression
# =============================================================================

source("R/00_setup.R")

# ---- 1. Load SITAR predictions and participant data ------------------------
sitar_predictions <- readRDS(file.path(paths$data, "sitar_predictions.rds"))
combined_wide     <- readRDS(file.path(paths$data, "wide_format.rds"))

# ---- 2. Reference centiles from INTERGROWTH-21st GWG standard --------------
# Cheikh Ismail L, Bishop DC, Pang R, et al. BMJ 2016;352:i555.
# Values at gestational week 36 for women with normal pre-pregnancy BMI.
#
# These reference values would normally be loaded from the INTERGROWTH-21st
# package (igrowup or igb21) or from the published tables. The values below
# are illustrative placeholders — replace with the official values from the
# standard before reproducing the analysis.

ig_centiles_week36 <- list(
  size = list(
    p25 = 9.0,   # kg, illustrative
    p75 = 13.5   # kg, illustrative
  ),
  velocity = list(
    p25 = 0.30,  # kg/week, illustrative
    p75 = 0.55   # kg/week, illustrative
  )
)

# ---- 3. Classify each participant ------------------------------------------
sitar_predictions <- sitar_predictions %>%
  mutate(
    size_category = case_when(
      pred_size <  ig_centiles_week36$size$p25 ~ "<P25",
      pred_size <= ig_centiles_week36$size$p75 ~ "P25-P75",
      pred_size >  ig_centiles_week36$size$p75 ~ ">P75",
      TRUE ~ NA_character_
    ),
    velocity_category = case_when(
      pred_velocity <  ig_centiles_week36$velocity$p25 ~ "<P25",
      pred_velocity <= ig_centiles_week36$velocity$p75 ~ "P25-P75",
      pred_velocity >  ig_centiles_week36$velocity$p75 ~ ">P75",
      TRUE ~ NA_character_
    ),
    size_category     = factor(size_category,     levels = c("P25-P75", "<P25", ">P75")),
    velocity_category = factor(velocity_category, levels = c("P25-P75", "<P25", ">P75"))
  )

# ---- 4. Merge with participant-level data ----------------------------------
analytic_dataset <- combined_wide %>%
  left_join(sitar_predictions, by = c("cohort", "id"))

# ---- 5. Restrict to women with normal pre-pregnancy BMI --------------------
# The INTERGROWTH-21st GWG standard is applicable only to women with normal
# pre-pregnancy BMI; the adjusted Poisson analyses are restricted accordingly.
analytic_dataset <- analytic_dataset %>%
  mutate(
    normal_bmi = (pre_bmi >= 18.5 & pre_bmi < 25)
  )

# ---- 6. Save ---------------------------------------------------------------
saveRDS(analytic_dataset, file.path(paths$data, "analytic_dataset.rds"))

message(
  "INTERGROWTH-21st classification complete. ",
  sum(analytic_dataset$normal_bmi, na.rm = TRUE),
  " women with normal pre-pregnancy BMI included in the analytic dataset."
)
