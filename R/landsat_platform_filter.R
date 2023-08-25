#' Filter Landsat features to only specific platforms
#'
#' @param items A `STACItemCatalog` containing some number of features
#' @param platforms A vector of acceptable platforms, for instance `landsat-9`.
#' Note that this refers to satellite names, and _not_ to platforms in
#' `spectral_indices()`.
#'
#' @returns A `STACItemCollection`.
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
#'   item_filter_function = landsat_platform_filter
#' )
#'
#' @export
landsat_platform_filter <- function(items, platforms) {
  acceptable_platforms <- vapply(
    items$features,
    function(x) tryCatch(x$properties$platform %in% platforms, error = function(e) FALSE),
    logical(1)
  )
  items$features <- items$features[acceptable_platforms]
  items
}
