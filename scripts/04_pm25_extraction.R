# =============================================================================
# 04_pm25_extraction.R
# Q3: What is each county's mean PM2.5?
#
# Uses exactextractr::exact_extract (area-weighted) rather than
# terra::extract (centroid-based) for accuracy with small counties.
# =============================================================================

source("scripts/01_setup.R")
