# Scripts

Run the scripts in numbered order. Each script sources `01_setup.R` at the top, so data is always loaded fresh — you do not need to run `01_setup.R` separately.

## Scripts at a glance

| Script | Purpose | Key output |
|--------|---------|------------|
| `01_setup.R` | Load packages, set paths, load and reproject all three datasets | R objects: `counties`, `plants`, `pm25` |
| `02_plants_per_county.R` | Count power plants inside each county (point-in-polygon join) | `counties` with `n_plants` column; map saved to `outputs/` |
| `03_nearby_plants.R` | Count power plants within 50 km of each county (buffer join) | `counties` with `n_plants_50km` column; map saved to `outputs/` |
| `04_pm25_extraction.R` | Extract area-weighted mean PM2.5 for each county from the raster | `counties` with `mean_pm25` column; map saved to `outputs/` |
| `05_comparison.R` | Join all county-level measures; compare PM2.5 by plant-presence group | Summary table and bar chart saved to `outputs/`; `data/processed/counties_summary.csv` |

## How to run

Open R or RStudio, make sure your working directory is the repo root, then run:

```r
source("scripts/02_plants_per_county.R")
source("scripts/03_nearby_plants.R")
source("scripts/04_pm25_extraction.R")
source("scripts/05_comparison.R")
```

If you only want to re-run one step, you can source that script alone — it will re-load the data automatically.

## A note on CRS

All spatial layers are reprojected to **EPSG:5070 (NAD83 / Conus Albers)** in `01_setup.R`. This projection:
- Covers the contiguous U.S.
- Uses meters as its unit of distance (required for meaningful buffers)
- Is equal-area (so area calculations are not distorted by latitude)
