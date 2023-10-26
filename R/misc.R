#' @export
`[.rsi_band_mapping` <- function(x, i) {
  out <- x
  attributes(out) <- NULL
  names(out) <- names(x)
  out <- out[i]
  out_names <- names(out)
  mostattributes(out) <- attributes(x)
  names(out) <- out_names
  out
}

#' @export
`[[.rsi_band_mapping` <- function(x, i) {
  out <- x
  attributes(out) <- NULL
  names(out) <- names(x)
  out <- out[i]
  out_names <- names(out)
  mostattributes(out) <- attributes(x)
  names(out) <- out_names
  out
}

#' @export
print.rsi_band_mapping <- function(x, ...) {
  cat("An rsi band mapping object with attributes:\n")
  cat(names(attributes(x)), sep = " ")
  cat("\n\n")
  x_names <- names(x)
  attributes(x) <- NULL
  names(x) <- x_names
  print(x)
}
