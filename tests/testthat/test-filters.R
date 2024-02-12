test_that("filter_platforms() works", {
  # Get package indices, in case we're on CRAN without internet:
  idxs <- suppressWarnings(
    spectral_indices(update_cache = FALSE),
    classes = "rsi_failed_download"
  )

  test_plats <- c("Landsat-OLI", "Sentinel-2")

  expect_no_error(
    # no internet and no cache file == warning
    both_plats <- suppressWarnings(filter_platforms(idxs, test_plats), classes = "rsi_failed_download")
  )

  expect_true(
    all(
      vapply(both_plats$platforms, function(x) all(test_plats %in% x), logical(1))
    )
  )

  expect_no_error(
    either_plat <- suppressWarnings(filter_platforms(idxs, test_plats, operand = "any"), classes = "rsi_failed_download")
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
    both_bands <- suppressWarnings(filter_bands(idxs, test_bands), classes = "rsi_failed_download")
  )

  expect_true(
    all(
      vapply(both_bands$bands, function(x) all(test_bands %in% x), logical(1))
    )
  )

  expect_no_error(
    either_band <- suppressWarnings(filter_bands(idxs, test_bands, operand = "any"), classes = "rsi_failed_download")
  )

  expect_true(
    all(
      vapply(either_band$bands, function(x) any(test_bands %in% x), logical(1))
    )
  )
})
