simple_download <- function(items,
                            sign_function,
                            asset_names,
                            gdalwarp_options,
                            aoi_bbox,
                            gdal_config_options) {
  p <- build_progressr(length(names(asset_names)))
  gdalwarp_options <- set_gdalwarp_extent(gdalwarp_options, aoi_bbox, NULL)
  out <- future.apply::future_lapply(
    names(asset_names),
    function(asset) {
      p(glue::glue("Downloading {asset}"))
      signed_items <- maybe_sign_items(items, sign_function)
      item_urls <- rstac::assets_url(signed_items, asset)
      out_file <- tempfile(fileext = ".tif")
      sf::gdal_utils(
        "warp",
        source = paste0("/vsicurl/", item_urls),
        destination = out_file,
        options = gdalwarp_options,
        quiet = TRUE,
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
                             sign_function,
                             asset_names,
                             gdalwarp_options,
                             aoi_bbox,
                             gdal_config_options) {
  p <- build_progressr(length(items$features) * length(asset_names))

  download_locations <- data.frame(
    matrix(
      data = replicate(
        length(asset_names) * length(items$features),
        tempfile(fileext = ".tif")
      ),
      ncol = length(asset_names),
      nrow = length(items$features)
    )
  )
  names(download_locations) <- names(asset_names)

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
  stats::na.omit(download_locations)
}

extract_urls <- function(asset_names, items) {
  items_urls <- lapply(
    names(asset_names),
    function(asset_name) suppressWarnings(rstac::assets_url(items, asset_name))
  )
  names(items_urls) <- names(asset_names)

  items_urls <- items_urls[!vapply(items_urls, is.null, logical(1))]

  items_urls
}

maybe_sign_items <- function(items, sign_function) {
  if (!is.null(sign_function)) {
    items <- sign_function(items)
  }
  items
}

