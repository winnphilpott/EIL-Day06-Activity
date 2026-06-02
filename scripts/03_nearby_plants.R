# =============================================================================
# Script:  03_nearby_plants.R
# Purpose: Answer Q2 -- how many power plants are within 50 km of each county?
#          This uses a "buffer join": draw a 50 km circle around each plant,
#          then count how many of those circles overlap each county.
#
#          Distance choice: 50 km.
#          Power plant emissions (especially from fossil fuels) can travel
#          tens of kilometers downwind. A 50 km radius captures meaningful
#          cross-county spillovers while remaining sub-regional in scale.
#          It also exceeds the ~5 km raster resolution, so the PM2.5 surface
#          has spatial variation that is meaningful at this distance.
#
# Inputs:
#   R objects `counties` and `plants` (loaded by 01_setup.R)
#
# Outputs:
#   R object `counties_buf`        -- counties sf with n_plants_50km column
#   outputs/map_nearby_plants.png  -- choropleth map
#
# How to run:
#   source("scripts/03_nearby_plants.R")
#
# Dependencies: 01_setup.R (sourced automatically below)
# =============================================================================

source("scripts/01_setup.R")
