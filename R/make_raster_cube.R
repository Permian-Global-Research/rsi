make_raster_cube <- function(features,
                             assets,
                             mask,
                             wkt,
                             pixel_x_size,
                             pixel_y_size,
                             imagery_time_step,
                             imagery_aggregation_function,
                             imagery_resampling_function,
                             bbox,
                             start_date,
                             end_date) {
  stac_collection <- gdalcubes::stac_image_collection(
    features,
    asset_names = assets
  )

  if (is.null(start_date)) {
    extent <- gdalcubes::extent(stac_collection)
    if (is.null(imagery_time_step)) imagery_time_step <- "P1D"
  } else {
    extent <- list(
      left = bbox[["xmin"]],
      right = bbox[["xmax"]],
      bottom = bbox[["ymin"]],
      top = bbox[["ymax"]],
      t0 = start_date,
      t1 = end_date
    )
  }

  stac_view <- gdalcubes::cube_view(
    srs = wkt,
    dx = pixel_x_size,
    dy = pixel_y_size,
    dt = imagery_time_step,
    aggregation = imagery_aggregation_function,
    resampling = imagery_resampling_function,
    extent = extent
  )
  gdalcubes::raster_cube(
    stac_collection,
    stac_view,
    mask
  )
}
