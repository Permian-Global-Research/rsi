#' Download data from STAC queries against the Planetary Computer
#'
#' @param q The query object from [rstac::stac_search()].
#' @param subscription_key Optionally, a subscription key associated with your
#' Planetary Computer account. At the time of writing, this is required for
#' downloading Sentinel 1 RTC products, as well as NAIP imagery. This key will
#' be automatically used if the environment variable `rsi_pc_key` is set.
#'
#' @export
download_planetary_computer <- function(q,
                                        subscription_key = Sys.getenv("rsi_pc_key")) {
  if (subscription_key == "") {
    rstac::items_sign(rstac::get_request(q), rstac::sign_planetary_computer())
  } else {
    rstac::get_request(q) |>
      rstac::items_sign(
        rstac::sign_planetary_computer(
          headers = c("Ocp-Apim-Subscription-Key" = subscription_key)
        )
      )
  }
}
