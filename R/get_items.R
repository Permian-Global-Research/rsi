get_items <- function(bbox_wgs84,
                      stac_source,
                      collections,
                      start_date,
                      end_date,
                      limit,
                      download_function) {
  if (!is.null(start_date)) {
    start_date <- process_dates(start_date)
    end_date <- process_dates(end_date)
    datetime <- paste0(start_date, "/", end_date)
  } else {
    datetime <- NULL
  }

  rstac::stac(stac_source) |>
    rstac::stac_search(
      collections = collections,
      bbox = c(
        bbox_wgs84["xmin"],
        bbox_wgs84["ymin"],
        bbox_wgs84["xmax"],
        bbox_wgs84["ymax"]
      ),
      datetime = datetime,
      limit = limit
    ) |>
    download_function()
}
