#' Filter indices based on (relatively) complicated fields
#'
#' @param platforms,bands Names of the instruments (for `platforms`) or spectra
#' (for `bands`) indices must contain.
#' @param indices The data frame to filter. Must contain the relevant column.
#' @param `operand` A function defining how to apply this filter.
#' For instance, `operand = all` means that the index must contain all the
#' `platforms` or `bands` provided, while `operand = any` means that the index
#' must contain at least one of the `platforms` or `bands` provided.
#'
#' @examples
#' filter_platforms(platforms = "Sentinel-2")
#' filter_platforms(platforms = c("Landsat-OLI", "Sentinel-2"))
#' filter_bands(bands = c("R", "N"), operand = any)
#'
#' @returns A filtered version of `indices`.
#'
#' @rdname filters
#' @export
filter_platforms <- function(indices = spectral_indices(),
                             platforms = unique(unlist(spectral_indices()$platforms)),
                             operand = c("all", "any")) {
  platforms <- rlang::arg_match(platforms, multiple = TRUE)
  if (missing(operand)) {
    operand <- rlang::arg_match(operand)
  }
  ret_indices <- vapply(
    indices$platforms,
    function(x) rlang::exec(operand, platforms %in% x),
    logical(1)
  )
  indices[ret_indices, , drop = FALSE]
}

#' @rdname filters
#' @export
filter_bands <- function(indices = spectral_indices(),
                         bands = unique(unlist(spectral_indices()$bands)),
                         operand = c("all", "any")) {
  bands <- rlang::arg_match(bands, multiple = TRUE)
  if (missing(operand)) {
    operand <- rlang::arg_match(operand)
  }
  ret_indices <- vapply(
    indices$bands,
    function(x) rlang::exec(operand, bands %in% x),
    logical(1)
  )
  indices[ret_indices, , drop = FALSE]
}
