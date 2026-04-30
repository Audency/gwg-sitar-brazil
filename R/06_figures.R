# =============================================================================
# 06_figures.R
# -----------------------------------------------------------------------------
# Generates the main and supplementary figures of the manuscript.
#
# Figure 1: SITAR fitted GWG curves and velocity curves for both cohorts,
#           with harmonised x-axis (gestational weeks 14-40) addressing
#           Reviewer 1, Comment 6.
#
# Supplementary Figure S3: Residual diagnostic plots from the SITAR models.
# Supplementary Figure (joint random effects): Scatter plot of size vs.
#           velocity random effects (response to Reviewer 3, Comment 12;
#           Eric Ohuma's suggestion).
#
# INPUT:
#   data/long_format.rds
#   output/sitar_model_summaries.rds
#
# OUTPUT (saved to output/):
#   figure1_sitar_curves.png/.pdf
#   figureS3_residual_diagnostics.png/.pdf
#   figureS_joint_random_effects.png/.pdf
# =============================================================================

source("R/00_setup.R")

# ---- 1. Load fitted models and data ----------------------------------------
combined_long <- readRDS(file.path(paths$data, "long_format.rds"))
sitar_models  <- readRDS(file.path(paths$output, "sitar_model_summaries.rds"))

M_ara <- sitar_models$araraquara
M_jun <- sitar_models$jundiai

# ---- 2. Figure 1: SITAR fits with harmonised x-axis ------------------------
# Reviewer 1 (Comment 6) noted that velocity curves started at week 5 while
# size curves started at week 10. We now use xlim = c(14, 40) for all panels.

png(
  filename = file.path(paths$output, "figure1_sitar_curves.png"),
  width = 10, height = 7, units = "in", res = 300
)

par(mfrow = c(2, 3), mar = c(4, 4, 3, 1))

# --- Araraquara: crude weight gain ---
mplot(
  x = gestational_age, y = cumulative_gwg, id = id,
  data   = combined_long %>% filter(cohort == "Araraquara"),
  xlim   = c(14, 40), ylim = c(-5, 25),
  xlab   = "Gestational age (weeks)", ylab = "Cumulative GWG (kg)",
  main   = "A. Araraquara — observed", col = "grey60"
)

# --- Araraquara: SITAR fit ---
plot(
  M_ara, opt = "d",
  xlim = c(14, 40), ylim = c(-5, 25),
  col  = "red", lwd = 2,
  xlab = "Gestational age (weeks)", ylab = "Cumulative GWG (kg)",
  main = "B. Araraquara — SITAR fit"
)

# --- Araraquara: velocity ---
plot(
  M_ara, opt = "v",
  xlim = c(14, 40), ylim = c(0, 0.6),
  col  = "red", lwd = 2, lty = 2,
  xlab = "Gestational age (weeks)", ylab = "Velocity (kg/week)",
  main = "C. Araraquara — velocity"
)

# --- Jundiai: crude weight gain ---
mplot(
  x = gestational_age, y = cumulative_gwg, id = id,
  data   = combined_long %>% filter(cohort == "Jundiai"),
  xlim   = c(14, 40), ylim = c(-5, 25),
  xlab   = "Gestational age (weeks)", ylab = "Cumulative GWG (kg)",
  main   = "D. Jundiai — observed", col = "grey60"
)

# --- Jundiai: SITAR fit ---
plot(
  M_jun, opt = "d",
  xlim = c(14, 40), ylim = c(-5, 25),
  col  = "darkgreen", lwd = 2,
  xlab = "Gestational age (weeks)", ylab = "Cumulative GWG (kg)",
  main = "E. Jundiai — SITAR fit"
)

# --- Jundiai: velocity ---
plot(
  M_jun, opt = "v",
  xlim = c(14, 40), ylim = c(0, 0.6),
  col  = "darkgreen", lwd = 2, lty = 2,
  xlab = "Gestational age (weeks)", ylab = "Velocity (kg/week)",
  main = "F. Jundiai — velocity"
)

dev.off()

# ---- 3. Supplementary Figure S3: residual diagnostics ----------------------
png(
  filename = file.path(paths$output, "figureS3_residual_diagnostics.png"),
  width = 10, height = 5, units = "in", res = 300
)

par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))

plot(
  fitted(M_ara), resid(M_ara),
  xlab = "Fitted values (kg)", ylab = "Residuals (kg)",
  main = "Araraquara — residual diagnostics",
  pch = 16, cex = 0.5, col = adjustcolor("red", alpha.f = 0.4)
)
abline(h = 0, lty = 2, col = "grey30")

plot(
  fitted(M_jun), resid(M_jun),
  xlab = "Fitted values (kg)", ylab = "Residuals (kg)",
  main = "Jundiai — residual diagnostics",
  pch = 16, cex = 0.5, col = adjustcolor("darkgreen", alpha.f = 0.4)
)
abline(h = 0, lty = 2, col = "grey30")

dev.off()

# ---- 4. Supplementary Figure: joint random effects -------------------------
# Following Ohuma et al. BMJ Glob Health 2021 (ref. 45) — visualise the
# joint distribution of size and velocity random effects.

re_ara <- as.data.frame(ranef(M_ara)) %>% mutate(cohort = "Araraquara")
re_jun <- as.data.frame(ranef(M_jun)) %>% mutate(cohort = "Jundiai")
re_all <- bind_rows(re_ara, re_jun)

p_re <- ggplot(re_all, aes(x = a, y = c, colour = cohort)) +
  geom_point(alpha = 0.4, size = 1) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey30") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey30") +
  scale_colour_manual(values = c("Araraquara" = "red", "Jundiai" = "darkgreen")) +
  facet_wrap(~ cohort) +
  labs(
    x = "Size random effect (a)",
    y = "Velocity random effect (c)",
    colour = "Cohort"
  ) +
  theme_bw(base_size = 12) +
  theme(legend.position = "none")

ggsave(
  filename = file.path(paths$output, "figureS_joint_random_effects.png"),
  plot = p_re, width = 8, height = 4, dpi = 300
)

message("Figures generated successfully and saved to output/.")
