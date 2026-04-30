# =============================================================================
# 05_poisson_regression.R
# -----------------------------------------------------------------------------
# Estimates risk ratios for the association between IG-21st-classified GWG
# parameters (size and velocity at week 36) and neonatal outcomes.
#
# Model: Poisson regression with log link and robust variance estimation
# (Zou G. Am J Epidemiol 2004;159:702-706).
#
# Outcomes:
#   - LBW          : birth weight < 2500 g
#   - macrosomia   : birth weight >= 4000 g
#   - preterm      : gestational age at birth < 37 weeks
#   - apgar_low    : 5-minute Apgar score < 7
#
# Adjustment covariates:
#   maternal age, pre-pregnancy BMI, education, race, parity, gestational
#   diabetes (T1), hypertensive disorders (T1), smoking (T1), alcohol (T1),
#   infant sex, and cohort.
#
# Population restricted to women with normal pre-pregnancy BMI (18.5-<25 kg/m2).
#
# INPUT:
#   data/analytic_dataset.rds   - participant-level dataset with classifications
#
# OUTPUT:
#   output/table3_adjusted_RRs.docx        - main pooled estimates
#   output/tableS2_cohort_stratified.docx  - cohort-stratified estimates
# =============================================================================

source("R/00_setup.R")

# ---- 1. Load data ----------------------------------------------------------
dat <- readRDS(file.path(paths$data, "analytic_dataset.rds")) %>%
  filter(normal_bmi)   # restrict to normal pre-pregnancy BMI

# ---- 2. Helper function: fit robust Poisson and return tidy RR -------------
fit_robust_poisson <- function(outcome, exposure, data,
                               covariates = NULL,
                               cohort_strat = FALSE) {

  formula_rhs <- if (!is.null(covariates)) {
    paste(c(exposure, covariates), collapse = " + ")
  } else exposure

  if (cohort_strat) {
    cohort_vec <- unique(data$cohort)
    out <- map_dfr(cohort_vec, function(coh) {
      d <- data %>% filter(cohort == coh) %>% drop_na(all_of(c(outcome, exposure, covariates)))
      .extract_rr(outcome, formula_rhs, d, cohort_label = coh)
    })
  } else {
    d <- data %>%
      drop_na(all_of(c(outcome, exposure, covariates, "cohort")))
    rhs <- if (is.null(covariates)) {
      paste(exposure, "+ cohort")
    } else {
      paste(c(exposure, covariates, "cohort"), collapse = " + ")
    }
    out <- .extract_rr(outcome, rhs, d, cohort_label = "Pooled")
  }

  out
}

# Internal extractor — fits robust Poisson and tidies the exposure RRs
.extract_rr <- function(outcome, rhs, data, cohort_label) {

  fit <- glm(
    as.formula(paste(outcome, "~", rhs)),
    family = poisson(link = "log"),
    data   = data
  )

  vcov_robust <- sandwich::vcovHC(fit, type = "HC0")
  ct <- lmtest::coeftest(fit, vcov. = vcov_robust)

  tibble(
    cohort     = cohort_label,
    outcome    = outcome,
    term       = rownames(ct),
    estimate   = ct[, "Estimate"],
    std_error  = ct[, "Std. Error"],
    z_value    = ct[, "z value"],
    p_value    = ct[, "Pr(>|z|)"]
  ) %>%
    mutate(
      RR     = exp(estimate),
      lower  = exp(estimate - 1.96 * std_error),
      upper  = exp(estimate + 1.96 * std_error),
      n_obs  = nrow(data)
    )
}

# ---- 3. Define outcomes, exposures, and covariates -------------------------
outcomes <- c("lbw", "macrosomia", "preterm", "apgar_low")
exposures <- c("size_category", "velocity_category")

covariates <- c(
  "age", "pre_bmi", "education", "race", "parity",
  "gdm_t1", "htn_t1", "smoking_t1", "alcohol_t1", "infant_sex"
)

# ---- 4. Pooled adjusted estimates (Table 3) --------------------------------
pooled_results <- expand_grid(outcome = outcomes, exposure = exposures) %>%
  mutate(results = map2(outcome, exposure, ~ fit_robust_poisson(
    outcome   = .x,
    exposure  = .y,
    data      = dat,
    covariates = covariates,
    cohort_strat = FALSE
  ))) %>%
  unnest(results) %>%
  filter(stringr::str_detect(term, "category"))

# ---- 5. Cohort-stratified estimates (Table S2) -----------------------------
stratified_results <- expand_grid(outcome = outcomes, exposure = exposures) %>%
  mutate(results = map2(outcome, exposure, ~ fit_robust_poisson(
    outcome   = .x,
    exposure  = .y,
    data      = dat,
    covariates = covariates,
    cohort_strat = TRUE
  ))) %>%
  unnest(results) %>%
  filter(stringr::str_detect(term, "category"))

# ---- 6. Format and export tables -------------------------------------------
format_table <- function(df, caption) {
  df %>%
    mutate(
      RR_CI = sprintf("%.2f (%.2f, %.2f)", RR, lower, upper)
    ) %>%
    select(cohort, outcome, term, RR_CI, p_value, n_obs) %>%
    flextable() %>%
    set_caption(caption) %>%
    autofit()
}

format_table(pooled_results,
             "Table 3. Adjusted risk ratios for the association between SITAR-derived GWG categories and neonatal outcomes (women with normal pre-pregnancy BMI).") %>%
  flextable::save_as_docx(
    path = file.path(paths$output, "table3_adjusted_RRs.docx")
  )

format_table(stratified_results,
             "Supplementary Table S2. Cohort-stratified adjusted risk ratios for the association between SITAR-derived GWG categories and neonatal outcomes.") %>%
  flextable::save_as_docx(
    path = file.path(paths$output, "tableS2_cohort_stratified.docx")
  )

message("Poisson regression complete. Tables 3 and S2 saved to output/.")
