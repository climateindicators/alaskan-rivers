# Build tidy long-format data for the Community Connection: Ice Breakup in Three Alaskan Rivers indicator.
#
#   Rscript R/build_data.R
#
# Reads EPA's published figure CSVs in data-raw/ and writes data/*.csv plus
# data/meta.yml. Rerunning with unchanged inputs produces byte-identical output.
# Nothing here touches the network.
#
# Generated as a stub by the build-indicator skill. Each figure below has a
# `todo_reshape()` call standing where its reshape belongs. Replace that line,
# then delete the todo_reshape() helper once no call to it remains.
#
# TO UPDATE THE DATA: drop replacement CSVs into data-raw/ and rerun. Headers
# are asserted, not assumed, so a renamed or reordered column stops the build.

suppressPackageStartupMessages({
  library(dplyr)
})

root <- here::here()
source(file.path(root, "R/utils/epa_csv.R"))
source(file.path(root, "R/utils/write_stable.R"))

raw_dir <- file.path(root, "data-raw")
out_dir <- file.path(root, "data")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# ---- Indicator constants -----------------------------------------------------

INDICATOR <- list(
  name                    = "Community Connection: Ice Breakup in Three Alaskan Rivers",
  slug                    = "alaskan-rivers",
  publisher               = "U.S. Environmental Protection Agency",
  source_page             = "https://19january2025snapshot.epa.gov/climate-indicators/alaskan-rivers/index.html",
  technical_documentation = "https://19january2025snapshot.epa.gov/system/files/documents/2024-12/river-ice_td.pdf",
  rights                  = "Public domain, work of the U.S. Government (17 U.S.C. 105)"
)

# ---- Figure 1: Ice Breakup Dates for Three Alaskan Rivers, 1896-2024 ----

f1_path <- file.path(raw_dir, "river-ice_fig-1_0.csv")
f1_meta <- read_epa_preamble(f1_path)
f1_raw  <- read_epa_csv(f1_path)

F1_RIVERS <- c("Yukon River", "Tanana River", "Kuskokwim River")

assert_headers(
  f1_raw,
  id_cols          = "Year",
  expected_headers = F1_RIVERS,
  what             = "river-ice_fig-1_0.csv"
)

# One row per year and river, in source order. EPA publishes the nine-year
# moving average already applied. The Tanana and Kuskokwim records start later
# than the Yukon's, so their early cells are blank and are dropped rather than
# carried as missing rows. Values stay character so EPA's digits survive.
f1 <- f1_raw |>
  tidyr::pivot_longer(all_of(F1_RIVERS), names_to = "river", values_to = "value") |>
  filter(!is.na(value), trimws(value) != "") |>
  transmute(year = Year, river, value)
assert_conservation(f1_raw, F1_RIVERS, nrow(f1), "river-ice_fig-1_0.csv")

write_csv_stable(f1, file.path(out_dir, "alaskan_rivers_ice_breakup.csv"))

# ---- Data dictionary ---------------------------------------------------------

col <- function(name, type, description) {
  list(name = name, type = type, description = description)
}

# One entry per output column, in order, filled from the data frame itself so it
# cannot drift. A column missing from `docs` leaves a blank type and description,
# which tests/test-data.R fails on.
describe <- function(df) {
  docs <- list(
    year  = c("integer", "Calendar year of the ice breakup."),
    river = c("string", "River and location: Yukon River (Dawson City), Tanana River (Nenana), or Kuskokwim River (Bethel)."),
    value = c("number", "Ice breakup date as days from January 1, nine-year moving average.")
  )
  lapply(names(df), function(nm) col(nm, docs[[nm]][1] %||% "", docs[[nm]][2] %||% ""))
}

meta <- list(
  indicator = INDICATOR,
  datasets = list(
    list(
      file            = "alaskan_rivers_ice_breakup.csv",
      figure          = "Figure 1",
      figure_title    = f1_meta$title,
      source_file     = "river-ice_fig-1_0.csv",
      source_sha256   = file_sha256(f1_path),
      source_encoding = "UTF-8",
      data_source     = f1_meta$data_source,
      web_update      = f1_meta$web_update,
      unit            = f1_meta$units,
      rows            = nrow(f1),
      columns         = describe(f1)
    )
  )
)

write_yaml_stable(meta, file.path(out_dir, "meta.yml"))

# ---- Verify what was written -------------------------------------------------

written <- list.files(out_dir, pattern = "[.](csv|yml)$", full.names = TRUE)
invisible(lapply(written, assert_clean_output))

cat("\nWrote:\n")
for (p in written) {
  cat(sprintf("  %-34s %8d bytes  %s\n", basename(p), file.size(p), substr(file_sha256(p), 1, 12)))
}
