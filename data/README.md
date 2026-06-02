# Data

## raw/

These are the original input files. **Do not modify them.** All scripts read from this folder but never write to it.

| File | Description | Source |
|------|-------------|--------|
| `us_counties.shp` (+ `.dbf`, `.prj`, `.shx`) | County boundaries for the contiguous U.S. | U.S. Census Bureau TIGER/Line |
| `us_powerplants.shp` (+ `.dbf`, `.prj`, `.shx`) | Every electricity-generating facility ≥ 1 MW, from EIA Form 860. The `enrgy_s` field gives the energy-source code (see table below). | U.S. Energy Information Administration |
| `us_pm25.tif` | Annual mean PM2.5 concentration surface at ~5 km resolution. Values are in µg/m³. | EPA / satellite-derived surface |

### Power plant energy source codes (`enrgy_s` field)

These are the most common codes in the dataset. Multiple codes joined by `;` indicate a plant that uses more than one fuel source.

| Code | Energy Source |
|------|---------------|
| `SUN` | Solar photovoltaic |
| `NG` | Natural gas |
| `WAT` | Conventional hydroelectric |
| `WND` | Wind |
| `DFO` | Distillate fuel oil (diesel) |
| `LFG` | Landfill gas |
| `MWH` | Battery / energy storage |
| `WDS` | Wood / wood waste solids |
| `SUB` | Subbituminous coal |
| `OBG` | Other biomass gas |
| `GEO` | Geothermal |

## processed/

County-level summary files produced by the analysis scripts. These are generated automatically — do not edit them manually.

| File | Produced by | Description |
|------|-------------|-------------|
| `counties_summary.csv` | `05_comparison.R` | One row per county with plant counts, nearby counts, and mean PM2.5 |
