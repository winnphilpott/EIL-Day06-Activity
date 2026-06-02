# =============================================================================
# Script:  04_pm25_extraction.R
# Purpose: Answer Q3 -- what is each county's mean PM2.5 concentration?
#          This extracts values from the raster for each county polygon using
#          area-weighted averaging, meaning pixels that only partially overlap
#          a county contribute proportionally rather than being fully counted
#          or fully dropped.
#
#          We use exactextractr::exact_extract() rather than terra::extract()
#          because terra's default treats each raster cell as either fully
#          inside or fully outside a polygon. For small counties (relative to
#          the ~5 km cell size), this can produce noticeably wrong averages.
#          exact_extract() handles partial overlaps correctly.
#
# Inputs:
#   R objects `counties` and `pm25` (loaded by 01_setup.R)
#
# Outputs:
#   R object `counties_pm25`  -- counties sf with mean_pm25 column
#   outputs/map_pm25.png      -- choropleth map
#
# How to run:
#   source("scripts/04_pm25_extraction.R")
#
# Dependencies: 01_setup.R (sourced automatically below)
# =============================================================================

source("scripts/01_setup.R")
