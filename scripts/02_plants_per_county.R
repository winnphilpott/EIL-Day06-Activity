# =============================================================================
# Script:  02_plants_per_county.R
# Purpose: Answer Q1 -- how many power plants are located inside each county?
#          This uses a "point-in-polygon" spatial join: for each plant point,
#          find the county polygon that contains it, then count up plants
#          by county.
#
# Inputs:
#   R objects `counties` and `plants` (loaded by 01_setup.R)
#
# Outputs:
#   R object `counties_pip`            -- counties sf with n_plants column
#   outputs/map_plants_per_county.png  -- choropleth map
#
# How to run:
#   source("scripts/02_plants_per_county.R")
#
# Dependencies: 01_setup.R (sourced automatically below)
# =============================================================================

source("scripts/01_setup.R")


# ---- Point-in-polygon join ---------------------------------------------------
# st_join() attaches county attributes to each plant point based on which
# county polygon contains it. The result has one row per plant, with the
# plant's own columns plus the GEOID and NAME of its containing county.
#
# join = st_within means: attach county info to a plant only if the plant
# falls entirely *within* that county. Plants that land exactly on a county
# border (a common geocoding artifact) may not match any county -- we flag
# those in the sanity check below.

plants_with_county <- st_join(
  plants,
  counties |> select(GEOID, NAME),
  join = st_within
)


# ---- Count plants per county -------------------------------------------------
# Drop the point geometry (we no longer need coordinates) and count how many
# plants share each GEOID. The result is a plain data frame, one row per
# county that contains at least one plant.

plant_counts <- plants_with_county |>
  st_drop_geometry() |>
  count(GEOID, name = "n_plants")


# ---- Attach counts back to the county polygons -------------------------------
# Left join keeps all 3,109 counties, including those with zero plants.
# Counties with no matching plants will have NA after the join; replace_na()
# converts those NAs to 0 so the column is clean for mapping and analysis.

counties_pip <- counties |>
  left_join(plant_counts, by = "GEOID") |>
  mutate(n_plants = replace_na(n_plants, 0L))


# ---- Sanity check ------------------------------------------------------------
# The count of matched plants should be close to (but may not exactly equal)
# the total number of plants. Any gap means some plants fell outside all
# county polygons -- this is normal for plants near coastlines or on
# simplified boundaries, but a large gap would suggest a data problem.

cat("\n=== Sanity Check: Plant-to-County Matching ===\n")
cat("Total plants in raw data:       ", nrow(plants), "\n")
cat("Total plants matched to county: ", sum(plant_counts$n_plants), "\n")
cat("Unmatched (outside any county): ", nrow(plants) - sum(plant_counts$n_plants), "\n")
cat("Counties with >= 1 plant:       ", sum(counties_pip$n_plants > 0), "of", nrow(counties_pip), "\n")
cat("==============================================\n\n")


# ---- Map ---------------------------------------------------------------------
# Choropleth: each county shaded by its plant count.
# We use a square-root color scale (trans = "sqrt") because a handful of
# counties have very high counts that would wash out the rest of the map
# on a linear scale.

p_pip <- ggplot(counties_pip) +
  geom_sf(aes(fill = n_plants), color = "white", linewidth = 0.1) +
  scale_fill_viridis_c(
    name   = "Power plants",
    option = "magma",
    trans  = "sqrt"
  ) +
  labs(
    title    = "Power plants per county, contiguous U.S.",
    subtitle = "EIA-860 facilities ≥ 1 MW",
    caption  = "Source: EIA Form 860"
  ) +
  theme_void() +
  theme(legend.position = "right")

print(p_pip)

ggsave(
  "outputs/map_plants_per_county.png",
  plot   = p_pip,
  width  = 10,
  height = 6,
  dpi    = 150
)

cat("Map saved to outputs/map_plants_per_county.png\n")
