# =============================================================================
# 07_supplementary_tables.R
# -----------------------------------------------------------------------------
# Generates the supplementary tables of the manuscript.
#
# - Table S1 (now to be moved to the main paper, per Eric's suggestion):
#     SITAR fixed-effect parameters and variance explained for both cohorts.
# - Table S3: Distribution of gestational age at birth in both cohorts.
# - Table S4: Random-effect variances and correlations.
#
# INPUT:
#   output/sitar_model_summaries.rds
#   data/wide_format.rds
#
# OUTPUT (saved to output/):
#   tableS1_sitar_parameters.docx
#   tableS3_gestational_age_distribution.docx
#   tableS4_random_effect_correlations.docx
# =============================================================================

source("R/00_setup.R")

# ---- 1. Load fitted models and data ----------------------------------------
sitar_models  <- readRDS(file.path(paths$output, "sitar_model_summaries.rds"))
combined_wide <- readRDS(file.path(paths$data, "wide_format.rds"))

M_ara <- sitar_models$araraquara
M_jun <- sitar_models$jundiai

# ---- 2. Table S1: SITAR fixed-effect parameters ----------------------------
build_sitar_table <- function(model, cohort_label) {
  fe <- summary(model)$tTable

  tibble(
    cohort         = cohort_label,
    parameter      = rownames(fe),
    estimate       = fe[, "Value"],
    std_error      = fe[, "Std.Error"],
    p_value        = fe[, "p-value"],
    variance_expl  = round(varexp(model) * 100, 2)
  )
}

tableS1 <- bind_rows(
  build_sitar_table(M_ara, "Araraquara"),
  build_sitar_table(M_jun, "Jundiai")
)

flextable(tableS1) %>%
  set_caption(
    "Table S1. SITAR fixed-effect parameters and percentage of variance explained in each cohort."
  ) %>%
  autofit() %>%
  flextable::save_as_docx(
    path = file.path(paths$output, "tableS1_sitar_parameters.docx")
  )

# ---- 3. Table S3: Distribution of gestational age at birth -----------------
ga_distribution <- combined_wide %>%
  filter(!is.na(ga_at_birth)) %>%
  mutate(
    ga_cat = case_when(
      ga_at_birth <  28 ~ "Extremely preterm (<28 wk)",
      ga_at_birth <  32 ~ "Very preterm (28-31 wk)",
      ga_at_birth <  37 ~ "Moderate/late preterm (32-36 wk)",
      ga_at_birth >= 37 ~ "Term (>=37 wk)",
      TRUE ~ NA_character_
    ),
    ga_cat = factor(ga_cat, levels = c(
      "Extremely preterm (<28 wk)",
      "Very preterm (28-31 wk)",
      "Moderate/late preterm (32-36 wk)",
      "Term (>=37 wk)"
    ))
  ) %>%
  count(cohort, ga_cat) %>%
  group_by(cohort) %>%
  mutate(percentage = round(100 * n / sum(n), 2)) %>%
  ungroup()

flextable(ga_distribution) %>%
  set_caption(
    "Table S3. Distribution of gestational age at birth in the Araraquara and Jundiai cohorts."
  ) %>%
  autofit() %>%
  flextable::save_as_docx(
    path = file.path(paths$output, "tableS3_gestational_age_distribution.docx")
  )

# ---- 4. Table S4: Random-effect correlations -------------------------------
random_effect_table <- tibble(
  cohort        = c("Araraquara", "Jundiai"),
  rho_size_velocity = c(
    round(sitar_models$rho_ara, 3),
    round(sitar_models$rho_jun, 3)
  ),
  variance_explained_pct = c(
    round(varexp(M_ara) * 100, 2),
    round(varexp(M_jun) * 100, 2)
  )
)

flextable(random_effect_table) %>%
  set_caption(
    "Table S4. Correlation between size and velocity random effects, and percentage of variance explained, by cohort."
  ) %>%
  autofit() %>%
  flextable::save_as_docx(
    path = file.path(paths$output, "tableS4_random_effect_correlations.docx")
  )

message("Supplementary tables saved to output/.")
