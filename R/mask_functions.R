#' Create a Sentinel-2 mask raster from the SCL band
#'
#' @param raster The SCL band of a Sentinel-2 image
#'
#' @returns A boolean raster to be used to mask a Sentinel-2 image
#'
#' @export
sentinel2_mask_function <- function(raster) {
  terra::`%in%`(raster,
                c(
                  2, # DARK_AREA_PIXELS
                  4, # VEGETATION
                  5, # NOT_VEGETATED
                  6, # WATER
                  7, # UNCLASSIFIED
                  11 # SNOW
                ))
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
#'
#' @returns A boolean raster to be used to mask a Landsat image
#'
#' @export
landsat_mask_function <- function(raster) {
  # "Clear with lows set"
  # https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/media/files/LSDS-1619_Landsat-8-9-C2-L2-ScienceProductGuide-v4.pdf
  raster == 21824
}
