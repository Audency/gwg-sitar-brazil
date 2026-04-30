# Data dictionary

This document describes the variables expected by the analysis pipeline.
Participant-level data are not included in this repository, but the
pipeline can be reproduced if data with the structure described below are
made available.

The harmonised variable names used inside the pipeline (after
`R/01_data_preparation.R`) are listed in the first column of each table.
The "raw" columns indicate the typical original variable names in the
Araraquara and Jundiaí datasets.

## Participant-level variables

| Harmonised name | Description | Type | Unit |
|---|---|---|---|
| `cohort` | Cohort identifier ("Araraquara" or "Jundiai") | character | — |
| `id` | Anonymised participant identifier | character | — |
| `age` | Maternal age at first prenatal visit | numeric | years |
| `pre_bmi` | Self-reported pre-pregnancy BMI | numeric | kg/m² |
| `pre_bmi_cat` | BMI category (Underweight/Normal/Overweight/Obesity) | factor | — |
| `education` | Highest level of education | factor | — |
| `race` | Self-reported skin colour / race | factor | — |
| `parity` | Number of previous live births | integer | — |
| `gdm_t1` | Gestational diabetes diagnosed at first trimester | binary | 0/1 |
| `htn_t1` | Hypertensive disorder identified at first trimester | binary | 0/1 |
| `smoking_t1` | Current smoking at first trimester | binary | 0/1 |
| `alcohol_t1` | Current alcohol use at first trimester | binary | 0/1 |
| `infant_sex` | Newborn sex | factor | M/F |
| `birth_weight` | Birth weight | numeric | grams |
| `ga_at_birth` | Gestational age at birth | numeric | weeks |
| `apgar5` | 5-minute Apgar score | integer | 0–10 |
| `lbw` | Low birth weight (< 2,500 g) | binary | 0/1 |
| `macrosomia` | Macrosomia (≥ 4,000 g) | binary | 0/1 |
| `preterm` | Preterm birth (< 37 weeks) | binary | 0/1 |
| `apgar_low` | 5-minute Apgar < 7 | binary | 0/1 |

## Repeated weight measurements

| Harmonised name | Description | Type | Unit |
|---|---|---|---|
| `ga_t1` | Gestational age at first prenatal visit | numeric | weeks |
| `weight_t1` | Maternal weight at first visit | numeric | kg |
| `ga_t2` | Gestational age at second prenatal visit | numeric | weeks |
| `weight_t2` | Maternal weight at second visit | numeric | kg |
| `ga_t3` | Gestational age at third prenatal visit | numeric | weeks |
| `weight_t3` | Maternal weight at third visit | numeric | kg |

## Long-format dataset (used by SITAR)

After `R/01_data_preparation.R`, the long-format dataset has one row per
(woman × measurement) and contains the following variables:

| Name | Description | Unit |
|---|---|---|
| `cohort` | Cohort identifier | — |
| `id` | Participant identifier | — |
| `visit` | Visit number (1, 2, or 3) | — |
| `gestational_age` | Gestational age at visit | weeks |
| `cumulative_gwg` | Cumulative weight gain since pre-pregnancy weight | kg |

## Notes on data harmonisation

- Both cohorts use up to three weight measurements during pregnancy
  (typically at trimesters 1, 2, and 3). When fewer measurements are
  available, SITAR still fits the trajectory using the available data
  within a mixed-effects framework.
- Pre-pregnancy weight is taken as the reference for cumulative GWG
  computation. When a separate "pre-pregnancy weight" variable is
  available it should be used directly; otherwise the weight at the
  earliest visit is used as a proxy.
- Gestational age was determined by obstetric ultrasound in Araraquara
  (variable `*_igusg` in the raw data) and by mixed methods in Jundiaí
  (last menstrual period and physical assessment at delivery), reflecting
  the prenatal care protocols available in each period.
