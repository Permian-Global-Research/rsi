#' Filter Landsat features to only specific platforms
#'
#' @param items A `STACItemCatalog` containing some number of features
#' @param platforms A vector of acceptable platforms, for instance `landsat-9`.
#' Note that this refers to satellite names, and _not_ to platforms in
#' `spectral_indices()`.
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
