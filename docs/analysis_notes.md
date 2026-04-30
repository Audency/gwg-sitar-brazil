# Analysis notes

This document records the main methodological decisions taken during the
analysis, including the rationale for each choice and references to the
relevant literature.

## 1. Choice of trajectory model: SITAR

The Super Imposition by Translation and Rotation (SITAR) model was
selected because our analytic aim was to derive **continuous,
clinically interpretable** GWG metrics (in kg and kg/week) that could be
benchmarked directly against the INTERGROWTH-21st GWG standard.

Alternative approaches considered:

- **Latent class trajectory models (LCTM)** — yield categorical class
  membership rather than continuous measurements; less suited to our
  comparison with a continuous international standard, and less stable
  with the density of our longitudinal data (2–3 measurements per woman).
- **Spline linear mixed-effects models** — flexible but do not parameterise
  individual deviations in interpretable dimensions of size and velocity.

## 2. SITAR specification: two random effects

We specified random effects for **size (a)** and **velocity (c)** only,
omitting the **timing (b)** random effect. Models with all three random
effects did not achieve stable convergence in either cohort.

This two-parameter specification is consistent with prior applications:

- Riddell CA et al. *Paediatr Perinat Epidemiol* 2017;31:116–25 — described
  the same convergence difficulties when applying SITAR to GWG data.
- Ohuma EO et al. *BMJ Glob Health* 2021;6:e004107 — used a structurally
  similar two-parameter SITAR formulation to model child linear growth
  across 64 countries.

## 3. Reference week: gestational week 36

Predicted size and velocity from the fitted SITAR models were extracted at
**gestational week 36** for each participant. Three considerations
informed this choice:

1. **Last gestational-age window of routine measurement.** Maternal weight
   was routinely recorded up to ~36 weeks in both cohorts (third-trimester
   assessment, 30–36 weeks). Beyond week 36, weight measurement was not
   part of the prenatal protocol; extracting later would rely on
   extrapolation.

2. **Plateau of cumulative GWG.** Although the INTERGROWTH-21st GWG
   standard extends to week 40, mean weekly weight gain decelerates after
   ~34 weeks (0.37 kg/week in the 34–40 window vs. 0.52–0.57 kg/week
   earlier; Cheikh Ismail et al. *BMJ* 2016). Approximately 92% of total
   GWG has already been achieved by week 36.

3. **Low frequency of prior delivery.** At week 36, 94.6% of Araraquara
   and 97.6% of Jundiaí participants remained undelivered. Very preterm
   birth (<32 weeks) was infrequent (1.6% and 0.1% respectively).

## 4. Centile thresholds: 25th and 75th

The 25th and 75th centiles of the INTERGROWTH-21st GWG standard were
selected as classification thresholds because they align with the IOM
recommendations for women with normal pre-pregnancy weight:

- The weight gain between the 25th and 75th centiles at term in the
  INTERGROWTH-21st Fetal Growth Longitudinal Study (10.9–17.9 kg) was
  comparable with the IOM recommendation for women with normal
  pre-pregnancy weight (11.5–16.0 kg).
- Aligned with the optimal GWG ranges reported in a secondary analysis of
  the INTERBIO-21st Fetal Study (Jabin et al. *Am J Clin Nutr* 2025).

## 5. Risk ratio estimation: Poisson regression with robust variance

Risk ratios with 95% confidence intervals were estimated using **Poisson
regression with a log link and robust variance estimation** (Zou G.
*Am J Epidemiol* 2004;159:702–706). This approach is preferred over
log-binomial regression for common outcomes and is robust to model
misspecification.

## 6. Restriction to women with normal pre-pregnancy BMI

The INTERGROWTH-21st GWG standard is applicable only to women with normal
pre-pregnancy BMI. Adjusted Poisson regression analyses comparing
P25–P75 with <P25 and >P75 categories were therefore restricted to
participants with pre-pregnancy BMI in the normal range
(18.5–<25 kg/m²). Descriptive characteristics of the full cohort are
reported in Table 1 of the manuscript for context.

## 7. Handling of missing data

All regression analyses were performed on **complete cases**: participants
with missing data on the outcome or on any covariate included in the
Poisson model were excluded from that specific analysis. No multiple
imputation was undertaken.

The SITAR model itself uses all available weight measurements per
participant within a mixed-effects framework that accommodates unbalanced
repeated-measures data, so missingness primarily affected the downstream
Poisson regression models rather than the trajectory modelling.

## 8. Outlier handling

Outliers were inspected using residual diagnostic plots from the fitted
SITAR models (fitted vs. residual values; Supplementary Figure S3).
Implausible weight values identified during the data cleaning stage
(e.g., values inconsistent with biologically plausible weekly changes)
were flagged and verified against the original records before SITAR
modelling.

## 9. Cohort harmonisation: outcome selection

Neonatal outcomes were pre-specified during cohort harmonisation based on
three criteria:

1. **Routine recording with identical operational definitions** in both
   the Araraquara and Jundiaí cohorts, enabling direct between-cohort
   comparison.
2. **Consistent use in the prior GWG literature**, facilitating
   comparison with existing evidence.
3. **Representation of distinct physiological pathways**: fetal growth
   (LBW, macrosomia), timing of delivery (preterm birth), and immediate
   neonatal adaptation (Apgar at 5 minutes).

SGA and LGA were not included as outcomes because the two cohorts differ
in the precision of gestational age estimation at delivery (obstetric
ultrasound in Araraquara vs. predominantly last menstrual period in
Jundiaí, 1997–2000), and a one-week dating error can shift a newborn
between SGA/LGA categories. LBW and macrosomia, defined by absolute
birthweight thresholds, are independent of gestational age and were
therefore retained as the harmonised birthweight outcomes.
