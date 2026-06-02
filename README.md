# EIL Day 6 Activity — Power Plants and PM2.5 Across U.S. Counties

**Author:** Winn Philpott  
**Program:** Environment Inequality Lab Summer Research Training Program 
**Date:** 2026-06-02

---

## Overview

This repository contains the code, data, and writeup for the Day 6 spatial data activity. The analysis asks whether counties that host (or are near) electricity-generating power plants tend to have higher annual mean PM2.5 concentrations than counties that do not.

## Research Questions

1. How many power plants are in each county?
2. How many power plants are within 50 km of each county?
3. What is each county's mean PM2.5 concentration?
4. Do counties with power plants — or near power plants — have higher mean PM2.5 than those without?

## Repository Structure

```
EIL-Day06-Activity/
├── data/
│   ├── raw/          ← original input files (never modify)
│   └── processed/    ← county-level summaries produced by scripts
├── scripts/          ← R scripts, run in numbered order
├── outputs/          ← maps and tables saved by the scripts
├── brief.md          ← short written summary of findings
└── README.md         ← this file
```

See the `README.md` inside each subfolder for details on its contents.

## How to Reproduce

1. Clone this repository.
2. Open R or RStudio and set your working directory to the repo root.
3. Edit the `setwd()` line at the top of `scripts/01_setup.R` to match your local path.
4. Run the scripts in order:

```r
source("scripts/02_plants_per_county.R")
source("scripts/03_nearby_plants.R")
source("scripts/04_pm25_extraction.R")
source("scripts/05_comparison.R")
```

Each script automatically sources `01_setup.R`, so you do not need to run it separately.

## Requirements

- R (version 4.1 or higher recommended)
- The following R packages (installed automatically via `pacman` if missing):
  `sf`, `terra`, `exactextractr`, `dplyr`, `tidyr`, `ggplot2`, `units`

## Data Sources

| File | Description | Source |
|------|-------------|--------|
| `us_counties.shp` | County boundaries for the contiguous U.S. | U.S. Census Bureau TIGER/Line |
| `us_powerplants.shp` | Electricity-generating facilities ≥ 1 MW | EIA Form 860 |
| `us_pm25.tif` | Annual mean PM2.5 surface, ~5 km resolution | EPA / satellite-derived surface |

Full details in `data/README.md`.

## Outputs

Maps and summary tables are saved to `outputs/`. See `outputs/README.md` for a full list.

## Writeup

See `brief.md` for a short written summary of the findings and what they suggest about the relationship between power plant siting and air quality.
