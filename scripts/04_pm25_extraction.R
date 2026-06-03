# =============================================================================
# Script:  04_pm25_extraction.R
# Purpose: Answer Q3 -- what is each county's mean PM2.5 concentration?
#          This extracts values from the raster for each county polygon using
#          area-weighted averaging, meaning pixels that only partially overlap
#          a county contribute proportionally rather than being fully counted
#          or fully dropped.
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


# ---- Extract mean PM2.5 per county -------------------------------------------

counties_pm25 <- counties |>
  mutate(
    mean_pm25 = exact_extract(pm25, geometry, fun = "mean", progress = FALSE)
  )


# ---- Sanity check ------------------------------------------------------------

cat("\n=== Sanity Check: PM2.5 Extraction ===\n")
cat("Counties with non-NA mean PM2.5: ", sum(!is.na(counties_pm25$mean_pm25)), "of", nrow(counties_pm25), "\n")
cat("Counties with NA mean PM2.5:     ", sum(is.na(counties_pm25$mean_pm25)), "\n")
cat("\nDistribution of mean PM2.5 per county (ug/m^3):\n")
print(summary(counties_pm25$mean_pm25))
cat("Std deviation:                   ", round(sd(counties_pm25$mean_pm25, na.rm = TRUE), 2), "\n")
cat("\nTop 5 counties by highest mean PM2.5:\n")
print(
  counties_pm25 |>
    st_drop_geometry() |>
    arrange(desc(mean_pm25)) |>
    select(NAME, STATEFP, mean_pm25) |>
    head(5)
)
cat("\nTop 5 counties by lowest mean PM2.5:\n")
print(
  counties_pm25 |>
    st_drop_geometry() |>
    arrange(mean_pm25) |>
    select(NAME, STATEFP, mean_pm25) |>
    head(5)
)
cat("=======================================\n\n")


# ---- Map ---------------------------------------------------------------------

p_pm25 <- ggplot(counties_pm25) +
  geom_sf(aes(fill = mean_pm25), color = NA) +
  scale_fill_viridis_c(
    name   = "Mean PM2.5\n(ug/m^3)",
    option = "magma"
  ) +
  labs(
    title   = "Mean annual PM2.5 by county, contiguous U.S.",
    caption = "Source: EPA / satellite-derived PM2.5 surface"
  ) +
  theme_void() +
  theme(legend.position = "right")

ggsave(
  "outputs/map_pm25.png",
  plot   = p_pm25,
  width  = 10,
  height = 6,
  dpi    = 150
)

cat("Map saved to outputs/map_pm25.png\n")
