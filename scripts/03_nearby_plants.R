# =============================================================================
# 03_nearby_plants.R
# Q2: How many plants are within 50 km of each county?
#
# Distance choice: 50 km. Power plant emissions (especially fossil fuels)
# can travel tens of kilometers, and 50 km captures meaningful cross-county
# spillovers while remaining sub-regional. It also exceeds the ~5 km raster
# resolution, so spatial variation in the PM2.5 surface is meaningful at
# this scale.
# =============================================================================

source("scripts/01_setup.R")
