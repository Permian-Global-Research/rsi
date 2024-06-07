test_that("Index calculation is stable", {
  skip_if_not_installed("terra")
  # covr can't instrument the local block properly
  skip_if(nzchar(Sys.getenv("is_covr")))
  skip_on_cran()
  index_out <- tempfile(fileext = ".tif")
  expect_no_error(
    out <- calculate_indices(
      system.file("rasters/example_sentinel1.tif", package = "rsi"),
      suppressWarnings(filter_platforms(spectral_indices(download_indices = FALSE, update_cache = FALSE), platforms = "Sentinel-1 (Dual Polarisation VV-VH)")),
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

test_that("Extra objects can be passed to calculate_indices()", {
  skip_if_not_installed("terra")
  # covr can't instrument the local block properly
  skip_if(nzchar(Sys.getenv("is_covr")))
  skip_on_cran()
  index_out <- tempfile(fileext = ".tif")

  idx <- suppressWarnings(filter_platforms(spectral_indices(download_indices = FALSE, update_cache = FALSE), platforms = "Sentinel-1 (Dual Polarisation VV-VH)"))[1, ]
  idx$formula <- "pmax(VH, 1000)"

  expect_warning(
    out <- calculate_indices(
      system.file("rasters/example_sentinel1.tif", package = "rsi"),
      idx,
      index_out,
      names_suffix = "sentinel1",
      extra_objects = list(`pmax` = pmax)
    ),
    class = "rsi_extra_objects"
  )

  expect_true(
    all(terra::values(terra::rast(out)) == 1000)
  )
})

test_that("Index calculations fail when missing a column", {
  skip_on_cran()
  index_out <- tempfile(fileext = ".tif")
  expect_error(
    calculate_indices(
      system.file("rasters/example_sentinel1.tif", package = "rsi"),
      suppressWarnings(filter_platforms(spectral_indices(download_indices = FALSE, update_cache = FALSE), platforms = "Sentinel-1 (Dual Polarisation VV-VH)"))["formula"],
      index_out
    ),
    class = "rsi_missing_column"
  )
})

test_that("Index calculations fail when missing bands", {
  skip_on_cran()
  index_out <- tempfile(fileext = ".tif")
  expect_error(
    calculate_indices(
      system.file("rasters/example_sentinel1.tif", package = "rsi"),
      suppressWarnings(filter_platforms(spectral_indices(download_indices = FALSE, update_cache = FALSE), platforms = "Landsat-OLI")),
      index_out
    ),
    class = "rsi_missing_indices"
  )
})

test_that("Index calculations stop obvious security issues", {
  skip_on_cran()
  example_indices <- suppressWarnings(filter_platforms(spectral_indices(download_indices = FALSE, update_cache = FALSE), platforms = "Sentinel-1 (Dual Polarisation VV-VH)"))[1, ]
  example_indices$formula <- 'system("echo something bad")'
  expect_error(calculate_indices(
    system.file("rasters/example_sentinel1.tif", package = "rsi"),
    example_indices,
    tempfile(fileext = ".tif")
  ))
})
