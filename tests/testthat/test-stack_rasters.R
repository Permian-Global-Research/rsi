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
