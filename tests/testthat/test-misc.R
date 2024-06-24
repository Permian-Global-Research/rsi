test_that("subsetting works", {
  expect_snapshot(landsat_band_mapping$planetary_computer_v1)
  expect_snapshot(landsat_band_mapping$planetary_computer_v1["red"])
  expect_snapshot(landsat_band_mapping$planetary_computer_v1[["red"]])
  expect_snapshot(
    landsat_band_mapping$planetary_computer_v1[landsat_band_mapping$planetary_computer_v1 == "R"]
  )
})

test_that("c works", {
  expect_snapshot(c(rsi::sentinel2_band_mapping$planetary_computer_v1, scl = "scl"))
  expect_identical(
    c(rsi::sentinel2_band_mapping$planetary_computer_v1, scl = "scl"),
    c(rsi::sentinel2_band_mapping$planetary_computer_v1, "scl")
  )
})