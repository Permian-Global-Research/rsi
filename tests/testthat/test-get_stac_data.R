test_that("get_landsat_imagery() is stable", {
  skip_on_cran()
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

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
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

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
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

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
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

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
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

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
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

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
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

  expect_no_error(
    out <- get_landsat_imagery(
      aoi,
      "2022-06-01",
      "2022-06-30",
      output_filename = tempfile(fileext = ".tif"),
      query_function = rsi_query_api,
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

test_that("simple merge method works", {
  skip_on_cran()
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

  expect_no_error(
    out <- get_stac_data(
      aoi,
      "2021-01-01",
      "2021-12-31",
      asset_names = "lcpri",
      stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1",
      collection = "usgs-lcmap-conus-v13",
      query_function = rsi_query_api,
      sign_function = rsi::sign_planetary_computer,
      output_filename = tempfile(fileext = ".tif")
    )
  )
  expect_no_error(terra::rast(out))
})

test_that("warning (but not error) fires if `mask_band` is not NULL with NULL `mask_function`", {
  skip_on_cran()
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

  expect_snapshot(
    x <- get_landsat_imagery(
      aoi = aoi,
      start_date = "2022-06-01",
      end_date = "2022-08-01",
      mask_function = NULL,
      rescale_bands = FALSE,
      output_filename = tempfile(fileext = ".tif")
    )
  )
})

test_that("get_*_data works with mapply() (#17)", {
  skip_on_cran()
  skip_if_offline()
  san_antonio <- sf::st_point(c(-98.491142, 29.424349))
  san_antonio <- sf::st_sfc(san_antonio, crs = "EPSG:4326")
  san_antonio <- sf::st_buffer(sf::st_transform(san_antonio, "EPSG:3081"), 100)

  expect_no_error(
    mapply(
      get_landsat_imagery,
      start_date = c("2023-09-01", "2023-10-01"),
      end_date = c("2023-09-30", "2023-10-31"),
      output_filename = replicate(2, tempfile(fileext = ".tif")),
      MoreArgs = c(aoi = list(san_antonio))
    )
  )
})

test_that("proper error if no items are found", {
  skip_if_offline()
  skip_on_cran()

  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)

  expect_error(
    get_stac_data(
      aoi,
      start_date = "1970-01-01", # pre-LCMAP dates
      end_date = "1970-12-31",
      asset_names = "lcpri",
      stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
      collection = "usgs-lcmap-conus-v13",
      output_filename = tempfile(fileext = ".tif"),
    ),
    class = "rsi_no_items_found"
  )
})

test_that("no-composite paths work on Windows #29, #32", {
  skip_if_offline()
  skip_on_cran()
  skip_on_os("mac")
  skip_on_os("linux")

  aoi <- sf::st_buffer(
    sf::st_transform(
      sf::st_sfc(sf::st_point(c(-74.912131, 44.080410)), crs = 4326),
      3857
    ),
    100
  )

  expect_no_error(
    get_landsat_imagery(
      aoi = aoi,
      start_date = "2022-06-01",
      end_date = "2022-08-01",
      composite_function = NULL,
      output_filename = tempfile(fileext = ".tif")
    )
  )
})

test_that("no-composites return the same data", {
  skip_if_offline()
  skip_on_cran()

  aoi <- sf::st_buffer(
    sf::st_transform(
      sf::st_sfc(sf::st_point(c(-74.912131, 44.080410)), crs = 4326),
      3857
    ),
    100
  )

  expect_contains(
    names(
      terra::rast(
        get_landsat_imagery(
          aoi = aoi,
          start_date = "2022-07-01",
          end_date = "2022-07-05",
          composite_function = NULL,
          output_filename = tempfile(fileext = ".tif")
        )
      )
    ),
    setdiff(rsi::landsat_band_mapping$planetary_computer_v1, "T")
  )
})

test_that("get_naip_imagery() is stable", {
  skip_on_cran()
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

  expect_no_error(
    out <- get_naip_imagery(
      aoi,
      "2018-01-01",
      "2020-01-31",
      output_filename = tempfile(fileext = ".tif")
    )
  )
  expect_no_error(terra::rast(out))
})

test_that("get_alos_palsar_imagery() is stable", {
  skip_on_cran()
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 3857), 100)

  expect_no_error(
    out <- get_alos_palsar_imagery(
      aoi,
      "2021-01-01",
      "2021-12-31",
      output_filename = tempfile(fileext = ".tif")
    )
  )
  expect_no_error(terra::rast(out))
})

test_that("non-sf AOI throws an error", {
  expect_error(
    get_stac_data(2),
    class = "rsi_aoi_not_sf"
  )
})

test_that("Providing pixel sizes with geographic coords fires the expected warning", {
  skip_on_cran()
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)

  expect_error(
    tryCatch(
      get_stac_data(aoi, pixel_x_size = 30, pixel_y_size = 30),
      rsi_default_pixel_size_geographic_coords = stop("The warning fired")
    )
  )
})

test_that("Providing no asset names fires the expected warning", {
  skip_on_cran()
  skip_if_offline()
  aoi <- sf::st_point(c(-74.912131, 44.080410))
  aoi <- sf::st_set_crs(sf::st_sfc(aoi), 4326)
  aoi <- sf::st_buffer(sf::st_transform(aoi, 5070), 100)

  expect_error(
    tryCatch(
      get_stac_data(
        aoi,
        start_date = "2022-01-01",
        end_date = "2022-12-31",
        stac_source = "https://planetarycomputer.microsoft.com/api/stac/v1/",
        collection = "usgs-lcmap-conus-v13",
        output_filename = tempfile(fileext = ".tif"),
      ),
      rsi_missing_asset_names = stop("The warning fired")
    )
  )
})
