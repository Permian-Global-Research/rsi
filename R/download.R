simple_download <- function(items,
                            sign_function,
                            asset_names,
                            gdalwarp_options,
                            aoi_bbox,
                            gdal_config_options,
                            p) {
  gdalwarp_options <- set_gdalwarp_extent(gdalwarp_options, aoi_bbox, NULL)
  out <- future.apply::future_lapply(
    names(asset_names),
    function(asset) {
      p(glue::glue("Downloading {asset}"))
      signed_items <- maybe_sign_items(items, sign_function)
      item_urls <- paste0("/vsicurl/", rstac::assets_url(signed_items, asset))
      out_file <- tempfile(fileext = ".tif")
      sf::gdal_utils(
        "warp",
        source = item_urls,
        destination = out_file,
        options = gdalwarp_options,
        config_options = gdal_config_options
      )
      out_file
    },
    future.seed = TRUE
  )
  list(
    final_bands = list(out),
    out_vrt = tempfile(fileext = ".vrt")
  )
}

complex_download <- function(items,
                             items_urls,
                             download_locations,
                             sign_function,
                             asset_names,
                             mask_band,
                             gdalwarp_options,
                             aoi_bbox,
                             gdal_config_options,
                             p,
                             output_filename) {
  feature_iterator <- ifelse(
    length(items$features) > ncol(download_locations),
    function(...) future.apply::future_lapply(..., future.seed = TRUE),
    lapply
  )
  feature_iterator(
    seq_along(items$features),
    function(i) {
      item <- items$features[[i]]

      item <- maybe_sign_items(item, sign_function)

      item_urls <- extract_urls(asset_names, item)
      if (!is.null(mask_band)) item_urls[[mask_band]] <- rstac::assets_url(item, mask_band)

      item_bbox <- item$bbox
      current_options <- set_gdalwarp_extent(gdalwarp_options, aoi_bbox, item_bbox)

      tryCatch({
        destinations <- unlist(download_locations[i, , drop = FALSE])
        future.apply::future_mapply(
          function(url, destination) {
            p("Downloading assets")
            sf::gdal_utils(
              "warp",
              paste0("/vsicurl/", url),
              destination,
              options = current_options,
              quiet = TRUE,
              config_options = gdal_config_options
            )
          },
          url = unlist(item_urls),
          destination = destinations,
          future.seed = TRUE
        )
        destinations
        },
        error = function(e) {
          rlang::warn(glue::glue("Failed to download {item$id %||% 'UNKNOWN'} from {item$properties$datetime %||% 'UNKNOWN'}"))
          download_locations[i, ] <- NA
        }
      )
    }
  )
  download_locations <- stats::na.omit(download_locations)
  names(download_locations) <- names(items_urls)
  download_locations
}

