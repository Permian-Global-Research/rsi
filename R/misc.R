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
c.rsi_band_mapping <- function(...) {
  dots <- list(...)
  x <- dots[[1]]
  dots[[1]] <- as.vector(x)
  names(dots[[1]]) <- names(x)
  out <- do.call(c, dots)
  out_names <- names(out)
  mostattributes(out) <- attributes(x)
  names(out) <- out_names
  not_named <- which(names(out) == "")
  names(out)[not_named] <- out[not_named]
  class(out) <- class(x)
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

build_progressr <- function(n) {
  if (rlang::is_installed("progressr")) {
    progressr::progressor(n, on_exit = FALSE)
  } else {
    function(...) NULL # nocov
  }
}
