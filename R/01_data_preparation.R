# =============================================================================
# 01_data_preparation.R
# -----------------------------------------------------------------------------
# Loads, cleans, and harmonises data from the Araraquara (2017-2024) and
# Jundiai (1997-2000) cohorts. Produces a single long-format dataset with
# repeated weight measurements per woman for SITAR modelling, plus a wide-
# format dataset for downstream regression analyses.
#
# INPUT (expected, not deposited in this repository):
#   data/araraquara_raw.rds  - raw Araraquara cohort dataset
#   data/jundiai_raw.rds     - raw Jundiai cohort dataset
#
# OUTPUT (produced by this script):
#   data/long_format.rds   - one row per (woman x measurement)
#   data/wide_format.rds   - one row per woman (used in Poisson regression)
# =============================================================================

# ---- 0. Setup ---------------------------------------------------------------
source("R/00_setup.R")

# ---- 1. Load raw cohort data ------------------------------------------------
# NOTE: Participant-level data are not deposited in this repository. The
# expected file structure is described in docs/data_dictionary.md. Adapt the
# loading code below to your own data source if necessary.

araraquara_raw <- readRDS(file.path(paths$data, "araraquara_raw.rds"))
jundiai_raw    <- readRDS(file.path(paths$data, "jundiai_raw.rds"))

# ---- 2. Harmonise variable names and formats --------------------------------
# Both cohorts have weight measurements at three trimester windows. The
# variables are named slightly differently and need to be harmonised before
# concatenation.

# 2.1 Araraquara harmonisation -----------------------------------------------
araraquara <- araraquara_raw %>%
  transmute(
    cohort           = "Araraquara",
    id               = as.character(a_id),
    age              = a_age,
    pre_bmi          = a_imc_pre,
    education        = a_escolaridade,
    race             = a_raca,
    parity           = a_paridade,
    gdm_t1           = a_gdm_1tri,
    htn_t1           = a_ghas_1tri,
    smoking_t1       = a_atrifumo,
    alcohol_t1       = a_atrialco,
    infant_sex       = a_sexo_rn,
    birth_weight     = a_peso_rn,
    ga_at_birth      = a_ig_parto,
    apgar5           = a_apgar5,

    # Repeated weight measurements
    ga_t1            = a_igusg_1tri,    # gestational age at first visit
    weight_t1        = a_peso_1tri,     # weight at first visit (kg)
    ga_t2            = b_igusg_2tri,
    weight_t2        = b_peso_2tri,
    ga_t3            = c_igusg_3tri,
    weight_t3        = c_peso_3tri
  )

# 2.2 Jundiai harmonisation --------------------------------------------------
jundiai <- jundiai_raw %>%
  transmute(
    cohort           = "Jundiai",
    id               = as.character(j_id),
    age              = j_age,
    pre_bmi          = j_imc_pre,
    education        = j_escolaridade,
    race             = j_raca,
    parity           = j_paridade,
    gdm_t1           = j_gdm_1tri,
    htn_t1           = j_ghas_1tri,
    smoking_t1       = j_atrifumo,
    alcohol_t1       = j_atrialco,
    infant_sex       = j_sexo_rn,
    birth_weight     = j_peso_rn,
    ga_at_birth      = j_ig_parto,
    apgar5           = j_apgar5,

    ga_t1            = j_ig_1tri,
    weight_t1        = j_peso_1tri,
    ga_t2            = j_ig_2tri,
    weight_t2        = j_peso_2tri,
    ga_t3            = j_ig_3tri,
    weight_t3        = j_peso_3tri
  )

# ---- 3. Combine cohorts -----------------------------------------------------
combined_wide <- bind_rows(araraquara, jundiai)

# ---- 4. Apply baseline exclusions -------------------------------------------
# Exclude women with multiple pregnancies, abortions, or missing core data
# (height, pre-pregnancy weight, birth weight). This step relies on flags
# present in the raw datasets; adjust filters below to match your variables.

combined_wide <- combined_wide %>%
  filter(
    !is.na(pre_bmi),
    !is.na(birth_weight)
  )

# ---- 5. Compute cumulative weight gain at each time point -------------------
# GWG at each visit = weight at visit - pre-pregnancy weight.
# Pre-pregnancy weight is implicitly weight_t1 reported back to GA = 0; if
# pre-pregnancy weight is recorded separately, replace `pre_weight` accordingly.

combined_wide <- combined_wide %>%
  mutate(
    pre_weight = weight_t1,                    # baseline reference
    gwg_t1     = weight_t1 - pre_weight,
    gwg_t2     = weight_t2 - pre_weight,
    gwg_t3     = weight_t3 - pre_weight
  )

# ---- 6. Reshape to long format for SITAR -----------------------------------
combined_long <- combined_wide %>%
  select(cohort, id, ga_t1, gwg_t1, ga_t2, gwg_t2, ga_t3, gwg_t3) %>%
  pivot_longer(
    cols = -c(cohort, id),
    names_to  = c(".value", "visit"),
    names_pattern = "(ga|gwg)_t(\\d+)"
  ) %>%
  rename(
    gestational_age = ga,
    cumulative_gwg  = gwg
  ) %>%
  filter(!is.na(gestational_age), !is.na(cumulative_gwg))

# ---- 7. Save processed datasets ---------------------------------------------
saveRDS(combined_long, file.path(paths$data, "long_format.rds"))
saveRDS(combined_wide, file.path(paths$data, "wide_format.rds"))

message(
  "Data preparation complete. ",
  nrow(combined_wide), " participants, ",
  nrow(combined_long), " weight measurements across cohorts."
)
