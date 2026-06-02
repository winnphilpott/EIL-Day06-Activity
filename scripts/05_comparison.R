# =============================================================================
# Script:  05_comparison.R
# Purpose: Join all county-level measures and compare mean PM2.5 between
#          counties with and without power plants.
#
#          We report two comparisons:
#            (a) Within-county: counties where n_plants > 0 vs. n_plants == 0
#            (b) Nearby:        counties where n_plants_50km > 0 vs. == 0
#
#          Reporting both lets us see whether the result is sensitive to how
#          we define "exposed to power plants."
#
# Inputs:
#   R objects from scripts 02, 03, and 04:
#     counties_pip   -- county plant counts (from 02_plants_per_county.R)
#     counties_buf   -- nearby plant counts (from 03_nearby_plants.R)
#     counties_pm25  -- mean PM2.5 per county (from 04_pm25_extraction.R)
#
# Outputs:
#   outputs/pm25_comparison.png          -- bar chart of the two comparisons
#   data/processed/counties_summary.csv  -- full county-level table
#
# How to run:
#   source("scripts/05_comparison.R")
#
# Dependencies: 01_setup.R (sourced automatically below), plus objects
#   produced by scripts 02-04. Run those first, or source them here.
# =============================================================================

source("scripts/01_setup.R")
source("scripts/02_plants_per_county.R")
source("scripts/03_nearby_plants.R")
source("scripts/04_pm25_extraction.R")
