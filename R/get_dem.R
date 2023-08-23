#' Download DEMs from Planetary Computer (or potentially another STAC source)
#'
#' This function downloads DEMs directly from a STAC endpoint, by default
#' Microsoft's Planetary Computer. It would likely work with other endpoints,
#' so long as `stac_source`, `collections`, `asset_names`, and
#' `download_function` are provided, but currently all default and input
#' checking are specific to Planetary Computer.
#'
#' @param buffer An optional buffer (in the same units as `aoi`) to apply to the
#' AOI before downloading data.
#' @param output_filename The filename to write the output raster to.
#' @param asset_names The names of the assets to download.
#' @inheritParams get_landsat_imagery
#' @inheritParams terra::writeRaster
#' @param ... Arguments passed to [terra::writeRaster()].
#' @param gdalbuildvrt_options,gdalwarp_options Options passed to `gdalbuildvrt`
#' and `gdalwarp`, respectively, through the `options` argument of
#' [sf::gdal_utils()].
#'
#' @examples
#' \dontrun{
#' aoi <- sf::st_point(c(-74.912131, 44.080410)) |>
#'   sf::st_sfc() |>
#'   sf::st_set_crs(4326) |>
#'   sf::st_transform(3857) |>
#'   sf::st_buffer(100)
#'
#' get_dem(aoi)
#' }
#'
#' @returns `output_filename`, unchanged.
#'
#' @export
get_dem <- function(aoi,
                    ...,
                    pixel_x_size = 30,
                    pixel_y_size = 30,
                    buffer = 90,
                    output_filename = paste0(targets::tar_random_name(), ".tif"),
                    start_date = NULL,
                    end_date = NULL,
                    stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1",
                    collections = c("cop-dem-glo-30", "cop-dem-glo-90", "alos-dem", "nasadem"),
                    asset_names = "data",
                    download_function = download_planetary_computer,
                    limit = 999,
                    gdalbuildvrt_options = c(
                      "-r", "bilinear",
                      "-overwrite"
                    ),
                    gdalwarp_options = c(
                      "-r", "bilinear",
                      "-multi",
                      "-overwrite",
                      "-co", "COMPRESS=DEFLATE",
                      "-co", "PREDICTOR=3",
                      "-co", "NUM_THREADS=ALL_CPUS"
                    )) {
  if (stac_source == "https://planetarycomputer.microsoft.com/api/stac/v1") {
    collections <- rlang::arg_match(collections)
  }

  if (collections %in% c("alos-dem", "nasadem") && "PREDICTOR=3" %in% gdalwarp_options) {
    rlang::warn(c(
      "Cannot use PREDICTOR=3 when retrieving ALOS DEM or NASADEM products.",
      i = "Removing the predictor and the argument preceding it from `gdalwarp_options`.",
      i = "Manually provide `gdalwarp_options` to silence this warning."
    ))
    pred_option <- which(gdalwarp_options == "PREDICTOR=3")
    gdalwarp_options <- gdalwarp_options[-((pred_option - 1):pred_option)]
  }

  if (collections == "nasadem" && asset_names == "data") {
    asset_names <- "elevation"
  }

  if (!is.null(buffer) && buffer > 0) {
    aoi <- aoi |>
      sf::st_bbox() |>
      sf::st_as_sfc() |>
      sf::st_buffer(buffer)
  }

  gdalwarp_options <- process_gdalwarp_options(
    gdalwarp_options = gdalwarp_options,
    aoi = aoi,
    pixel_x_size = pixel_x_size,
    pixel_y_size = pixel_y_size
  )

  items <- get_items(
    sf::st_transform(aoi, 4326) |> sf::st_bbox(),
    stac_source,
    collections,
    start_date,
    end_date,
    limit,
    download_function
  )

  items_url <- paste0("/vsicurl/", rstac::assets_url(items, asset_names))
  temp_vrt <- tempfile(fileext = ".vrt")

  sf::gdal_utils(
    "buildvrt",
    items_url,
    temp_vrt,
    options = gdalbuildvrt_options
  )
  on.exit(file.remove(temp_vrt), add = TRUE)

  vrt <- readLines(temp_vrt)
  band_def <- grep("VRTRasterBand", vrt)

  vrt <- c(
    vrt[1:band_def[[1]]],
    paste0("    <Description>", "elevation", "</Description>"),
    vrt[(band_def[[1]] + 1):length(vrt)]
  )
  writeLines(vrt, temp_vrt)

  sf::gdal_utils(
    "warp",
    temp_vrt,
    output_filename,
    options = gdalwarp_options
  )

  output_filename
}
