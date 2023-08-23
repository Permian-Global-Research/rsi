#' Get Landsat imagery
#'
#' This function downloads Landsat imagery from a STAC endpoint, by default
#' Microsoft's Planetary Computer. The `landsat_band_mapping` object included
#' in this package contains metadata relevant to the Planetary Computer STAC
#' endpoint.
#'
#' @inheritParams get_sentinel2_imagery
#' @param qa_band_name Character of length 1: The name of the QA band in your
#' STAC source. The built-in band mappings store this in the `qa_name` attribute
#' of each set, which will be used automatically if this argument is not
#' manually provided.
#' @param platforms The acceptable satellites to download imagery from.
#' @inheritParams rlang::args_dots_empty
#'
#' @inherit get_sentinel2_imagery return
#'
#' @examples
#' \dontrun{
#' aoi <- sf::st_point(c(-74.912131, 44.080410)) |>
#'   sf::st_sfc() |>
#'   sf::st_set_crs(4326) |>
#'   sf::st_transform(3857) |>
#'   sf::st_buffer(100)
#'
#' get_landsat_imagery(
#'   aoi,
#'   "2022-06-01",
#'   "2022-08-30"
#' )
#' }
#'
#' @export
get_landsat_imagery <- function(aoi,
                                start_date,
                                end_date,
                                ...,
                                pixel_x_size = 30,
                                pixel_y_size = 30,
                                imagery_time_step = "P1D",
                                imagery_aggregation_function = "median",
                                imagery_resampling_function = "bilinear",
                                reduce_time = TRUE,
                                remap_band_names = landsat_band_mapping$planetary_computer_v1,
                                stac_source = attr(remap_band_names, "stac_source"),
                                collections = attr(remap_band_names, "collection_name"),
                                qa_band_name = attr(remap_band_names, "qa_name"),
                                platforms = c("landsat-9", "landsat-8"),
                                download_function = attr(remap_band_names, "download_function"),
                                limit = 999,
                                creation_options = list(
                                  "COMPRESS" = "DEFLATE",
                                  "PREDICTOR" = "3"
                                ),
                                reduce_function = "median",
                                directory = ".") {
  rlang::check_dots_empty()
  bbox <- sf::st_bbox(aoi)
  crs <- sf::st_crs(aoi)
  bbox_wgs84 <- sf::st_transform(aoi, 4326) |> sf::st_bbox()

  items <- get_items(
    bbox_wgs84,
    stac_source,
    collections,
    start_date,
    end_date,
    limit,
    download_function
  )

  if (!is.null(platforms)) {
    acceptable_platforms <- vapply(
      items$features,
      \(x) tryCatch(x$properties$platform %in% platforms, error = \(e) FALSE),
      logical(1)
    )
    items$features <- items$features[acceptable_platforms]
  }

  qa_band_name <- qa_band_name %||% "qa_pixel"
  # "Clear with lows set"
  # https://d9-wret.s3.us-west-2.amazonaws.com/assets/palladium/production/s3fs-public/media/files/LSDS-1619_Landsat-8-9-C2-L2-ScienceProductGuide-v4.pdf
  stac_mask <- gdalcubes::image_mask(
    qa_band_name,
    values = 21824,
    invert = TRUE
  )
  assets <- c(names(remap_band_names), qa_band_name)

  stac_collection <- make_raster_cube(items$features,
                                      assets = assets,
                                      mask = stac_mask,
                                      wkt = crs$wkt,
                                      pixel_x_size,
                                      pixel_y_size,
                                      imagery_time_step,
                                      imagery_aggregation_function,
                                      imagery_resampling_function,
                                      bbox,
                                      start_date,
                                      end_date
  )

  rescale_bands <- vector("list", length(names(stac_collection)))
  names(rescale_bands) <- names(stac_collection)
  for (band in names(stac_collection)) {
    band_metadata <- items$features[[1]]$assets[[band]]
    if (!is.null(band_metadata$`raster:bands`)) {
      scale <- band_metadata$`raster:bands`[[1]]$scale
      offset <- band_metadata$`raster:bands`[[1]]$offset
      transform <- glue::glue("{band}")
      if (!is.null(scale)) transform <- paste0("(", transform, " * ", scale, ")")
      if (!is.null(offset)) transform <- paste0("(", transform, " + ", offset, ")")
      rescale_bands[[band]] <- transform
    } else {
      rescale_bands[[band]] <- NULL
    }
  }

  if (length(rescale_bands)) {
    stac_collection <- stac_collection |>
      gdalcubes::apply_pixel(
        expr = unlist(rescale_bands),
        names = names(rescale_bands),
        keep_bands = FALSE
      )
  }

  stac_collection <- remap_reformulate_reduce(
    stac_collection,
    remap_band_names,
    reduce_time,
    reduce_function
  )

  out <- gdalcubes::write_tif(
    stac_collection,
    directory,
    creation_options = creation_options
  )
  out
}
