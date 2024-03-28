#' Download specific assets from a set of STAC items
#'
#' @param items A `StacItemCollection` object, as returned by [rsi_query_api()].
#' @param aoi Either an sf(c) object outlining the area of interest to get
#' imagery for, or a `bbox` image containing the bounding box of your AOI.
#' @param merge Logical: for each asset, should data from multiple items be
#' merged into a single downloaded file? If `TRUE`, this returns a single file
#' for each asset, which has been merged via gdalwarp. No resampling or
#' compositing is performed, but rather each pixel uses the last data
#' downloaded. This is fast, but precludes per-item masking and compositing.
#' If `FALSE`, each asset from each item is saved as a separate file.
#' @inheritParams get_stac_data
#'
#' @returns A data frame  where columns correspond to distinct assets, rows
#' correspond to distinct items, and cells contain file paths to the downloaded
#' data.
#'
#' @export
rsi_download_rasters <- function(items,
                                 aoi,
                                 asset_names,
                                 sign_function = NULL,
                                 merge = FALSE,
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
                                 ),
                                 ...) {
  if (!inherits(aoi, "bbox")) aoi <- sf::st_bbox(aoi)

  check_type_and_length(
    merge = logical(1)
  )

  n_tiles_out <- ifelse(merge, 1L, length(items$features))
  p <- build_progressr(length(names(asset_names)) * n_tiles_out)

  download_locations <- data.frame(
    matrix(
      data = replicate(
        length(asset_names) * n_tiles_out,
        tempfile(fileext = ".tif")
      ),
      ncol = length(asset_names),
      nrow = n_tiles_out
    )
  )
  names(download_locations) <- names(asset_names)

  if (merge) {
    gdalwarp_options <- set_gdalwarp_extent(gdalwarp_options, aoi, NULL)
  }

  asset_iterator <- ifelse(
    merge || (n_tiles_out < ncol(download_locations)),
    function(...) future.apply::future_lapply(..., future.seed = TRUE),
    lapply
  )

  current_options <- gdalwarp_options

  asset_iterator(
    names(download_locations),
    function(asset) {
      feature_iter <- seq_len(length(items$features))
      if (length(download_locations[[asset]]) == 1) {
        feature_iter <- list(feature_iter)
      }

      future.apply::future_mapply(
        function(which_item, dl_location) {
          p(glue::glue("Downloading {asset}"))
          signed_items <- maybe_sign_items(items, sign_function)
          url <- rstac::assets_url(signed_items, asset)[which_item]

          if (!merge) {
            item_bbox <- items$features[[which_item]]$bbox
            current_options <- set_gdalwarp_extent(
              gdalwarp_options,
              aoi,
              item_bbox
            )
          }

          tryCatch(
            {
              sf::gdal_utils(
                "warp",
                paste0("/vsicurl/", url),
                dl_location,
                options = current_options,
                quiet = TRUE,
                config_options = gdal_config_options
              )
            },
            error = function(e) {
              rlang::warn(
                glue::glue(
                  "Failed to download {items$features[[which_item]]$id %||% 'UNKNOWN'} from {items$features[[which_item]]$properties$datetime %||% 'UNKNOWN'}" # nolint
                )
              )
              download_locations[which_item, ] <- NA
            }
          )
        },
        which_item = feature_iter,
        dl_location = download_locations[[asset]],
        future.seed = TRUE
      )
    }
  )
  as.data.frame(as.list(stats::na.omit(download_locations)))
}

maybe_sign_items <- function(items, sign_function) {
  if (!is.null(sign_function)) {
    items <- sign_function(items)
  }
  items
}
