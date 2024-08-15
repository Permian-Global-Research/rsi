test_that("landsat_mask_function arguments work", {
  skip_on_cran()
  skip_if_offline()

  boston <- sf::st_point(c(-71.0610279, 42.361697)) |>
    sf::st_sfc(crs = 4326) |>
    sf::st_transform(2249) |>
    sf::st_buffer(10000)

  bands <- rsi::landsat_band_mapping$planetary_computer_v1[""]
  bands[[1]] <- "qa_pixel"
  names(bands) <- "qa_pixel"

  boston_landsat <- rsi::get_landsat_imagery(
    boston,
    "2022-06-01",
    "2022-07-01",
    asset_names = bands,
    output_filename = tempfile(fileext = ".tif"),
    mask_function = NULL,
    mask_band = NULL
  )

  expect_gt(
    sum(terra::values(landsat_mask_function(terra::rast(boston_landsat)))),
    sum(terra::values(landsat_mask_function(terra::rast(boston_landsat), "water")))
  )

  expect_gt(
    sum(terra::values(landsat_mask_function(terra::rast(boston_landsat), "both"))),
    sum(terra::values(landsat_mask_function(terra::rast(boston_landsat))))
  )

  expect_equal(
    sum(terra::values(landsat_mask_function(terra::rast(boston_landsat), "both"))),
    sum(terra::values(landsat_mask_function(terra::rast(boston_landsat), c("land", "water"))))
  )

  expect_equal(
    sum(terra::values(landsat_mask_function(terra::rast(boston_landsat), "both"))),
    sum(
      terra::values(
        landsat_mask_function(
          terra::rast(boston_landsat), 
          masked_bits = list(
            clear_land = c(0:5, 7, 9, 11, 13, 15),
            clear_water = c(0:5, 9, 11, 13, 15)
          )
        )
      )
    )
  )  
})
