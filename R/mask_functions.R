#' Create a Sentinel-2 mask raster from the SCL band
#'
#' @param raster The SCL band of a Sentinel-2 image
#'
#' @returns A boolean raster to be used to mask a Sentinel-2 image
#'
#' @examplesIf interactive()
#' aoi <- sf::st_point(c(-74.912131, 44.080410))
#' aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
#' aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)
#'
#' sentinel2_image <- get_sentinel2_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-08-30",
#'   mask_function = sentinel2_mask_function
#' )
#'
#' @export
sentinel2_mask_function <- function(raster) {
  terra::`%in%`(
    raster,
    c(
      4, # VEGETATION
      5, # NOT_VEGETATED
      6, # WATER
      7, # UNCLASSIFIED
      11 # SNOW
    )
  )
  # That means we drop:
  # c(
  # 0, # NO_DATA
  # 1, # SATURATED_OR_DEFECTIVE
  # 2, # DARK_AREA_PIXELS
  # 3, # CLOUD_SHADOWS
  # 8, # CLOUD_MEDIUM_PROBABILITY
  # 9, # CLOUD_HIGH_PROBABILITY
  # 10 # THIN_CIRRUS
  # )
}

#' Create a Landsat mask raster from the QA band
#'
#' @param raster The QA band of a Landsat image
#' @param include Include pixels that represent land, water, or both? Passing
#' `c("land", "water")` is identical to passing `"both"`.
#' @inheritParams rlang::args_dots_empty
#' @param masked_bits Optionally, a list of integer vectors representing the
#' individual bits to mask out. Each vector is converted to an integer
#' representation, and then pixels with matching `qa_pixel` values
#' are preserved by the mask. Refer to the Landsat science product guide for
#' further information on what bit values represent for your platform of
#' interest.
#'
#' @returns A boolean raster to be used to mask a Landsat image
#'
#' @examplesIf interactive()
#' aoi <- sf::st_point(c(-74.912131, 44.080410))
#' aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
#' aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)
#'
#' landsat_image <- get_landsat_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-08-30",
#'   mask_function = landsat_mask_function,
#'   output_file = tempfile(fileext = ".tif")
#' )
#'
#' # Or, optionally pass the qa_pixel bits to mask out directly
#' landsat_image <- get_landsat_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-08-30",
#'   mask_function = \(x) landsat_mask_function(
#'     x,
#'     masked_bits = list(c(0:5, 7, 9, 11, 13, 15))
#'   ),
#'   output_file = tempfile(fileext = ".tif")
#' )
#'
#' # You can use this to specify multiple acceptable values
#' # from the qa_pixel bitmask; names are optional
#' landsat_image <- get_landsat_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-08-30",
#'   mask_function = \(x) landsat_mask_function(
#'     x,
#'     masked_bits = list(
#'       clear_land = c(0:5, 7, 9, 11, 13, 15),
#'       clear_water = c(0:5, 9, 11, 13, 15)
#'     )
#'   ),
#'   output_file = tempfile(fileext = ".tif")
#' )
#'
#' @export
landsat_mask_function <- function(raster,
                                  include = c("land", "water", "both"),
                                  ...,
                                  masked_bits) {
  rlang::check_dots_empty()
  if (missing(masked_bits)) {
    if (missing(include)) include <- include[[1]]
    include <- rlang::arg_match(include, multiple = TRUE)

    masked_bits <- list()
    if (any(c("land", "both") %in% include)) {
      masked_bits <- c(masked_bits, list(c(0:5, 7, 9, 11, 13, 15)))
    }
    if (any(c("water", "both") %in% include)) {
      masked_bits <- c(masked_bits, list(c(0:5, 9, 11, 13, 15)))
    }

  } else if (!missing(include)) {
    rlang::abort(
      "Only one of `include` and `masked_bits` can be specified.",
      class = "rsi_masked_bits_and_include"
    )
  }

  classes <- vapply(masked_bits, bits_to_int, integer(1), USE.NAMES = FALSE)

  terra::`%in%`(raster, classes)
}

bits_to_int <- function(vals) {
  bits <- integer(16)
  bits[setdiff(0:15, vals) + 1] <- 1
  strtoi(paste0(rev(bits), collapse = ""), 2)
}

#' Create an ALOS PALSAR mask raster from the mask band
#'
#' @param raster The mask band of an ALOS PALSAR image
#' @param include Include pixels that represent land, water, or both? Passing
#' `c("land", "water")` is identical to passing `"both"`.
#'
#' @returns A boolean raster to be used to mask an ALOS PALSAR image
#'
#' @examplesIf interactive()
#' aoi <- sf::st_point(c(-74.912131, 44.080410))
#' aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
#' aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)
#'
#' palsar_image <- get_alos_palsar_imagery(
#'   aoi,
#'   start_date = "2021-01-01",
#'   end_date = "2021-12-31",
#'   mask_function = alos_palsar_mask_function,
#'   output_file = tempfile(fileext = ".tif"),
#'   gdalwarp_options = c(
#'     rsi::rsi_gdalwarp_options(),
#'     "-srcnodata", "nan"
#'   )
#' )
#'
#' @export
alos_palsar_mask_function <- function(
    raster,
    include = c("land", "water", "both")) {
  if (missing(include)) include <- include[[1]]
  include <- rlang::arg_match(include, multiple = TRUE)
  # includes no data (0), layover (100) and shadow (150)
  # https://docs.digitalearthafrica.org/en/latest/sandbox/notebooks/Datasets/ALOS_PALSAR_Annual_Mosaic.html
  classes <- c(0, 100, 150)

  if (any(c("land", "both") %in% include)) classes <- c(classes, 255)
  if (any(c("water", "both") %in% include)) classes <- c(classes, 50)

  terra::`%in%`(raster, classes)
}
