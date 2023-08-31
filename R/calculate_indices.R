#' Calculate indices from the bands of a raster
#'
#' This function computes any number of indices from an input raster via
#' [terra::predict()]. By default, this function is designed to work with
#' subsets of [spectral_indices()], but it will work with any data frame with a
#' `formula`, `bands`, and `short_name` column.
#'
#' Note that this function is running code from the `formula` column of the
#' spectral indices data frame, which is derived from a JSON file downloaded off
#' the internet. It's not impossible that an attacker could take advantage of
#' this to run arbitrary code on your computer. Make sure you inspect the
#' `formula` column to make sure there's nothing nasty hiding in any of the
#' formulas you're going to run, and consider using pre-saved indices tables or
#' `spectral_indices(download_indices = FALSE)` if using this in an unsupervised
#' workload.
#'
#' @param raster The raster (either as a SpatRaster or object readable by
#' [terra::rast()]) to compute indices from.
#' @param indices A data frame of indices to compute. The intent is for this
#' function to work with subsets of [spectral_indices], but any data frame with
#' columns `formula` (containing a string representation of the equation used
#' to calculate the index), `bands` (a list column containing character vectors
#' of the necessary bands) and `short_name` (which will be used as the band
#' name) will work.
#' @param output_filename The filename to write the computed metrics to.
#' @param ... Additional arguments passed to [terra::predict()].
#' @param names_suffix If not `NULL`, will be used (with [paste()]) to add a
#' suffix to each of the band names returned.
#'
#' @return `output_filename`, unchanged.
#'
#' @examples
#' calculate_indices(
#'   system.file("rasters/example_sentinel1.tif", package = "rsi"),
#'   filter_platforms(platforms = "Sentinel-1 (Dual Polarisation VV-VH)"),
#'   tempfile(fileext = ".tif"),
#'   names_suffix = "sentinel1"
#' )
#'
#' @export
calculate_indices <- function(raster,
                              indices,
                              output_filename,
                              ...,
                              names_suffix = NULL) {
  rlang::check_dots_empty()
  rlang::check_installed("terra")
  if (!all(c("formula", "short_name") %in% names(indices))) {
    rlang::abort(
      "Both `formula` and `short_name` must be columns in `indices`.",
      class = "rsi_missing_column"
    )
  }
  if (!inherits(raster, "SpatRaster")) raster <- terra::rast(raster)

  check_indices(names(raster), indices)

  terra::predict(
    raster,
    indices,
    fun = function(model, newdata) {
      out <- lapply(
        indices[["formula"]],
        \(calc) {
          with(newdata, eval(str2lang(calc)))
        }
      )
      names(out) <- indices[["short_name"]]
      if (!is.null(names_suffix) && names_suffix != "") {
        names(out) <- paste(names(out), names_suffix, sep = "_")
      }
      return(out)
    },
    filename = output_filename,
    ...
  )
  output_filename
}

check_indices <- function(remap_band_names, indices, call = rlang::caller_env()) {
  good <- TRUE
  if (!is.null(remap_band_names)) {
    good <- vapply(
      indices$bands,
      \(bands) all(bands %in% unlist(remap_band_names)),
      logical(1)
    )
  }

  if (!any(good)) {
    rlang::abort(
      "Some indices cannot be calculated using the available image bands.",
      call = call,
      class = "rsi_missing_indices"
    )
  }
}
