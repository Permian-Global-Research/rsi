landsat_platform_filter <- function(items, platforms) {
  acceptable_platforms <- vapply(
    items$features,
    function(x) tryCatch(x$properties$platform %in% platforms, error = function(e) FALSE),
    logical(1)
  )
  items$features <- items$features[acceptable_platforms]
  items
}
