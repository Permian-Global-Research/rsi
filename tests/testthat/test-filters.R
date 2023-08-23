test_that("filter_platforms() works", {
  # Get package indices, in case we're on CRAN without internet:
  idxs <- suppressWarnings(
    spectral_indices(update_cache = FALSE),
    classes = "rsi_failed_download"
  )

  test_plats <- c("Landsat-OLI", "Sentinel-2")

  expect_no_error(
    both_plats <- filter_platforms(idxs, test_plats)
  )

  expect_true(
    all(
      vapply(both_plats$platforms, function(x) all(test_plats %in% x), logical(1))
    )
  )

  expect_no_error(
    either_plat <- filter_platforms(idxs, test_plats, operand = "any")
  )

  expect_true(
    all(
      vapply(either_plat$platforms, function(x) any(test_plats %in% x), logical(1))
    )
  )
})

test_that("filter_bands() works", {
  # Get package indices, in case we're on CRAN without internet:
  idxs <- suppressWarnings(
    spectral_indices(update_cache = FALSE),
    classes = "rsi_failed_download"
  )

  test_bands <- c("R", "N")

  expect_no_error(
    both_bands <- filter_bands(idxs, test_bands)
  )

  expect_true(
    all(
      vapply(both_bands$bands, function(x) all(test_bands %in% x), logical(1))
    )
  )

  expect_no_error(
    either_band <- filter_bands(idxs, test_bands, operand = "any")
  )

  expect_true(
    all(
      vapply(either_band$bands, function(x) any(test_bands %in% x), logical(1))
    )
  )
})
