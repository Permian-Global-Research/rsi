rsi_download_rasters <- function(items,
                                  sign_function,
                                  asset_names,
                                  gdalwarp_options,
                                  aoi_bbox,
                                  gdal_config_options,
                                  merge_assets) {
  n_tiles_out <- ifelse(merge_assets, 1L, length(items$features))
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

  if (merge_assets) {
    gdalwarp_options <- set_gdalwarp_extent(gdalwarp_options, aoi_bbox, NULL)
  }

  asset_iterator <- ifelse(
    merge_assets || (n_tiles_out < ncol(download_locations)),
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

      tryCatch({
        future.apply::future_mapply(
          function(which_item, dl_location) {
            p(glue::glue("Downloading {asset}"))
            signed_items <- maybe_sign_items(items, sign_function)
            url <- rstac::assets_url(signed_items, asset)[which_item]

            if (!merge_assets) {
              item_bbox <- items$features[[which_item]]$bbox
              current_options <- set_gdalwarp_extent(gdalwarp_options, aoi_bbox, item_bbox)
            }

            sf::gdal_utils(
              "warp",
              paste0("/vsicurl/", url),
              dl_location,
              options = current_options,
              quiet = TRUE,
              config_options = gdal_config_options
            )
          },
          which_item = feature_iter,
          dl_location = download_locations[[asset]],
          future.seed = TRUE
        )},
        error = function(e) {
          rlang::warn(glue::glue("Failed to download {items$features[[i]]$id %||% 'UNKNOWN'} from {items$features[[i]]$properties$datetime %||% 'UNKNOWN'}"))
          download_locations[i, ] <- NA
        }
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
