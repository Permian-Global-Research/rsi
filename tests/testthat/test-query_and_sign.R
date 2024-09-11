test_that("non-4326 CRS warns", {
  nc <- sf::read_sf(
    system.file("shape/nc.shp", package = "sf")
  )
  expect_warning(
    rsi_query_api(
      sf::st_as_sfc(sf::st_bbox(nc)),
      stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
      collection = "landsat-c2-l2",
      start_date = "2023-08-01",
      end_date = "2023-09-01",
      limit = 10
    ),
    class = "rsi_reprojecting_bbox"
  )
})

test_that("unaccepted bbox objects error well", {
  expect_error(
    rsi_query_api(
      "not a bbox",
      stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
      collection = "landsat-c2-l2",
      start_date = "2023-08-01",
      end_date = "2023-09-01",
      limit = 10
    ),
    class = "rsi_bbox_wrong_class"
  )
})
