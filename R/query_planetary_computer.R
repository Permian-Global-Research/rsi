#' Execute STAC queries against the Planetary Computer
#'
#' @param q The query object from [rstac::stac_search()].
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
#'   query_function = query_planetary_computer
#' )
#'
#' @export
query_planetary_computer <- function(q,
                                     subscription_key = Sys.getenv("rsi_pc_key")) {
  if (subscription_key == "") {
    rstac::items_sign(rstac::get_request(q), rstac::sign_planetary_computer())
  } else {
    rstac::items_sign(
      rstac::get_request(q),
      rstac::sign_planetary_computer(
        headers = c("Ocp-Apim-Subscription-Key" = subscription_key)
      )
    )
  }
}
