#' Deprecated functions
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' These functions have been deprecated in favor of better approaches.
#'
#' * `default_query_function()` was renamed to `rsi_query_api()`. These
#'   functions are identical, and the older name will be removed in a future
#'   release.
#'
#' @name deprecated
#' @keywords internal
#' @export
default_query_function <- function(bbox,
                                   stac_source,
                                   collection,
                                   start_date,
                                   end_date,
                                   limit,
                                   ...) {
  lifecycle::deprecate_warn(
    "0.2.0",
    "default_query_function()",
    "rsi_query_api()"
  )
  rsi_query_api(
    bbox = bbox,
    stac_source = stac_source,
    collection = collection,
    start_date = start_date,
    end_date = end_date,
    limit = limit,
    ...
  )
}
