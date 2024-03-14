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
      2, # DARK_AREA_PIXELS
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
#'   mask_function = landsat_mask_function
#' )
#'
#' @export
landsat_mask_function <- function(raster, include = c("land", "water", "both")) {
  if (missing(include)) include <- include[[1]]
  include <- rlang::arg_match(include, multiple = TRUE)
  classes <- numeric()

  # "Clear with lows set"
  # https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/media/files/LSDS-1619_Landsat-8-9-C2-L2-ScienceProductGuide-v4.pdf
  if (any(c("land", "both") %in% include)) classes <- c(classes, 21824)
  # from https://github.com/Permian-Global-Research/rsi/issues/37
  if (any(c("water", "both") %in% include)) classes <- c(classes, 21952)

  terra::`%in%`(raster, classes)
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
#'   mask_function = alos_palsar_mask_function
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
