test_that("stack_rasters works", {
  expect_equal(
    stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      tempfile(fileext = ".vrt")
    ) |>
      terra::rast() |>
      terra::values(),
    terra::rast(system.file("rasters/example_sentinel1.tif", package = "rsi")) |>
      terra::values()
  )
})

test_that("stack_rasters fails when reference_raster isn't in the vector", {
  expect_error(
    stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      tempfile(fileext = ".vrt"),
      reference_raster = 2
    ),
    class = "rsi_not_in_vec"
  )

  expect_error(
    stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      tempfile(fileext = ".vrt"),
      reference_raster = "some_raster"
    ),
    class = "rsi_not_in_vec"
  )
})

test_that("stack_rasters fails when extent isn't four numbers", {
  expect_error(
    stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      tempfile(fileext = ".vrt"),
      extent = 20
    ),
    class = "rsi_bad_extent"
  )
})

test_that("stack_rasters fails when resolution isn't 1-2 numbers", {
  expect_error(
    stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      tempfile(fileext = ".vrt"),
      resolution = c(20, 30, 40)
    ),
    class = "rsi_bad_resolution"
  )
})

test_that("stack_rasters fails when rasters don't share a CRS", {
  s1 <- tempfile(fileext = ".tif")
  terra::writeRaster(
    terra::project(
      terra::rast(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      "EPSG:4326"
    ),
    s1
  )

  expect_error(
    stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi"),
        s1
      ),
      tempfile(fileext = ".vrt")
    ),
    class = "rsi_multiple_crs"
  )
})
