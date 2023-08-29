test_that("subsetting works", {
  expect_snapshot(landsat_band_mapping$planetary_computer_v1)
  expect_snapshot(landsat_band_mapping$planetary_computer_v1["red"])
  expect_snapshot(landsat_band_mapping$planetary_computer_v1[["red"]])
  expect_snapshot(
    landsat_band_mapping$planetary_computer_v1[landsat_band_mapping$planetary_computer_v1 == "R"]
  )
})
