test_that("stack_rasters works", {
  expect_equal(
    terra::values(
      terra::rast(
        stack_rasters(
          list(
            system.file("rasters/example_sentinel1.tif", package = "rsi")
          ),
          tempfile(fileext = ".vrt")
        )
      )
    ),
    terra::values(terra::rast(system.file("rasters/example_sentinel1.tif", package = "rsi")))
  )
})

test_that("stack_rasters works with non-VRT outputs", {
  expect_no_error(
    out_tif <- stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      tempfile(fileext = ".tif")
    )
  )

  # the re-compression means we don't expect this to necessarily be the same size
  # but it should still be a decent sized file, not just a text file
  expect_true(
    file.info(out_tif)$size >
      (file.info(system.file("rasters/example_sentinel1.tif", package = "rsi"))$size / 2)
  )

  expect_equal(
    terra::values(terra::rast(out_tif, drivers = "GTiff")),
    terra::values(terra::rast(system.file("rasters/example_sentinel1.tif", package = "rsi")))
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

test_that("stack_rasters fails when rasters are not character vectors", {
  r1 <- terra::rast(matrix(rnorm(100), 10))
  expect_snapshot(
    stack_rasters(r1, "a"),
    error = TRUE
  )
})

test_that("stack_rasters warns when arguments are being ignored", {
  expect_warning(
    stack_rasters(
      list(
        system.file("rasters/example_sentinel1.tif", package = "rsi")
      ),
      tempfile(fileext = ".vrt"),
      gdalwarp_options = c("THIS IS IGNORED")
    ),
    class = "rsi_gdal_options_ignored"
  )
})

test_that("type_and_length checks", {
  expect_snapshot(
    stack_rasters("a", c("a", "b")),
    error = TRUE
  )

  expect_snapshot(
    stack_rasters("a", "b", resampling_method = c("a", "b")),
    error = TRUE
  )
})
