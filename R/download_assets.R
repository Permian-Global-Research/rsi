download_assets <- function(urls, destinations, gdalwarp_options) {
  if (length(urls) != length(destinations)) {
    rlang::abort("`urls` and `destinations` must be the same length.")
  }

  mapply(
    function(url, destination) {
      sf::gdal_utils(
        "warp",
        paste0("/vsicurl/", url),
        destination,
        options = gdalwarp_options,
        quiet = TRUE
      )
    },
    url = urls,
    destination = destinations
  )

  destinations
}
