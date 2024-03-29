#' Query a STAC API using a specific spatiotemporal area of interest
#'
#' This function is the default method used to retrieve lists of items to
#' download for all the collections and endpoints supported by rsi. It will
#' likely work for any other STAC APIs of interest.
#'
#' You can pass your own query functions to `get_stac_data()` and its variants.
#' This is the best way to perform more complex queries, for instance if you
#' need to provide authentication to get the list of items (not just the assets)
#' available for your AOI, or to perform cloud filtering prior to downloading
#' assets.
#'
#' @param bbox An sfc object representing the spatial bounding box of your area
#' of interest. This must be in EPSG:4326 coordinates (and, if this function is
#' called from within `get_stac_data()`, it will be)
#' @inheritParams get_stac_data
#' @param start_date,end_date Character strings of length 1 representing the
#' boundaries of your temporal range of interest, in RFC-3339 format. Set either
#' argument to `..` to use an open interval; set `start_date` to `NULL` to not
#' pass a temporal range of interest (which may cause errors with some APIs). If
#' this function is called from within `get_stac_data()`, the inputs to
#' `start_date` and `end_date` will have already been processed to try and force
#' RFC-3339 compliance.
#' @param ... Ignored by this function. Arguments passed to `get_stac_data()`
#' via `...` will be available (unchanged) in this function
#'
#' @returns  A StacItemCollection object.
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
#'   query_function = rsi_query_api
#' )
#'
#' @export
rsi_query_api <- function(bbox,
                          stac_source,
                          collection,
                          start_date,
                          end_date,
                          limit,
                          ...) {
  if (!is.null(start_date)) {
    datetime <- paste0(start_date, "/", end_date)
  } else {
    datetime <- NULL
  }

  items <- rstac::stac_search(
    rstac::stac(stac_source),
    collections = collection,
    bbox = c(
      bbox["xmin"],
      bbox["ymin"],
      bbox["xmax"],
      bbox["ymax"]
    ),
    datetime = datetime,
    limit = limit
  )

  items <- rstac::items_fetch(
    rstac::get_request(items, rsi_user_agent),
    rsi_user_agent
  )

  items
}

#' Sign STAC items retrieved from the Planetary Computer
#'
#' @param items A STACItemCollection, as returned by `rsi_query_api`.
#' @param subscription_key Optionally, a subscription key associated with your
#' Planetary Computer account. At the time of writing, this is required for
#' downloading Sentinel 1 RTC products, as well as NAIP imagery. This key will
#' be automatically used if the environment variable `rsi_pc_key` is set.
#'
#' @returns A STACItemCollection object with signed assets url.
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
#'   sign_function = sign_planetary_computer
#' )
#'
#' @export
sign_planetary_computer <- function(items,
                                    subscription_key = Sys.getenv("rsi_pc_key")) {
  if (subscription_key == "") {
    rstac::items_sign(items, rstac::sign_planetary_computer(rsi_user_agent))
  } else {
    rstac::items_sign(
      items,
      rstac::sign_planetary_computer(
        rsi_user_agent,
        headers = c("Ocp-Apim-Subscription-Key" = subscription_key)
      )
    )
  }
}
