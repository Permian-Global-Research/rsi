test_that("get_landsat_imagery() is stable", {
  skip_on_cran()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 1000)

  expect_no_error(
    out <- get_landsat_imagery(
      aoi,
      "2022-06-01",
      "2022-06-30",
      output_filename = tempfile(fileext = ".tif")
    )
  )
  expect_no_error(terra::rast(out))
  expect_true(
    all(
      names(terra::rast(out)) %in%
        as.vector(landsat_band_mapping$planetary_computer_v1)
    )
  )
})

test_that("get_sentinel1_imagery() is stable", {
  skip_on_cran()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 1000)

  expect_no_error(
    out <- get_sentinel1_imagery(
      aoi,
      "2022-06-01",
      "2022-06-30",
      output_filename = tempfile(fileext = ".tif")
    )
  )
  expect_no_error(terra::rast(out))
  expect_true(
    all(
      names(terra::rast(out)) %in%
        as.vector(sentinel1_band_mapping$planetary_computer_v1)
    )
  )
})

test_that("get_sentinel2_imagery() is stable", {
  skip_on_cran()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 1000)

  expect_no_error(
    out <- get_sentinel2_imagery(
      aoi,
      "2022-06-01",
      "2022-06-30",
      output_filename = tempfile(fileext = ".tif"),
      mask_function = sentinel2_mask_function
    )
  )
  expect_no_error(terra::rast(out))
  expect_true(
    all(
      names(terra::rast(out)) %in%
        as.vector(sentinel2_band_mapping$planetary_computer_v1)
    )
  )
})

test_that("get_dem() is stable", {
  skip_on_cran()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 1000)

  expect_no_error(
    out <- get_dem(
      aoi,
      output_filename = tempfile(fileext = ".tif")
    )
  )
  expect_no_error(terra::rast(out))
  expect_true(
    all(
      names(terra::rast(out)) %in%
        as.vector(dem_band_mapping$planetary_computer_v1)
    )
  )
})

test_that("non-default mappings work", {
  skip_on_cran()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 1000)

  expect_no_error(
    out <- get_sentinel2_imagery(
      aoi,
      "2022-06-01",
      "2022-06-30",
      output_filename = tempfile(fileext = ".tif"),
      asset_names = sentinel2_band_mapping$aws_v1
    )
  )
  expect_no_error(terra::rast(out))
  expect_true(
    all(
      names(terra::rast(out)) %in%
        as.vector(sentinel2_band_mapping$aws_v1)
    )
  )
})

test_that("can download RTC products", {
  skip_if(Sys.getenv("rsi_pc_key") == "", "Environment variable `rsi_pc_key` not set")
  skip_on_cran()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 1000)

  expect_no_error(
    out <- get_sentinel1_imagery(
      aoi,
      "2022-06-01",
      "2022-06-30",
      output_filename = tempfile(fileext = ".tif"),
      collection = "sentinel-1-rtc"
    )
  )
  expect_no_error(terra::rast(out))
  expect_true(
    all(
      names(terra::rast(out)) %in%
        as.vector(sentinel1_band_mapping$planetary_computer_v1)
    )
  )
})

test_that("hidden arguments work", {
  skip_on_cran()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 1000)

  expect_no_error(
    out <- get_landsat_imagery(
      aoi,
      "2022-06-01",
      "2022-06-30",
      output_filename = tempfile(fileext = ".tif"),
      query_function = query_planetary_computer,
      mask_function = landsat_mask_function
    )
  )
  expect_no_error(terra::rast(out))
  expect_true(
    all(
      names(terra::rast(out)) %in%
        as.vector(landsat_band_mapping$planetary_computer_v1)
    )
  )
})
