# =============================================================================
# Script:  01b_explore.R
# Purpose: Visually and numerically inspect all three input datasets BEFORE
#          running any analysis. Half of all spatial bugs are caught at this
#          stage -- wrong CRS, a missing column, points in the ocean, a raster
#          full of NAs. Step through each block and read the output carefully.
#
# Inputs:
#   R objects `counties`, `plants`, `pm25` (loaded by 01_setup.R)
#
# Outputs:
#   Console output and plots only -- no files are written.
#
# How to run:
#   source("scripts/01b_explore.R")
#   (or step through it block-by-block in RStudio)
#
# Dependencies: 01_setup.R (sourced automatically below)
# =============================================================================

source("scripts/01_setup.R")


# ---- counties: a polygon layer -----------------------------------------------
# print() shows the class, CRS, bounding box, and first few rows.

cat("\n--- COUNTIES ---\n")
print(counties)
cat("\nColumn names:\n")
print(names(counties))
cat("\nNumber of counties:", nrow(counties), "\n")
cat("CRS (EPSG):", st_crs(counties)$epsg, "\n")

# Preview the attribute table without the geometry column getting in the way:
cat("\nFirst 6 rows (no geometry):\n")
print(head(st_drop_geometry(counties)))


# ---- plants: a point layer ---------------------------------------------------
# Each row is one electricity-generating facility.

cat("\n--- POWER PLANTS ---\n")
print(plants)
cat("\nColumn names:\n")
print(names(plants))
cat("\nNumber of plants:", nrow(plants), "\n")

cat("\nFirst 6 rows (no geometry):\n")
print(head(st_drop_geometry(plants)))

# For the "Going Further" section.
# Check the distribution of energy source codes:
cat("\nEnergy source codes (enrgy_s), all values sorted by frequency:\n")
print(sort(table(plants$enrgy_s), decreasing = TRUE))


# ---- pm25: a raster ----------------------------------------------------------

cat("\n--- PM2.5 RASTER ---\n")
print(pm25)
cat("\nSummary of PM2.5 cell values (ug/m^3):\n")
print(summary(values(pm25)))


# ---- Data quality check 1: join key uniqueness -------------------------------

cat("\n--- Data Quality Checks ---\n")
cat(
  "counties: GEOID unique?  ", !any(duplicated(counties$GEOID)),
  " (", length(unique(counties$GEOID)), "distinct of", nrow(counties), ")\n"
)
cat(
  "plants:   plant_d unique?", !any(duplicated(plants$plant_d)),
  " (", length(unique(plants$plant_d)), "distinct of", nrow(plants), ")\n"
)


# ---- Data quality check 2: duplicate records vs. duplicate coordinates -------

cat("\nplants: fully duplicated rows:   ", sum(duplicated(st_drop_geometry(plants))), "\n")
cat(
  "plants: duplicated coordinates: ", sum(duplicated(st_coordinates(plants))),
  " (co-located facilities -- expected, not necessarily a problem)\n"
)


# ---- Data quality check 3: missing values ------------------------------------

cat("\nNAs per column (plants):\n")
print(colSums(is.na(st_drop_geometry(plants))))


# ---- Data quality check 4: dead columns --------------------------------------

cat("\nDistinct values per plants column:\n")
print(sapply(st_drop_geometry(plants), function(x) length(unique(x))))


# ---- Data quality check 5: geometry health -----------------------------------

cat(
  "\nEmpty geometries   -- counties:", sum(st_is_empty(counties)),
  "  plants:", sum(st_is_empty(plants)), "\n"
)
cat(
  "Invalid geometries -- counties:", sum(!st_is_valid(counties)),
  "  plants:", sum(!st_is_valid(plants)), "\n"
)


# ---- Visual check 1: do the points land on the counties? --------------------

plot(
  st_geometry(counties),
  border = "grey40",
  main   = "Counties + power plants (do the points land on the map?)"
)
plot(st_geometry(plants), add = TRUE, pch = 20, cex = 0.3, col = "#E57200")


# ---- Visual check 2: PM2.5 raster on its own ---------------------------------
# Confirm the raster covers the contiguous U.S. and has no obvious holes.

plot(pm25, main = "PM2.5 surface (ug/m^3)")


# ---- Visual check 3: distribution of PM2.5 values ---------------------------
# Histogram

hist(
  values(pm25),
  breaks = 40,
  col    = "#00B3BE",
  border = "white",
  main   = "Distribution of PM2.5 cell values",
  xlab   = "PM2.5 (ug/m^3)"
)
