#' Create and save a multi-band output raster by combining input rasters
#'
#' This function creates an output raster that "stacks" all the bands of its
#' input rasters, as though they were loaded one after another into a GIS. It
#' does this by first constructing a GDAL virtual raster, or "VRT", and then
#' optionally uses GDAL's warper to convert this VRT into a standalone file.
#' The VRT is fast to create and does not require much space, but does require
#' the input rasters not be moved or altered. Creating a standalone raster from
#' this file may take a long time and a large amount of disk space.
#'
#' @param rasters A list of rasters to combine into a single multi-band raster,
#' either as SpatRaster objects from [terra::rast()] or character file paths
#' to files that can be read by [terra::rast()]. Rasters will be "stacked" upon
#' one another, preserving values. They must share CRS.
#' @param output_filename The location to save the final "stacked" raster. If
#' this filename has a "vrt" extension as determined by `tools::file_ext()`,
#' then this function exits after creating a VRT; otherwise, this function will
#' create a VRT and then use `sf::gdal_utils("warp")` to convert the VRT into
#' another format.
#' @inheritParams rlang::args_dots_empty
#' @param resolution Numeric of length 2, representing the target X and Y
#' resolution of the output raster. If only a single value is provided, it will
#' be used for both X and Y resolution; if more than 2 values are provided, an
#' error is thrown.
#' @param extent Numeric of length 4, representing the target xmin, ymin, xmax,
#' and ymax values of the output raster (its bounding box), in that order.
#' @param reference_raster The position (index) of the raster in `rasters` to
#' take extent, resolution, and CRS information from. No reprojection is done.
#' If `resolution` or `extent` are provided, they override the values from the
#' reference raster.
#' @param resampling_method The method to use when resampling to different
#' resolutions.
#' @param band_names Either a character vector of band names, or a function that
#' when given a character vector of band names, returns a character vector of
#' the same length containing new band names.
#' @param gdalwarp_options Options passed to `gdalwarp` through the `options`
#' argument of [sf::gdal_utils()]. This argument is ignored (with a warning)
#' if `output_filename` is a VRT.
#' @param gdal_config_options Options passed to `gdalwarp` through the
#' `config_options` argument of [sf::gdal_utils()].  This argument is ignored
#' (with a warning) if `output_filename` is a VRT.
#'
#' @returns `output_filename`, unchanged.
#'
#' @examples
#' stack_rasters(
#'   list(
#'     system.file("rasters/dpdd.tif", package = "rsi"),
#'     system.file("rasters/example_sentinel1.tif", package = "rsi")
#'   ),
#'   tempfile(fileext = ".vrt")
#' )
#'
#' @export
stack_rasters <- function(rasters,
                          output_filename,
                          ...,
                          resolution,
                          extent,
                          reference_raster = 1,
                          resampling_method = "bilinear",
                          band_names,
                          gdalwarp_options = c(
                            "-r", "bilinear",
                            "-multi",
                            "-overwrite",
                            "-co", "COMPRESS=DEFLATE",
                            "-co", "PREDICTOR=2",
                            "-co", "NUM_THREADS=ALL_CPUS"
                          ),
                          gdal_config_options = c(
                            VSI_CACHE = "TRUE",
                            GDAL_CACHEMAX = "30%",
                            VSI_CACHE_SIZE = "10000000",
                            GDAL_HTTP_MULTIPLEX = "YES",
                            GDAL_INGESTED_BYTES_AT_OPEN = "32000",
                            GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
                            GDAL_HTTP_VERSION = "2",
                            GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
                            GDAL_NUM_THREADS = "ALL_CPUS"
                          )) {
  rlang::check_dots_empty()

  check_type_and_length(
    output_filename = character(1),
    resampling_method = character(1)
  )

  tryCatch(
    check_type_and_length(rasters = list()),
    error = function(e) check_type_and_length(
      rasters = character(),
      call = rlang::caller_env(4)
    )
  )

  out_dir <- dirname(output_filename)

  use_warper <- tolower(tools::file_ext(output_filename)) != "vrt"

  if (!use_warper && (!missing(gdal_config_options) || !missing(gdalwarp_options))) {
    rlang::warn(
      "`gdal_config_options` and `gdalwarp_options` are both ignored when `output_filename` ends in 'vrt'.",
      class = "rsi_gdal_options_ignored"
    )
  }

  if (!(reference_raster %in% seq_along(rasters) ||
    reference_raster %in% names(rasters))) {
    if (is.numeric(reference_raster)) {
      msg <- glue::glue("`rasters` is of length {length(rasters)}, but `reference_raster` is {reference_raster}.")
    } else {
      msg <- glue::glue("`reference_raster` is '{reference_raster}', but none of the elements in `rasters` are named '{reference_raster}'.")
    }
    rlang::abort(
      c(
        "`reference_raster` must be a valid index for `rasters`",
        i = msg
      ),
      class = "rsi_not_in_vec"
    )
  }

  ref_rast <- terra::rast(rasters[[reference_raster]])

  if (missing(extent)) {
    extent <- terra::ext(ref_rast)
    extent <- as.vector(extent)[c("xmin", "ymin", "xmax", "ymax")]
    names(extent) <- NULL
  } else {
    if (length(extent) != 4) {
      rlang::abort(
        c(
          "`extent` must be 4 numbers (in xmin ymin xmax ymax order).",
          i = glue::glue("{length(extent)} values were provided.")
        ),
        class = "rsi_bad_extent"
      )
    }
  }

  if (missing(resolution)) {
    resolution <- terra::res(ref_rast)
  } else {
    if (length(resolution) == 1) resolution <- c(resolution, resolution)
    if (length(resolution) != 2) {
      rlang::abort(
        c(
          "`resolution` must be 2 numbers (in xres yres order).",
          i = glue::glue("{length(resolution)} values were provided.")
        ),
        class = "rsi_bad_resolution"
      )
    }
  }

  ref_crs <- terra::crs(ref_rast)

  var_names <- unlist(
    lapply(
      rasters,
      function(r) {
        r <- terra::rast(r)
        # this is the only place we instantiate these rasters, so may as well
        # check CRS alignment while we're here...
        if (terra::crs(r) != ref_crs) {
          rlang::abort(
            c(
              "Rasters do not all share the reference raster's CRS.",
              i = "Reproject rasters to all share the same CRS."
            ),
            class = "rsi_multiple_crs",
            call = rlang::caller_env()
          )
        }
        names(r)
      }
    )
  )

  if (!missing(band_names) && is.function(band_names)) {
    var_names <- band_names(var_names)
  }
  if (!missing(band_names) && is.character(band_names)) {
    var_names <- band_names
  }

  vrt_container_file <- tempfile(tmpdir = out_dir, fileext = ".vrt")
  sf::gdal_utils(
    "buildvrt",
    rasters[[reference_raster]],
    vrt_container_file,
    options = c(
      "-b", 1,
      "-te", extent,
      "-tr", resolution,
      "-r", resampling_method
    )
  )
  vrt_container <- readLines(vrt_container_file)
  file.remove(vrt_container_file)

  intermediate_vrt <- lapply(
    rasters,
    function(raster) {
      r_lyrs <- terra::nlyr(terra::rast(raster))
      out_files <- replicate(
        r_lyrs,
        tempfile(tmpdir = out_dir, fileext = ".vrt")
      )

      lapply(
        seq_len(r_lyrs),
        function(b) {
          sf::gdal_utils(
            "buildvrt",
            raster,
            out_files[[b]],
            options = c(
              "-b", b,
              "-te", extent,
              "-tr", resolution,
              "-r", resampling_method
            )
          )
        }
      )
      out_files
    }
  )

  intermediate_vrt <- unlist(intermediate_vrt)
  on.exit(file.remove(intermediate_vrt), add = TRUE)

  band_no <- 1
  vrt_bands <- vector("list", length(intermediate_vrt))
  for (vrt in intermediate_vrt) {
    vrt <- readLines(vrt)
    band_def <- grep("VRTRasterBand", vrt)
    vrt <- vrt[seq(band_def[[1]], band_def[[2]])]
    vrt[1] <- gsub("band=\"1\"", paste0("band=\"", band_no, "\""), vrt[1])
    vrt <- c(
      vrt[1],
      paste0("    <Description>", var_names[[band_no]], "</Description>"),
      vrt[2:length(vrt)]
    )

    vrt_bands[[band_no]] <- vrt

    band_no <- band_no + 1
  }

  vrt_destination <- ifelse(
    use_warper,
    tempfile(fileext = ".vrt"),
    output_filename
  )

  band_def <- grep("VRTRasterBand", vrt_container)
  writeLines(
    c(
      vrt_container[1:(band_def[[1]] - 1)],
      unlist(vrt_bands),
      vrt_container[(band_def[[2]] + 1):length(vrt_container)]
    ),
    vrt_destination
  )

  if (use_warper) {
    sf::gdal_utils(
      "warp",
      source = vrt_destination,
      destination = output_filename,
      options = gdalwarp_options,
      config_options = gdal_config_options
    )
  }

  output_filename
}
