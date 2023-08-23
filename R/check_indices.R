check_indices <- function(remap_band_names, indices, call = rlang::caller_env()) {
  good <- TRUE
  if (!is.null(remap_band_names)) {
    good <- vapply(
      indices$bands,
      \(bands) all(bands %in% unlist(remap_band_names)),
      logical(1)
    )
  }

  if (!any(good)) {
    rlang::abort(
      "Some indices cannot be calculated using the available image bands.",
      call = call,
      class = "rsi_missing_indices"
    )
  }
}
