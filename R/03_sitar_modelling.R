# =============================================================================
# 03_sitar_modelling.R
# -----------------------------------------------------------------------------
# Fits SITAR (Super Imposition by Translation and Rotation) models to the
# longitudinal GWG data of each cohort separately. Extracts predicted size
# and velocity at the reference gestational week (36 weeks) for each woman.
#
# Methodological notes:
#   * Random effects: SIZE (a) and VELOCITY (c) only. The TIMING (b) random
#     effect is omitted because models with all three random effects did not
#     achieve stable convergence in our data, consistent with prior SITAR
#     applications in GWG (Riddell et al. 2017) and child growth (Ohuma et
#     al. 2021).
#   * Spline degrees of freedom: df = 4, selected based on BIC and stable
#     convergence in both cohorts.
#   * Reference week: 36 weeks (last gestational-age window of routine
#     maternal weight measurement in both cohorts).
#
# INPUT:
#   data/long_format.rds    - one row per (woman x measurement)
#
# OUTPUT:
#   data/sitar_predictions.rds  - predicted size and velocity at week 36
#   output/sitar_model_summaries.rds  - fitted SITAR model objects
# =============================================================================

source("R/00_setup.R")

# ---- 1. Load longitudinal data ---------------------------------------------
combined_long <- readRDS(file.path(paths$data, "long_format.rds"))

araraquara_long <- combined_long %>% filter(cohort == "Araraquara")
jundiai_long    <- combined_long %>% filter(cohort == "Jundiai")

# ---- 2. Fit SITAR models ----------------------------------------------------
# We fit SITAR with two random effects (size + velocity).
# random = "a + c" specifies size (a) and velocity (c) only.

cat("Fitting SITAR model — Araraquara cohort...\n")
M_ara <- sitar(
  x      = gestational_age,
  y      = cumulative_gwg,
  id     = id,
  data   = araraquara_long,
  df     = 4,
  random = "a + c",
  control = nlmeControl(maxIter = 200, msMaxIter = 200, returnObject = TRUE)
)

cat("Fitting SITAR model — Jundiai cohort...\n")
M_jun <- sitar(
  x      = gestational_age,
  y      = cumulative_gwg,
  id     = id,
  data   = jundiai_long,
  df     = 4,
  random = "a + c",
  control = nlmeControl(maxIter = 200, msMaxIter = 200, returnObject = TRUE)
)

# ---- 3. Model diagnostics ---------------------------------------------------
# Print model summaries (fixed effects, random-effect variances, AIC/BIC,
# variance explained).
cat("\n========== Araraquara SITAR summary ==========\n")
print(summary(M_ara))
cat("\nVariance explained (Araraquara): ",
    round(varexp(M_ara) * 100, 2), "%\n", sep = "")

cat("\n========== Jundiai SITAR summary ==========\n")
print(summary(M_jun))
cat("\nVariance explained (Jundiai): ",
    round(varexp(M_jun) * 100, 2), "%\n", sep = "")

# ---- 4. Random-effect correlations (response to Reviewer 3, Comment 12) ----
rho_ara <- suppressWarnings(cov2cor(getVarCov(M_ara))[1, 2])
rho_jun <- suppressWarnings(cov2cor(getVarCov(M_jun))[1, 2])

cat("\nRandom-effect correlation (size, velocity):\n")
cat(" Araraquara: rho = ", round(rho_ara, 3), "\n", sep = "")
cat(" Jundiai:    rho = ", round(rho_jun, 3), "\n", sep = "")

# ---- 5. Extract individual predictions at reference week (36 weeks) --------
ref_week <- 36

extract_individual_pred <- function(model, ref_week) {
  ranef_df <- as.data.frame(ranef(model))
  ranef_df$id <- rownames(ranef_df)

  # Predicted size (kg) at reference week for each woman
  pred_size <- predict(
    model,
    newdata = data.frame(
      gestational_age = ref_week,
      id = ranef_df$id
    ),
    level = 1
  )

  # Predicted velocity (kg/week) at reference week for each woman
  pred_velocity <- predict(
    model,
    newdata = data.frame(
      gestational_age = ref_week,
      id = ranef_df$id
    ),
    level    = 1,
    deriv    = 1
  )

  data.frame(
    id            = ranef_df$id,
    pred_size     = pred_size,
    pred_velocity = pred_velocity
  )
}

pred_ara <- extract_individual_pred(M_ara, ref_week) %>%
  mutate(cohort = "Araraquara")
pred_jun <- extract_individual_pred(M_jun, ref_week) %>%
  mutate(cohort = "Jundiai")

sitar_predictions <- bind_rows(pred_ara, pred_jun)

# ---- 6. Save outputs --------------------------------------------------------
saveRDS(sitar_predictions, file.path(paths$data, "sitar_predictions.rds"))
saveRDS(
  list(araraquara = M_ara, jundiai = M_jun,
       rho_ara = rho_ara, rho_jun = rho_jun),
  file.path(paths$output, "sitar_model_summaries.rds")
)

message(
  "SITAR modelling complete. Predicted size and velocity at week ", ref_week,
  " saved to data/sitar_predictions.rds."
)
