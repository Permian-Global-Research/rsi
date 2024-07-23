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

#' Default options for GDAL
#' 
#' These functions provide useful default options for GDAL functions,
#' making downloading and warping (hopefully!) more efficient for
#' most use cases. 
#' 
#' @returns A vector of options for GDAL commands.
#' 
#' @name rsi_gdal_options
#' @export
rsi_gdal_config_options <- function() {
  c(
    VSI_CACHE = "TRUE",
    GDAL_CACHEMAX = "30%",
    VSI_CACHE_SIZE = "10000000",
    GDAL_HTTP_MULTIPLEX = "YES",
    GDAL_INGESTED_BYTES_AT_OPEN = "32000",
    GDAL_DISABLE_READDIR_ON_OPEN = "EMPTY_DIR",
    GDAL_HTTP_VERSION = "2",
    GDAL_HTTP_MERGE_CONSECUTIVE_RANGES = "YES",
    GDAL_NUM_THREADS = "ALL_CPUS",
    GDAL_HTTP_USERAGENT = "rsi (https://permian-global-research.github.io/rsi/)"
  )
}

#' @rdname rsi_gdal_options
#' @export
rsi_gdalwarp_options <- function() {
  c(
    "-r", "bilinear",
    "-multi",
    "-overwrite",
    "-co", "COMPRESS=DEFLATE",
    "-co", "PREDICTOR=2",
    "-co", "NUM_THREADS=ALL_CPUS"
  )
}
