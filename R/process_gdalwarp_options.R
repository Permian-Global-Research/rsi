process_gdalwarp_options <- function(gdalwarp_options,
                                     aoi,
                                     pixel_x_size = 30,
                                     pixel_y_size = 30) {
  if (is.null(gdalwarp_options)) {
    gdalwarp_options <- character(0)
  }

  if (!("-t_srs" %in% gdalwarp_options)) {
    gdalwarp_options <- c(gdalwarp_options, "-t_srs", sf::st_crs(aoi)$wkt)
  }

  if (!("-te" %in% gdalwarp_options)) {
    gdalwarp_options <- c(gdalwarp_options, "-te", sf::st_bbox(aoi))
  }

  if (!("-tr" %in% gdalwarp_options)) {
    gdalwarp_options <- c(gdalwarp_options, "-tr", pixel_x_size, pixel_y_size)
  }

  gdalwarp_options
}
