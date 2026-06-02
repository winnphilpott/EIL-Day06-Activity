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

# The enrgy_s field is important for the "Going Further" section.
# Check the distribution of energy source codes:
cat("\nEnergy source codes (enrgy_s), all values sorted by frequency:\n")
print(sort(table(plants$enrgy_s), decreasing = TRUE))


# ---- pm25: a raster ----------------------------------------------------------
# print() shows dimensions, resolution, CRS, and value range.

cat("\n--- PM2.5 RASTER ---\n")
print(pm25)
cat("\nSummary of PM2.5 cell values (ug/m^3):\n")
print(summary(values(pm25)))
# Watch for: all-NA values, or a range that seems physically implausible.
# Annual mean PM2.5 in the U.S. typically runs from ~2 to ~15 ug/m^3.


# ---- Data quality check 1: join key uniqueness -------------------------------
# If GEOID is not unique in counties, a left_join() will silently duplicate
# rows -- a very common and hard-to-spot bug. Same logic for plant_d in plants.

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
# Two different plants can share the same address (co-located facilities on the
# same site). That is NOT a data error. Check both, and don't confuse them.

cat("\nplants: fully duplicated rows:   ", sum(duplicated(st_drop_geometry(plants))), "\n")
cat(
  "plants: duplicated coordinates: ", sum(duplicated(st_coordinates(plants))),
  " (co-located facilities -- expected, not necessarily a problem)\n"
)


# ---- Data quality check 3: missing values ------------------------------------
# NAs in a key column or a variable you plan to filter on will propagate
# silently. Check every column.

cat("\nNAs per column (plants):\n")
print(colSums(is.na(st_drop_geometry(plants))))


# ---- Data quality check 4: dead columns --------------------------------------
# A column with only one unique value carries no information. Worth knowing
# before you try to group, filter, or map by it.

cat("\nDistinct values per plants column:\n")
print(sapply(st_drop_geometry(plants), function(x) length(unique(x))))


# ---- Data quality check 5: geometry health -----------------------------------
# Empty or invalid geometries will silently break spatial joins and buffers.
# 01_setup.R already ran st_make_valid() on counties -- confirm it took.

cat(
  "\nEmpty geometries   -- counties:", sum(st_is_empty(counties)),
  "  plants:", sum(st_is_empty(plants)), "\n"
)
cat(
  "Invalid geometries -- counties:", sum(!st_is_valid(counties)),
  "  plants:", sum(!st_is_valid(plants)), "\n"
)


# ---- Visual check 1: do the points land on the counties? --------------------
# If the points don't overlap the county polygons, the CRSs are out of sync.
# Fix that before running any join -- misaligned layers produce silently wrong
# results, not errors.

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
# A histogram lets you see whether the range is physically plausible and whether
# the distribution looks reasonable (no spike at zero, no extreme outliers).

hist(
  values(pm25),
  breaks = 40,
  col    = "#00B3BE",
  border = "white",
  main   = "Distribution of PM2.5 cell values",
  xlab   = "PM2.5 (ug/m^3)"
)


# =============================================================================
# BEFORE MOVING ON, ask yourself:
#   - Do all three layers report the same CRS (EPSG:5070)?
#   - Is GEOID unique in counties? Is plant_d unique in plants?
#   - Any duplicate rows, missing values, or dead (single-value) columns?
#   - Do both geometry layers pass the empty/valid checks?
#   - Do the plant points fall inside the U.S., on top of the counties?
#   - Is the PM2.5 range physically sensible (roughly 2-15 ug/m^3)?
# If anything looks off, stop and sort it out -- it will not fix itself later.
# =============================================================================
