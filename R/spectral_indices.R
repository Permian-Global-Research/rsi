#' Get the URL to download spectral indices from
#'
#' @returns A URL to download indices from.
#'
#' @examples
#' spectral_indices_url()
#'
#' @export
spectral_indices_url <- function() {
  if (!is.null(getOption("rsi_url"))) {
    return(getOption("rsi_url"))
  }
  if (!(Sys.getenv("rsi_url") == "")) {
    return(Sys.getenv("rsi_url"))
  }
  "https://raw.githubusercontent.com/awesome-spectral-indices/awesome-spectral-indices/main/output/spectral-indices-dict.json"
}

#' Get a data frame of spectral indices
#'
#' This function returns a data frame of spectral indices, from the
#' `awesome-spectral-indices` repository.
#'
#' @inheritParams rlang::args_dots_empty
#' @param url The URL to download spectral indices from. If the option `rsi_url`
#' is set, that value will be used; otherwise, if the environment variable
#' `rsi_url` is set, that value will be used; otherwise, the list at
#' https://github.com/awesome-spectral-indices/awesome-spectral-indices will
#' be used.
#' @param download_indices Logical: should this function download indices? If
#' `NULL`, this function will only download indices if the cache will be
#' updated. If `TRUE`, this function will attempt to download indices no matter
#' what. If `FALSE`, either cached or package indices will be used.
#' @param update_cache Logical: should cached indices be updated? If `NULL`,
#' cached values will be updated if the cache is older than a day. If `TRUE`,
#' the cache will be updated, if `FALSE` it will not.
#'
#' @examples
#' spectral_indices()
#'
#' @returns A [tibble::tibble] with nine columns, containing information about spectral indices.
#'
#' @source [https://github.com/awesome-spectral-indices/awesome-spectral-indices](https://github.com/awesome-spectral-indices/awesome-spectral-indices)
#'
#' @export
spectral_indices <- function(..., url = spectral_indices_url(), download_indices = NULL, update_cache = NULL) {
  rlang::check_dots_empty()
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")

  if (isFALSE(download_indices)) {
    if (isTRUE(update_cache)) {
      rlang::abort(
        "Cannot update the cache if not downloading indices.",
        class = "rsi_cache_download_conflict"
      )
    }

    update_cache <- FALSE
  }

  if (is.null(update_cache)) {
    if (file.exists(indices_path)) {
      update_cache <- (Sys.time() - file.info(indices_path)[["mtime"]]) > 86400
    } else {
      update_cache <- TRUE
    }
  }

  if (is.null(download_indices)) download_indices <- update_cache

  if (update_cache && isTRUE(download_indices)) {
    tryCatch(
      update_cached_indices(url),
      error = function(e) { # nocov start
        rlang::warn(
          c(
            "Failed to update the cache of indices.",
            i = "Returning (likely outdated) cached data instead."
          ),
          class = "rsi_failed_cache_update"
        )
        spectral_indices_internal
      } # nocov end
    )
  }

  if (!isTRUE(download_indices) && file.exists(indices_path)) {
    tibble::as_tibble(readRDS(indices_path))
  } else if (isTRUE(download_indices)) {
    tryCatch(
      download_web_indices(url),
      error = function(e) { # nocov start
        rlang::warn(
          c(
            "Failed to download new indices.",
            i = "Returning (likely outdated) package data instead."
          ),
          class = "rsi_failed_download"
        )
        spectral_indices_internal
      }
    ) # nocov end
  } else {
    rlang::warn(
      c(
        "No cache file present and `download_indices` set to `FALSE`.",
        i = "Returning (likely outdated) package data instead."
      ),
      class = "rsi_failed_download"
    )
    spectral_indices_internal
  }
}

download_web_indices <- function(url = spectral_indices_url()) {
  spectral_indices <- lapply(
    jsonlite::read_json(url)[[1]],
    function(index) {
      for (col in names(index)) {
        if (length(index[[col]]) > 1) index[[col]] <- list(unlist(index[[col]]))
      }
      tibble::as_tibble(index)
    }
  )

  spectral_indices <- do.call(rbind, spectral_indices)

  spectral_indices$formula <- gsub(" \\*\\* ", "\\^", spectral_indices$formula)
  spectral_indices$formula <- gsub("\\*\\*", "\\^", spectral_indices$formula)
  spectral_indices
}

update_cached_indices <- function(url = spectral_indices_url()) {
  # nocov start
  if (!dir.exists(tools::R_user_dir("rsi"))) {
    dir.create(tools::R_user_dir("rsi"), recursive = TRUE)
  }
  # nocov end
  indices_path <- file.path(
    tools::R_user_dir("rsi"),
    "indices.rda"
  )
  saveRDS(
    download_web_indices(url),
    indices_path
  )
}
