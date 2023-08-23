#' Create and save a multi-band VRT by combining input rasters
#'
#' This function creates a VRT that "stacks" all the bands of its input rasters,
#' as though they were loaded one after another into a GIS. The VRT is fast
#' to create and does not require much space, but does require the input rasters
#' not be moved or altered. Run
#' `sf::gdal_utils("warp", raster_path, some_path.tif)` to turn the output VRT
#' into a standalone TIF file.
#'
#' @param rasters A list of rasters to combine into a single multi-band raster,
#' either as SpatRaster objects from [terra::rast()] or character file paths
#' to files that can be read by [terra::rast()]. Rasters will be "stacked" upon
#' one another, preserving values. They must share CRS.
#' @param raster_path The location to save the final "stacked" raster. Must be
#' a VRT file.
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
#'
#' @returns `raster_path`, unchanged.
#'
#' @examples
#' stack_rasters(
#'   list(
#'     system.file("rasters/ta.tif", package = "lignin"),
#'     system.file("rasters/ta.tif", package = "lignin")
#'   ),
#'   tempfile(fileext = ".vrt")
#' )
#'
#' @export
stack_rasters <- function(rasters,
                          raster_path,
                          ...,
                          resolution,
                          extent,
                          reference_raster = 1,
                          resampling_method = "bilinear",
                          band_names) {
  rlang::check_dots_empty()

  out_dir <- dirname(raster_path)

  if (!(reference_raster %in% seq_along(rasters) ||
        reference_raster %in% names(rasters))) {
    if (is.numeric(reference_raster)) {
      msg <- glue::glue("`rasters` is of length {length(rasters)}, but `reference_raster` is {reference_raster}.")
    } else {
      msg <- glue::glue("`reference_raster` is '{reference_raster}', but none of the elements in `rasters` are named '{reference_raster}'.")
    }
    rlang::abort(c(
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
      rlang::abort(c(
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
      rlang::abort(c(
        "`resolution` must be 2 numbers (in xres yres order).",
        i = glue::glue("{length(resolution)} values were provided.")
      ),
      class = "rsi_bad_resolution"
      )
    }
  }

  ref_crs <- terra::crs(ref_rast)

  if (missing(band_names) || is.function(band_names)) {
    var_names <- unlist(
      lapply(
        rasters,
        function(r) {
          r <- terra::rast(r)
          # this is the only place we instantiate these rasters, so may as well
          # check CRS alignment while we're here...
          if (terra::crs(r) != ref_crs) {
            rlang::abort(c(
              "Rasters do not all share the reference raster's CRS.",
              i = "Reproject rasters to all share the same CRS."
            ),
            class = "rsi_multiple_crs"
            )
          }
          names(r)
        }
      )
    )
  }
  if (!missing(band_names) && is.function(band_names)) {
    var_names <- band_names(var_names)
  }
  if (is.character(band_names)) {
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
  vrt_bands <- lapply(
    intermediate_vrt,
    function(vrt) {
      vrt <- readLines(vrt)
      band_def <- grep("VRTRasterBand", vrt)
      vrt <- vrt[seq(band_def[[1]], band_def[[2]])]
      vrt[1] <- gsub("band=\"1\"", paste0("band=\"", band_no, "\""), vrt[1])
      vrt <- c(
        vrt[1],
        paste0("    <Description>", var_names[[band_no]], "</Description>"),
        vrt[2:length(vrt)]
      )

      band_no <<- band_no + 1

      vrt
    }
  )

  band_def <- grep("VRTRasterBand", vrt_container)
  writeLines(
    c(
      vrt_container[1:(band_def[[1]] - 1)],
      unlist(vrt_bands),
      vrt_container[(band_def[[2]] + 1):length(vrt_container)]
    ),
    raster_path
  )
  raster_path
}
