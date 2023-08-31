test_that("Index calculation is stable", {
  skip_if_not_installed("terra")
  index_out <- tempfile(fileext = ".tif")
  expect_no_error(
    out <- calculate_indices(
      system.file("rasters/example_sentinel1.tif", package = "rsi"),
      filter_platforms(platforms = "Sentinel-1 (Dual Polarisation VV-VH)"),
      index_out,
      names_suffix = "sentinel1"
    )
  )

  expect_no_error(terra::rast(out))

  expect_equal(
    terra::values(terra::rast(out, lyrs = "DPDD_sentinel1")),
    terra::values(terra::rast(system.file("rasters/dpdd.tif", package = "rsi")))
  )
})

test_that("Index calculations fail when missing a column", {
  expect_error(
    calculate_indices(
      system.file("rasters/example_sentinel1.tif", package = "rsi"),
      filter_platforms(platforms = "Sentinel-1 (Dual Polarisation VV-VH)")["formula"],
      index_out
    ),
    class = "rsi_missing_column"
  )
})

test_that("Index calculations fail when missing bands", {
  x <- tryCatch(
    calculate_indices(
      system.file("rasters/example_sentinel1.tif", package = "rsi"),
      filter_platforms(platforms = "Landsat-OLI"),
      index_out
    ),
    error = function(e) class(e)
  )
  print(x)

  expect_true("rsi_missing_indices" %in% x)
})
