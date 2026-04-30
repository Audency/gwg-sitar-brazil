# =============================================================================
# 02_descriptive_analysis.R
# -----------------------------------------------------------------------------
# Produces baseline characteristics tables for both cohorts and the analytic
# subset (women with normal pre-pregnancy BMI). Generates Table 1 of the
# manuscript.
#
# INPUT:
#   data/wide_format.rds   - one row per woman
#   data/long_format.rds   - one row per measurement
#
# OUTPUT:
#   output/table1_baseline_characteristics.docx
# =============================================================================

source("R/00_setup.R")

# ---- 1. Load processed data -------------------------------------------------
combined_wide <- readRDS(file.path(paths$data, "wide_format.rds"))

# ---- 2. Categorise pre-pregnancy BMI ----------------------------------------
combined_wide <- combined_wide %>%
  mutate(
    pre_bmi_cat = case_when(
      pre_bmi <  18.5 ~ "Underweight",
      pre_bmi <  25.0 ~ "Normal",
      pre_bmi <  30.0 ~ "Overweight",
      pre_bmi >= 30.0 ~ "Obesity",
      TRUE ~ NA_character_
    ),
    pre_bmi_cat = factor(
      pre_bmi_cat,
      levels = c("Underweight", "Normal", "Overweight", "Obesity")
    )
  )

# ---- 3. Define neonatal outcomes -------------------------------------------
combined_wide <- combined_wide %>%
  mutate(
    lbw          = as.integer(birth_weight  <  2500),
    macrosomia   = as.integer(birth_weight  >= 4000),
    preterm      = as.integer(ga_at_birth   <  37),
    apgar_low    = as.integer(apgar5        <  7)
  )

# ---- 4. Build Table 1 -------------------------------------------------------
table1 <- combined_wide %>%
  select(
    cohort,
    age, pre_bmi, pre_bmi_cat,
    education, race, parity,
    gdm_t1, htn_t1, smoking_t1, alcohol_t1,
    infant_sex,
    birth_weight, ga_at_birth, apgar5,
    lbw, macrosomia, preterm, apgar_low
  ) %>%
  tbl_summary(
    by = cohort,
    missing = "ifany",
    statistic = list(
      all_continuous() ~ "{median} ({p25}, {p75})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = all_continuous() ~ 1
  ) %>%
  add_overall() %>%
  add_p() %>%
  modify_header(label ~ "**Variable**")

# ---- 5. Export Table 1 ------------------------------------------------------
table1 %>%
  as_flex_table() %>%
  flextable::save_as_docx(
    path = file.path(paths$output, "table1_baseline_characteristics.docx")
  )

message("Descriptive analysis complete. Table 1 saved to output/.")
