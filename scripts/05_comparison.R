# =============================================================================
# Script:  05_comparison.R
# Purpose: Join all county-level measures and compare mean PM2.5 between
#          counties with and without power plants.
#
#          We report two comparisons:
#            (a) Within-county: counties where n_plants > 0 vs. n_plants == 0
#            (b) Nearby:        counties where n_plants_50km > 0 vs. == 0
#
#          Reporting both lets us see whether the result is sensitive to how
#          we define "exposed to power plants."
#
# Inputs:
#   R objects produced by scripts 02, 03, and 04:
#     counties_pip   -- county plant counts       (from 02_plants_per_county.R)
#     counties_buf   -- nearby plant counts        (from 03_nearby_plants.R)
#     counties_pm25  -- mean PM2.5 per county      (from 04_pm25_extraction.R)
#
# Outputs:
#   outputs/pm25_comparison.png          -- bar chart of the two comparisons
#   data/processed/counties_summary.csv  -- full county-level table
#
# How to run:
#   source("scripts/05_comparison.R")
#
# Dependencies: scripts 02-04 (sourced automatically below)
# =============================================================================

source("scripts/02_plants_per_county.R")
source("scripts/03_nearby_plants.R")
source("scripts/04_pm25_extraction.R")


# ---- Join all county-level measures ------------------------------------------
# Each of the three upstream scripts produced a version of the counties sf
# with one new column. Here we drop the geometry and join them all together
# into a single flat data frame -- one row per county, all measures together.
# We use GEOID as the join key throughout.

counties_summary <- counties_pm25 |>
  st_drop_geometry() |>
  select(GEOID, NAME, STATEFP, mean_pm25) |>
  left_join(
    st_drop_geometry(counties_pip) |> select(GEOID, n_plants),
    by = "GEOID"
  ) |>
  left_join(
    st_drop_geometry(counties_buf) |> select(GEOID, n_plants_50km),
    by = "GEOID"
  )


# ---- Create plant-presence indicators ----------------------------------------
# Convert the raw counts into binary yes/no indicators that we can use to
# split counties into groups for comparison.

counties_summary <- counties_summary |>
  mutate(
    has_plant        = n_plants > 0,        # TRUE if county contains >= 1 plant
    has_nearby_plant = n_plants_50km > 0    # TRUE if county has >= 1 plant within 50 km
  )


# ---- Sanity check ------------------------------------------------------------

cat("\n=== Sanity Check: County Summary Table ===\n")
cat("Total counties:                    ", nrow(counties_summary), "\n")
cat("Counties WITH a plant (within):    ", sum(counties_summary$has_plant), "\n")
cat("Counties WITHOUT a plant (within): ", sum(!counties_summary$has_plant), "\n")
cat("Counties WITH a nearby plant:      ", sum(counties_summary$has_nearby_plant), "\n")
cat("Counties WITHOUT a nearby plant:   ", sum(!counties_summary$has_nearby_plant), "\n")
cat("Any NAs in mean_pm25:              ", sum(is.na(counties_summary$mean_pm25)), "\n")
cat("==========================================\n\n")


# ---- Compute group means -----------------------------------------------------
# For each of the two plant-presence indicators, compute the mean PM2.5
# across counties in each group. This is the core comparison the assignment asks for.

comparison <- data.frame(
  measure = c("Within-county", "Within-county", "Nearby (50 km)", "Nearby (50 km)"),
  group   = c("Has plant", "No plant", "Has nearby plant", "No nearby plant"),
  mean_pm25 = c(
    mean(counties_summary$mean_pm25[counties_summary$has_plant],        na.rm = TRUE),
    mean(counties_summary$mean_pm25[!counties_summary$has_plant],       na.rm = TRUE),
    mean(counties_summary$mean_pm25[counties_summary$has_nearby_plant], na.rm = TRUE),
    mean(counties_summary$mean_pm25[!counties_summary$has_nearby_plant],na.rm = TRUE)
  )
)

cat("=== PM2.5 Comparison Results ===\n")
print(comparison)
cat("================================\n\n")


# ---- Bar chart ---------------------------------------------------------------
# Display the four group means side by side, with the two measures in separate
# panels so the within-county and nearby comparisons are easy to read.

p_comparison <- ggplot(comparison, aes(x = group, y = mean_pm25, fill = group)) +
  geom_col(width = 0.6) +
  facet_wrap(~ measure, scales = "free_x") +
  scale_fill_manual(
    values = c(
      "Has plant"        = "#E57200",
      "No plant"         = "#B0B0B0",
      "Has nearby plant" = "#E57200",
      "No nearby plant"  = "#B0B0B0"
    )
  ) +
  labs(
    title   = "Mean PM2.5 by power plant presence, contiguous U.S. counties",
    x       = NULL,
    y       = "Mean PM2.5 (ug/m^3)",
    caption = "Sources: EIA Form 860; EPA / satellite-derived PM2.5 surface"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(p_comparison)

ggsave(
  "outputs/pm25_comparison.png",
  plot   = p_comparison,
  width  = 8,
  height = 5,
  dpi    = 150
)

cat("Bar chart saved to outputs/pm25_comparison.png\n")


# ---- Save county-level summary to processed data folder ----------------------
# Writing the full county-level table to a CSV makes it easy to inspect,
# share, or use in other tools (e.g., Excel, Stata) without re-running R.

write.csv(
  counties_summary,
  "data/processed/counties_summary.csv",
  row.names = FALSE
)

cat("County summary saved to data/processed/counties_summary.csv\n")
