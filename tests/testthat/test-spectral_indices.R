test_that("spectral_indices() works", {
  # Loading indices three ways
  # First, even if we have no internet and no cache (like on CRAN)
  # then we should still load indices from package data, if needed,
  # with no warnings other than the package's warning:
  expect_no_warning(
    suppressWarnings(
      spectral_indices(update_cache = FALSE),
      classes = "rsi_failed_download"
    )
  )

  # Second, if we're online, we should be able to download the current indices:
  skip_if_offline()
  expect_no_warning(spectral_indices(update_cache = FALSE))

  # Third, if we're online and can write to the cache folder,
  # we should be able to update our cache:
  skip_on_cran()
  expect_no_warning(spectral_indices())
})


