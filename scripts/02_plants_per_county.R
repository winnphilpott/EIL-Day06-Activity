# =============================================================================
# Script:  02_plants_per_county.R
# Purpose: Answer Q1 -- how many power plants are located inside each county?
#          This uses a "point-in-polygon" spatial join: for each plant point,
#          find the county polygon that contains it, then count up plants
#          by county.
#
# Inputs:
#   R objects `counties` and `plants` (loaded by 01_setup.R)
#
# Outputs:
#   R object `counties_pip`            -- counties sf with n_plants column
#   outputs/map_plants_per_county.png  -- choropleth map
#
# How to run:
#   source("scripts/02_plants_per_county.R")
#
# Dependencies: 01_setup.R (sourced automatically below)
# =============================================================================

source("scripts/01_setup.R")
