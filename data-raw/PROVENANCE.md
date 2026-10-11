# Provenance

Every file in this directory is reproduced unmodified from EPA's published
indicator page and its per-figure data downloads. To update the data, replace the
file and rerun `Rscript R/build_data.R`.

## Indicator page

- `source-page.html`  \
  <https://19january2025snapshot.epa.gov/climate-indicators/alaskan-rivers/index.html>  \
  sha256 `5ad89e972b5ed1217c463b1002b3c3042570d695aa71503a58d07b333cfb104e`

Technical documentation: <https://19january2025snapshot.epa.gov/system/files/documents/2024-12/river-ice_td.pdf>

## Figure data

- `river-ice_fig-1_0.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2024-12/river-ice_fig-1_0.csv>  \
  sha256 `cdd7fa3732bac5b2f6e1d5939765150ac9ee495eb6166d92d6e98297f55eef7b`  \
  encoding UTF-8, 129 data rows, columns: `Year`, `Yukon River`, `Tanana River`, `Kuskokwim River`  \
  title: Figure 1. Ice Breakup Dates for Three Alaskan Rivers, 1896-2024  \
  data source: National Snow and Ice Data Center, 2024; Yukon River Breakup, 2024; Kuskokwim Ice Classic, 2024; National Weather Service, 2024.; web update: December 2024; units: Days from January 1

## Chart configuration files

EPA's page draws these figures from a separate chart file and takes the figure
title and the data-source line in `narrative.qmd` from it. The data itself comes
from the download above, not from these files.

- Figure 1: `river-ice_fig-1.csv`  \
  <https://19january2025snapshot.epa.gov/system/files/other-files/2022-07/river-ice_fig-1.csv>  \
  sha256 `815f2f403a7d1d396b592b5f402dc8e613962aa05a59e32c9c20d152513ca103`
