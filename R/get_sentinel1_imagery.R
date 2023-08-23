#' Retrieve composites of Sentinel-1 images from STAC endpoints
#'
#' This function retrieves composites of Sentinel-1 images from STAC endpoints.
#' The interface is similar to, but not identical to, [get_dem()] and
#' [get_landsat_imagery()]. Importantly, where [get_dem()] does not average
#' images at all and [get_landsat_imagery()] provides the `reduce_time` boolean
#' to control if raw images or composites should be returned, this function
#' _always_ produces composites of all the images within the spatiotemporal area
#' of interest.
#'
#' Both the GRD and RTC collections are supported. To download RTC data, set
#' `collections` to `sentinel-1-rtc`, and supply your subscription key as an
#' environment variable named `lignin_pc_key` (through, e.g., `Sys.setenv()`
#' or your `.Renviron` file).
#'
#' @inheritParams get_dem
#' @param reduce_function The (quoted) name of a function from
#' `terra` (for instance, [terra::median]) used to combine downloaded images
#' into a single composite.
#'
#' @returns `output_file`, unchanged.
#'
#' @examplesIf interactive()
#' aoi <- sf::st_point(c(-74.912131, 44.080410))
#' aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
#' aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)
#'
#' get_sentinel1_imagery(
#'   aoi,
#'   "2022-06-01",
#'   "2022-08-30"
#' )
#'
#' @export
get_sentinel1_imagery <- function(aoi,
                                  start_date,
                                  end_date,
                                  ...,
                                  pixel_x_size = 10,
                                  pixel_y_size = 10,
                                  buffer = 90,
                                  output_file = paste0(proceduralnames::make_english_names(1), ".tif"),
                                  reduce_function = "median",
                                  asset_names = sentinel1_band_mapping$planetary_computer_v1,
                                  stac_source = attr(asset_names, "stac_source"),
                                  collections = attr(asset_names, "collection_name"),
                                  download_function = attr(asset_names, "download_function"),
                                  limit = 999,
                                  gdalwarp_options = c(
                                    "-r", "bilinear",
                                    "-multi",
                                    "-overwrite",
                                    "-co", "COMPRESS=DEFLATE",
                                    "-co", "PREDICTOR=2",
                                    "-co", "NUM_THREADS=ALL_CPUS"
                                  )) {
  rlang::check_dots_empty()

  if (!is.null(buffer) && buffer > 0) {
    aoi <- sf::st_buffer(
      sf::st_as_sfc(sf::st_bbox(aoi)),
      buffer
    )
  }

  gdalwarp_options <- process_gdalwarp_options(
    gdalwarp_options = gdalwarp_options,
    aoi = aoi,
    pixel_x_size = pixel_x_size,
    pixel_y_size = pixel_y_size
  )

  items <- get_items(
    sf::st_bbox(sf::st_transform(aoi, 4326)),
    stac_source,
    collections,
    start_date,
    end_date,
    limit,
    download_function
  )

  items_urls <- lapply(
    names(asset_names),
    function(asset_name) suppressWarnings(rstac::assets_url(items, asset_name))
  )
  names(items_urls) <- names(asset_names)

  items_urls <- items_urls[!vapply(items_urls, is.null, logical(1))]

  download_dir <- file.path(tempdir(), "sentinel1")
  if (!dir.exists(download_dir)) dir.create(download_dir)

  downloaded_bands <- vapply(
    names(items_urls),
    function(band_name) {
      out_file <- file.path(download_dir, paste0(toupper(band_name), ".tif"))

      urls <- items_urls[[band_name]]
      downloads <- replicate(length(urls), tempfile(fileext = ".tif"))
      download_assets(urls, downloads, gdalwarp_options)
      on.exit(file.remove(downloads), add = TRUE)

      composite_images(downloads, out_file, reduce_function)

      out_file
    },
    character(1)
  )
  on.exit(file.remove(downloaded_bands), add = TRUE)

  out_vrt <- tempfile(fileext = ".vrt")
  invisible(stack_rasters(downloaded_bands, out_vrt, band_names = remap_band_names(names(items_urls), asset_names)))
  on.exit(file.remove(out_vrt), add = TRUE)

  sf::gdal_utils(
    "warp",
    out_vrt,
    output_file,
    options = gdalwarp_options
  )

  output_file
}
