# Regression checks on the generated data for the Community Connection: Ice Breakup in Three Alaskan Rivers indicator.
#
#   Rscript tests/test-data.R
#
# The checks below are shape-independent: they hold whatever the reshape in
# R/build_data.R turns each figure into. Value snapshots, which pin the actual
# numbers so a data update fails loudly instead of passing silently, are the
# TODO at the bottom.

setwd(here::here())
source("R/utils/write_stable.R")

# Keeps the dictionary check readable when a meta.yml field is absent altogether.
`%||%` <- function(a, b) if (is.null(a)) b else a

failures <- character()
check <- function(label, ok) {
  ok <- isTRUE(ok)
  cat(sprintf("  [%s] %s\n", if (ok) "PASS" else "FAIL", label))
  if (!ok) failures <<- c(failures, label)
  invisible(ok)
}

rd <- function(f) {
  readr::read_csv(file.path("data", f),
                  col_types = readr::cols(.default = readr::col_character()),
                  na = character(), progress = FALSE)
}

meta <- yaml::read_yaml("data/meta.yml")

cat("\nData dictionary\n")
check("meta.yml documents 1 dataset(s)", length(meta$datasets) == 1L)
check("meta.yml has no timestamp",
      !any(grepl("\\d{4}-\\d{2}-\\d{2}T|Sys\\.time|generated_at",
                 readLines("data/meta.yml", warn = FALSE))))

for (ds in meta$datasets) {
  df   <- rd(ds$file)
  cols <- vapply(ds$columns, function(x) x$name, character(1))
  check(sprintf("%s: meta.yml lists the columns the file actually has", ds$file),
        identical(cols, names(df)))
  check(sprintf("%s: meta.yml row count matches the file", ds$file),
        identical(as.integer(ds$rows), nrow(df)))
  check(sprintf("%s: every column has a type and a description", ds$file),
        all(vapply(ds$columns, function(x) nzchar(x$type %||% "") && nzchar(x$description %||% ""), logical(1))))
  check(sprintf("%s: source file is still present and unchanged", ds$file),
        identical(file_sha256(file.path("data-raw", ds$source_file)), ds$source_sha256))
  check(sprintf("%s: no blank rows", ds$file), nrow(df) > 0L)
}

cat("\nFile hygiene\n")
for (f in list.files("data", pattern = "[.](csv|yml)$", full.names = TRUE)) {
  check(sprintf("%s is UTF-8, LF, no BOM, no mojibake", basename(f)),
        tryCatch({ assert_clean_output(f); TRUE },
                 error = function(e) { cat("      ", conditionMessage(e), "\n"); FALSE }))
}

cat("\nValue snapshots\n")
# Pinned from data-raw/river-ice_fig-1_0.csv (web update December 2024). A data
# update fails here and says exactly what changed. Values compare as strings so
# EPA's published digits must survive byte for byte.
f1 <- rd("alaskan_rivers_ice_breakup.csv")
check("fig1: 338 rows (129 + 108 + 101 non-blank cells)", nrow(f1) == 338L)
check("fig1: first row is 1896 Yukon River 134",
      identical(unlist(f1[1, ], use.names = FALSE), c("1896", "Yukon River", "134")))
check("fig1: last row is 2024 Kuskokwim River 128.8",
      identical(unlist(f1[nrow(f1), ], use.names = FALSE), c("2024", "Kuskokwim River", "128.8")))

snap <- list(
  # river              rows first  last   min            max
  list("Yukon River",     129L, "1896", "2024", "122",         "134"),
  list("Tanana River",    108L, "1917", "2024", "116.5555556", "128.7777778"),
  list("Kuskokwim River", 101L, "1924", "2024", "120.2222222", "139.875")
)
for (s in snap) {
  r <- f1[f1$river == s[[1]], ]
  v <- as.numeric(r$value)
  check(sprintf("fig1 %s: %d rows, %s-%s", s[[1]], s[[2]], s[[3]], s[[4]]),
        nrow(r) == s[[2]] && identical(r$year[1], s[[3]]) && identical(r$year[nrow(r)], s[[4]]))
  check(sprintf("fig1 %s: min %s, max %s", s[[1]], s[[5]], s[[6]]),
        identical(r$value[which.min(v)], s[[5]]) && identical(r$value[which.max(v)], s[[6]]))
}

cat("\n")
if (length(failures)) {
  cat(sprintf("%d FAILED:\n", length(failures)))
  for (f in failures) cat("  -", f, "\n")
  quit(status = 1L)
}
cat("All data checks passed.\n")
