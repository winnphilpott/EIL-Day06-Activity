# =============================================================================
# 01_setup.R
# EIL Day 6 Activity
#
# Loads the three input layers, reprojects to EPSG:5070 (NAD83/Conus Albers),
# and exposes them as `counties`, `plants`, `pm25` for downstream scripts.
# Source this once at the start of the session.
# =============================================================================

setwd("/Users/winnphilpott/Desktop/EIL Summer/EIL-Day06-Activity")

# ---- Packages ---------------------------------------------------------------

if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")

pacman::p_load(
  sf,             # vector data
  terra,          # raster data
  exactextractr,  # area-weighted raster -> polygon
  dplyr,          # data manipulation
  tidyr,          # replace_na
  ggplot2,        # plotting
  units           # km^2 etc.
)

# ---- Paths ------------------------------------------------------------------

data_raw <- "data/raw/"

# ---- Common CRS -------------------------------------------------------------
# EPSG:5070 = NAD83 / Conus Albers. Equal-area, units = meters.

target_crs <- 5070

# ---- Load and reproject -----------------------------------------------------

counties <- st_read(paste0(data_raw, "us_counties.shp"), quiet = TRUE) |>
  st_transform(target_crs) |>
  st_make_valid()

plants <- st_read(paste0(data_raw, "us_powerplants.shp"), quiet = TRUE) |>
  st_transform(target_crs)

pm25 <- rast(paste0(data_raw, "us_pm25.tif"))
pm25 <- terra::project(pm25, paste0("EPSG:", target_crs))

# ---- Sanity checks ----------------------------------------------------------

stopifnot(st_crs(counties)$epsg == target_crs)
stopifnot(st_crs(plants)$epsg == target_crs)

cat("Setup complete.\n")
cat(" counties:", nrow(counties), "polygons,  CRS =", st_crs(counties)$epsg, "\n")
cat(" plants:  ", nrow(plants),   "points,    CRS =", st_crs(plants)$epsg,   "\n")
cat(" pm25:    ", ncol(pm25), "x", nrow(pm25), "raster, CRS =",
    crs(pm25, describe = TRUE)$code, "\n")
