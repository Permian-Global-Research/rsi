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
#' @examplesIf interactive()
#' aoi <- sf::st_point(c(-74.912131, 44.080410))
#' aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
#' aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)
#'
#' landsat_image <- get_landsat_imagery(
#'   aoi,
#'   start_date = "2022-06-01",
#'   end_date = "2022-08-30",
#'   download_function = rsi_download_rasters
#' )
#'
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
                                   GDAL_NUM_THREADS = "ALL_CPUS",
                                   GDAL_HTTP_USERAGENT = "rsi (https://permian-global-research.github.io/rsi/)"
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

  # Which loop gets parallelized is determined based on which has more steps,
  # working from the assumption that all downloads take about as long
  #
  # so if we aren't merging, or if there's more assets than tiles, we'll
  # parallelize the outside loop that walks over assets (which, unless the user 
  # has set up wild nested futures, turns the inside one into a serial process)
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
              browser()
              rlang::warn(
                glue::glue(
                  "Failed to download {items$features[[which_item]]$id %||% 'UNKNOWN'} from {items$features[[which_item]]$properties$datetime %||% 'UNKNOWN'}" # nolint
                )
              )
              download_locations[which_item, ] <<- NA
            }
          )
        },
        which_item = feature_iter,
        dl_location = download_locations[[asset]],
        future.seed = TRUE
      )
    }
  )
  out <- stats::na.omit(download_locations)
  na_attr <- stats::na.action(out)
  out <- as.data.frame(as.list(out))
  attr(out, "na.action") <- na_attr
  out
}

maybe_sign_items <- function(items, sign_function) {
  if (!is.null(sign_function)) {
    items <- sign_function(items)
  }
  items
}

set_gdalwarp_extent <- function(gdalwarp_options, aoi_bbox, item_bbox = NULL) {
  if (!("-te" %in% gdalwarp_options)) {
    if (!is.null(item_bbox)) {
      class(item_bbox) <- "bbox"
      item_bbox <- sf::st_as_sfc(item_bbox)
      item_bbox <- sf::st_set_crs(item_bbox, 4326)
      item_bbox <- sf::st_transform(item_bbox, sf::st_crs(aoi_bbox))
      item_bbox <- sf::st_bbox(item_bbox)

      aoi_bbox <- c(
        xmin = max(aoi_bbox[[1]], item_bbox[[1]]),
        ymin = max(aoi_bbox[[2]], item_bbox[[2]]),
        xmax = min(aoi_bbox[[3]], item_bbox[[3]]),
        ymax = min(aoi_bbox[[4]], item_bbox[[4]])
      )

      aoi_bbox <- c(
        xmin = min(aoi_bbox[["xmin"]], aoi_bbox[["xmax"]]),
        ymin = min(aoi_bbox[["ymin"]], aoi_bbox[["ymax"]]),
        xmax = max(aoi_bbox[["xmin"]], aoi_bbox[["xmax"]]),
        ymax = max(aoi_bbox[["ymin"]], aoi_bbox[["ymax"]])
      )
    }

    gdalwarp_options <- c(gdalwarp_options, "-te", aoi_bbox)
  }
  gdalwarp_options
}
