#' Calculate indices from the bands of a raster
#'
#' This function computes any number of indices from an input raster via
#' [terra::predict()]. By default, this function is designed to work with
#' subsets of [spectral_indices()], but it will work with any data frame with a
#' `formula`, `bands`, and `short_name` column.
#'
#' @section Security:
#' Note that this function is running code from the `formula` column of the
#' spectral indices data frame, which is derived from a JSON file downloaded off
#' the internet. It's not impossible that an attacker could take advantage of
#' this to run arbitrary code on your computer. To mitigate this, indices are
#' calculated in a minimal environment that contains very few functions or
#' symbols (preventing an attacker from accessing, for example, `system()`).
#'
#' Still, it's good practice to inspect your `formula` column to make sure
#' there's nothing nasty hiding in any of the formulas you're going to run.
#' Additionally, consider using pre-saved indices tables or
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
#' @inheritParams rlang::args_dots_empty
#' @inheritParams terra::predict
#' @param extra_objects A named list of additional objects to pass to the 
#' minimal environment that formulas are executed in. For instance, if you
#' need to use the `pmax` function in order to calculate an index, you can 
#' make it available in the environment by setting 
#' `extra_objects = list("pmax" = pmax)`. Providing extra functionality is 
#' inherently less safe than the default minimal environment, and as such always 
#' emits a warning, which you can suppress with `suppressWarnings()`.
#' @param names_suffix If not `NULL`, will be used (with [paste()]) to add a
#' suffix to each of the band names returned.
#'
#' @return `output_filename`, unchanged.
#'
#' @examples
#' our_raster <- system.file("rasters/example_sentinel1.tif", package = "rsi")
#' calculate_indices(
#'   our_raster,
#'   filter_bands(bands = names(terra::rast(our_raster))),
#'   tempfile(fileext = ".tif"),
#'   names_suffix = "sentinel1"
#' )
#'
#' # Formulas aren't able to access most R functions or operators,
#' # in order to try and keep formulas from doing something bad:
#' example_indices <- filter_platforms(platforms = "Sentinel-1 (Dual Polarisation VV-VH)")[1, ]
#' example_indices$formula <- 'system("echo something bad")'
#' # So this will error:
#' try(
#'   calculate_indices(
#'     system.file("rasters/example_sentinel1.tif", package = "rsi"),
#'     example_indices,
#'     tempfile(fileext = ".tif")
#'   )
#' )
#' 
#' # Because of this, formulas which try to use most R functions
#' # will wind up erroring as well:
#' example_indices$formula <- "pmax(VH, VV)"
#' try(
#'   calculate_indices(
#'     system.file("rasters/example_sentinel1.tif", package = "rsi"),
#'     example_indices,
#'     tempfile(fileext = ".tif")
#'   )
#' )
#' 
#' # To fix this, pass the objects you want to use to `extra_objects`
#' calculate_indices(
#'   system.file("rasters/example_sentinel1.tif", package = "rsi"),
#'   example_indices,
#'   tempfile(fileext = ".tif"),
#'   extra_objects = list(pmax = pmax)
#' ) |>
#'   suppressWarnings(classes = "rsi_extra_objects")
#'
#' @export
calculate_indices <- function(raster,
                              indices,
                              output_filename,
                              ...,
                              cores = 1L,
                              wopt = list(),
                              overwrite = FALSE,
                              extra_objects = list(),
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

  formulas <- lapply(indices[["formula"]], str2lang)
  paste_names <- !is.null(names_suffix) && names_suffix != ""

  exec_objects <- list(
    # math functions
    `-` = `-`,
    `(` = `(`,
    `*` = `*`,
    `/` = `/`,
    `^` = `^`,
    `+` = `+`,
    # necessary syntax
    `<-` = `<-`,
    `if` = `if`,
    `{` = `{`,
    `function` = `function`,
    # renaming
    names = names,
    `names<-` = `names<-`,
    paste = paste,
    # pieces for predicting
    predict = terra::predict,
    list = list(),
    lapply = lapply,
    with = with,
    eval = eval,
    # user-provided variables
    formulas = formulas,
    short_names = indices[["short_name"]],
    paste_names = paste_names,
    raster = raster,
    output_filename = output_filename,
    wopt = wopt,
    cores = cores,
    overwrite = overwrite,
    names_suffix = names_suffix
  )

  if (length(extra_objects)) {
    rlang::warn(c(
      "Providing extra objects can potentially make it easier for malicious code to impact your system.",
      i = "Make sure you closely inspect the formulas you're running, before running them, and understand why they need extra objects!",
      i = "This warning can be silenced using `suppressWarnings(..., classes = 'rsi_extra_objects')`"
      ),
      class = "rsi_extra_objects"
    )
    exec_objects <- c(
      exec_objects,
      extra_objects
    )
  }

  exec_env <- rlang::new_environment(exec_objects)

  # covr can't instrument inside of our locked-down environment
  # so either we widen the environment (which seems like the wrong thing to do)
  # or we ignore this chunk wrt coverage
  # nocov start
  local(
    {
      predict(
        raster,
        list,
        fun = function(model, newdata) {
          out <- lapply(
            formulas,
            function(calc) {
              with(newdata, eval(calc))
            }
          )
          names(out) <- short_names
          if (paste_names) {
            names(out) <- paste(names(out), names_suffix, sep = "_")
          }
          out
        },
        filename = output_filename,
        wopt = wopt,
        cores = cores,
        overwrite = overwrite
      )
    },
    envir = exec_env
  )
  # nocov end

  output_filename
}

check_indices <- function(remap_band_names, indices, call = rlang::caller_env()) {
  good <- TRUE
  if (!is.null(remap_band_names)) {
    good <- vapply(
      indices$bands,
      function(bands) all(bands %in% unlist(remap_band_names)),
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
