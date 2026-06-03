# =============================================================================
# Script:  03_nearby_plants.R
# Purpose: Answer Q2 -- how many power plants are within 50 km of each county?
#          This uses a "buffer join": draw a 50 km circle around each plant,
#          then count how many of those circles overlap each county.
#
#          Distance choice: 50 km.
#          Based on EPA guidelines for PM2.5 permitting
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
# Units are meters because our CRS (EPSG:5070) measures distance in meters.
# 50 km = 50,000 meters.

buffer_dist_m <- 50000  # 50 km


# ---- Buffer the plant points -------------------------------------------------

plants_buf <- st_buffer(plants, dist = buffer_dist_m)


# ---- Count nearby plants per county ------------------------------------------

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
cat("Counties with 1 nearby plant:    ", sum(counties_buf$n_plants_50km == 1), "\n")
cat("Counties with 2+ nearby plants:  ", sum(counties_buf$n_plants_50km >= 2), "\n")
cat("\nDistribution of nearby plants per county:\n")
print(summary(counties_buf$n_plants_50km))
cat("Std deviation:                   ", round(sd(counties_buf$n_plants_50km), 2), "\n")
cat("\nTop 5 counties by nearby plant count:\n")
print(
  counties_buf |>
    st_drop_geometry() |>
    arrange(desc(n_plants_50km)) |>
    select(NAME, STATEFP, n_plants_50km) |>
    head(5)
)
cat("===================================================\n\n")


# ---- Map ---------------------------------------------------------------------

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

ggsave(
  "outputs/map_nearby_plants.png",
  plot   = p_buf,
  width  = 10,
  height = 6,
  dpi    = 150
)

cat("Map saved to outputs/map_nearby_plants.png\n")
