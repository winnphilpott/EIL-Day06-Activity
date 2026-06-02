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


# ---- Set buffer distance -----------------------------------------------------
# Storing the distance as a named variable (rather than writing 50000 directly
# in the st_buffer() call) makes it easy to change later and makes the code
# self-documenting.
#
# Units are meters because our CRS (EPSG:5070) measures distance in meters.
# 50 km = 50,000 meters.

buffer_dist_m <- 50000  # 50 km


# ---- Buffer the plant points -------------------------------------------------
# st_buffer() draws a circle of radius `buffer_dist_m` around each plant point.
# The result is a new sf object where each row is a circle (polygon), not a
# point. We are not changing what the plants *are* -- we are just giving each
# one a zone of influence.

plants_buf <- st_buffer(plants, dist = buffer_dist_m)


# ---- Count nearby plants per county ------------------------------------------
# st_intersects(counties, plants_buf) asks: for each county, which plant
# buffers touch it? It returns a list with one element per county; each
# element is a vector of indices of the plant buffers that overlap that county.
# lengths() converts each vector to a count.
#
# This captures plants that are near a county even if they are not inside it --
# which is exactly what the "nearby" measure is designed to do.

counties_buf <- counties |>
  mutate(
    n_plants_50km = lengths(st_intersects(geometry, plants_buf))
  )


# ---- Sanity check ------------------------------------------------------------
# Every county should have a non-negative count. Counties near dense metro
# areas will have high counts; rural counties far from any plant may have 0.

cat("\n=== Sanity Check: Nearby Plants (50 km buffer) ===\n")
cat("Buffer distance:                 ", buffer_dist_m / 1000, "km\n")
cat("Counties with >= 1 nearby plant: ", sum(counties_buf$n_plants_50km > 0), "of", nrow(counties_buf), "\n")
cat("Counties with 0 nearby plants:   ", sum(counties_buf$n_plants_50km == 0), "\n")
cat("Max nearby plants (one county):  ", max(counties_buf$n_plants_50km), "\n")
cat("===================================================\n\n")


# ---- Map ---------------------------------------------------------------------
# Choropleth: each county shaded by how many plant buffers overlap it.
# Square-root scale keeps high-count counties from washing out the rest.

p_buf <- ggplot(counties_buf) +
  geom_sf(aes(fill = n_plants_50km), color = "white", linewidth = 0.1) +
  scale_fill_viridis_c(
    name   = "Plants within\n50 km",
    option = "magma",
    trans  = "sqrt"
  ) +
  labs(
    title    = "Power plants within 50 km of each county, contiguous U.S.",
    subtitle = "EIA-860 facilities >= 1 MW",
    caption  = "Source: EIA Form 860"
  ) +
  theme_void() +
  theme(legend.position = "right")

print(p_buf)

ggsave(
  "outputs/map_nearby_plants.png",
  plot   = p_buf,
  width  = 10,
  height = 6,
  dpi    = 150
)

cat("Map saved to outputs/map_nearby_plants.png\n")
