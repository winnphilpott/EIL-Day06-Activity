# =============================================================================
# Script:  01_setup.R
# Purpose: Load all required packages and the three input datasets, then
#          reproject everything to a common coordinate system so that
#          distances and areas are meaningful in downstream scripts.
#
# Inputs:
#   data/raw/us_counties.shp     -- county boundaries, contiguous U.S.
#   data/raw/us_powerplants.shp  -- power plant locations (EIA-860)
#   data/raw/us_pm25.tif         -- annual mean PM2.5 raster
#
# Outputs (R objects available after sourcing):
#   counties  -- sf data frame of county polygons, projected to EPSG:5070
#   plants    -- sf data frame of plant points, projected to EPSG:5070
#   pm25      -- SpatRaster of PM2.5 values, projected to EPSG:5070
#
# How to run:
#   This script is sourced automatically by scripts 02-05. You do not need
#   to run it separately. If you want to run it on its own:
#     source("scripts/01_setup.R")
#
# Dependencies: none (run this first)
# =============================================================================


# ---- Working directory -------------------------------------------------------
# Point this at the root of your local copy of the repository.
# Every other file path in this project is written relative to this folder,
# so this is the only path you should ever need to change.

setwd("/Users/winnphilpott/Desktop/EIL Summer/EIL-Day06-Activity")


# ---- Packages ----------------------------------------------------------------
# We use `pacman` to manage packages: p_load() installs any package that is
# not already installed, then loads it. This means the script is self-contained
# -- a collaborator can run it on a fresh R installation without manually
# installing packages first.

if (!requireNamespace("pacman", quietly = TRUE)) install.packages("pacman")

pacman::p_load(
  sf,            # read, write, and manipulate vector spatial data (points, lines, polygons)
  terra,         # read, write, and manipulate raster spatial data
  exactextractr, # accurately summarize raster values within polygons (area-weighted)
  dplyr,         # data manipulation: filter, mutate, summarize, join
  tidyr,         # helper functions like replace_na
  ggplot2,       # plotting and mapping
  units          # handle physical units like km^2 so R doesn't silently drop them
)


# ---- File paths --------------------------------------------------------------
# Storing paths as variables means we only have to update one place if the
# folder structure ever changes.

data_raw <- "data/raw/"


# ---- Common coordinate reference system (CRS) --------------------------------
# All three layers arrive in different CRSs. Before we can do any spatial
# operations (buffers, intersections, extractions), they all need to be in
# the same CRS -- and ideally one measured in meters, not degrees.
#
# EPSG:5070 = NAD83 / Conus Albers
#   - Covers the contiguous U.S.
#   - Equal-area projection: good for area calculations
#   - Distance units: meters (required for meaningful st_buffer() distances)

target_crs <- 5070


# ---- Load and reproject: county boundaries -----------------------------------
# st_read() reads the shapefile into R as an sf data frame.
# st_transform() reprojects it to our target CRS.
# st_make_valid() repairs any malformed polygon geometries (a common issue
# with Census TIGER shapefiles near coastlines).

counties <- st_read(paste0(data_raw, "us_counties.shp"), quiet = TRUE) |>
  st_transform(target_crs) |>
  st_make_valid()


# ---- Load and reproject: power plants ----------------------------------------

plants <- st_read(paste0(data_raw, "us_powerplants.shp"), quiet = TRUE) |>
  st_transform(target_crs)


# ---- Load and reproject: PM2.5 raster ----------------------------------------
# terra::project() reprojects the raster to match the vector layers.
# Raster reprojection resamples (interpolates) the grid, so values will
# change very slightly -- this is expected and acceptable.

pm25 <- rast(paste0(data_raw, "us_pm25.tif"))
pm25 <- terra::project(pm25, paste0("EPSG:", target_crs))


# ---- Sanity checks -----------------------------------------------------------
# These will throw an error (and stop the script) if something went wrong
# with the reprojection. Better to catch it here than get mysterious errors
# later in the analysis.

stopifnot(st_crs(counties)$epsg == target_crs)
stopifnot(st_crs(plants)$epsg   == target_crs)

cat("Setup complete.\n")
cat(" counties:", nrow(counties), "polygons,  CRS =", st_crs(counties)$epsg, "\n")
cat(" plants:  ", nrow(plants),   "points,    CRS =", st_crs(plants)$epsg,   "\n")
cat(" pm25:    ", ncol(pm25), "x", nrow(pm25), "raster, CRS =",
    crs(pm25, describe = TRUE)$code, "\n")
