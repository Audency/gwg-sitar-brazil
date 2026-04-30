# Modelling gestational weight gain trajectories using SITAR in two Brazilian cohorts

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Made with R](https://img.shields.io/badge/Made%20with-R-1f425f.svg)](https://www.r-project.org/)

## Overview

This repository contains the R analysis code for the manuscript:

> **Modelling gestational weight gain trajectories and risk of adverse birth outcomes using Super Imposition by Translation and Rotation: Findings from two Brazilian cohort studies.**
> *The Lancet Regional Health – Americas* (2026, under review).
> Manuscript reference: TLRHAMERICAS-D-26-00207.

The analysis applies the **Super Imposition by Translation and Rotation (SITAR)** approach to model individual gestational weight gain (GWG) trajectories in two Brazilian cohorts conducted approximately two decades apart:

- **Araraquara cohort** (2017–2024) — São Paulo state, Brazil
- **Jundiaí cohort** (1997–2000) — São Paulo state, Brazil

Predicted GWG size and velocity at gestational week 36 are classified relative to the **INTERGROWTH-21st GWG standard** (P25, P25–P75, P75 categories) and associated with neonatal outcomes (low birth weight, macrosomia, preterm birth, and low 5-minute Apgar score) using Poisson regression with robust variance.

## Repository structure

```
gwg-sitar-brazil/
├── README.md                       # this file
├── LICENSE                         # MIT license
├── R/
│   ├── 00_setup.R                  # packages and global options
│   ├── 01_data_preparation.R       # cohort harmonisation and reshaping
│   ├── 02_descriptive_analysis.R   # baseline tables and summaries
│   ├── 03_sitar_modelling.R        # SITAR model fitting and diagnostics
│   ├── 04_intergrowth_classification.R  # IG-21st centile classification
│   ├── 05_poisson_regression.R     # adjusted risk ratio estimation
│   ├── 06_figures.R                # main and supplementary figures
│   └── 07_supplementary_tables.R   # supplementary tables
├── docs/
│   ├── data_dictionary.md          # variable descriptions
│   └── analysis_notes.md           # notes on methodological decisions
└── output/                         # figures and tables (created at runtime)
```

## Data availability

In line with the ethical approvals and data-sharing policies of the
Araraquara and Jundiaí cohorts, **participant-level data are not deposited
in this public repository**. Reasonable requests for data access should be
directed to the corresponding author and will be evaluated according to
the cohorts' governance frameworks.

The R code is publicly available to ensure analytic reproducibility.
Researchers with access to the underlying data, or to comparable cohort
data with the same variable structure, can run the full pipeline by
adapting the data-loading steps in `R/01_data_preparation.R`.

## Software requirements

- R ≥ 4.2.0
- The following R packages (CRAN):
  - `sitar` (≥ 1.4.0) — SITAR modelling
  - `dplyr`, `tidyr`, `purrr`, `stringr` — data manipulation
  - `ggplot2`, `patchwork`, `cowplot` — visualisation
  - `sandwich`, `lmtest` — robust standard errors for Poisson regression
  - `gtsummary`, `flextable` — tabular outputs
  - `nlme` — mixed-effects framework underlying SITAR

Install all required packages with:

```r
install.packages(c(
  "sitar", "dplyr", "tidyr", "purrr", "stringr",
  "ggplot2", "patchwork", "cowplot",
  "sandwich", "lmtest",
  "gtsummary", "flextable",
  "nlme"
))
```

## How to run

```r
# From the repository root:
source("R/00_setup.R")
source("R/01_data_preparation.R")
source("R/02_descriptive_analysis.R")
source("R/03_sitar_modelling.R")
source("R/04_intergrowth_classification.R")
source("R/05_poisson_regression.R")
source("R/06_figures.R")
source("R/07_supplementary_tables.R")
```

Each script is self-contained, documented, and writes its outputs to
the `output/` directory.

## Key methodological choices

- **SITAR specification**: random effects for size (a) and velocity (c)
  only. The timing (b) random effect was omitted because the full
  three-parameter model did not achieve stable convergence in either
  cohort, consistent with prior applications in GWG (Riddell et al. 2017)
  and in child linear growth (Ohuma et al. 2021).
- **Reference week for parameter extraction**: gestational week 36, the
  last gestational-age window of routine maternal weight measurement in
  both cohorts.
- **GWG classification**: P25, P25–P75, and >P75 of the INTERGROWTH-21st
  GWG standard (Cheikh Ismail et al. 2016).
- **Risk ratio estimation**: Poisson regression with log link and robust
  variance estimation (Zou 2004).
- **Population restricted**: women with normal pre-pregnancy BMI
  (18.5–<25 kg/m²) for the regression analyses, as required by the
  INTERGROWTH-21st GWG standard.

## Citation

If you use this code, please cite the manuscript:

> Victor A, Rondó PHC, Ohuma EO, et al. Modelling gestational weight gain
> trajectories and risk of adverse birth outcomes using Super Imposition by
> Translation and Rotation: Findings from two Brazilian cohort studies.
> *The Lancet Regional Health – Americas.* 2026 (in press).

## Corresponding author

Audêncio Victor — London School of Hygiene & Tropical Medicine (LSHTM), UK.

## License

This code is released under the [MIT License](LICENSE).
