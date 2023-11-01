#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL

#' @importFrom rlang %||%
#' @importFrom stats predict

utils::globalVariables(c(
  "dem_band_mapping",
  "landsat_band_mapping",
  "sentinel1_band_mapping",
  "sentinel2_band_mapping",
  "short_names"
))
