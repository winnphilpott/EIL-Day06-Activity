# =============================================================================
# 05_comparison.R
# Compare mean PM2.5 in counties with vs. without power plants.
#
# Two measures of "with plants":
#   (a) within-county count > 0  (from 02_plants_per_county.R)
#   (b) nearby count > 0         (from 03_nearby_plants.R)
# =============================================================================

source("scripts/01_setup.R")
