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

  # github actions seems to not like reading from a github URL
  skip_on_ci()

  # Second, if we're online, we should be able to download the current indices:
  skip_if_offline()
  expect_no_warning(spectral_indices(update_cache = FALSE, download_indices = TRUE))

  # Third, if we're online and can write to the cache folder,
  # we should be able to update our cache:
  skip_on_cran()
  expect_no_warning(spectral_indices())
  expect_no_warning(spectral_indices(update_cache = TRUE))
})

test_that("spectral_indices_url() respects options", {
  skip_if_not_installed("withr")
  expect_identical(
    withr::with_options(
      list("rsi_url" = "example"),
      spectral_indices_url()
    ),
    "example"
  )
})

test_that("spectral_indices_url() respects environment variables", {
  skip_if_not_installed("withr")
  expect_identical(
    withr::with_envvar(
      list("rsi_url" = "example"),
      spectral_indices_url()
    ),
    "example"
  )
})

test_that("no cache", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  if (file.exists(indices_path)) file.remove(indices_path)
  expect_no_warning(spectral_indices())
})

test_that("no cache, update false", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  if (file.exists(indices_path)) file.remove(indices_path)
  expect_snapshot(spectral_indices(update_cache = FALSE))
})

test_that("no cache, download false", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  if (file.exists(indices_path)) file.remove(indices_path)
  expect_snapshot(spectral_indices(download_indices = FALSE))
})

test_that("no cache, download and update false", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  if (file.exists(indices_path)) file.remove(indices_path)
  expect_snapshot(spectral_indices(download_indices = FALSE, update_cache = FALSE))
})

test_that("no cache, update true", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  if (file.exists(indices_path)) file.remove(indices_path)
  expect_no_warning(spectral_indices(update_cache = TRUE))
})

test_that("no cache, download true", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  if (file.exists(indices_path)) file.remove(indices_path)
  expect_no_warning(spectral_indices(download_indices = TRUE))
})

test_that("no cache, download and update true", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  if (file.exists(indices_path)) file.remove(indices_path)
  expect_no_warning(spectral_indices(download_indices = TRUE, update_cache = TRUE))
})

test_that("new cache", {
  invisible(spectral_indices(update_cache = TRUE))
  expect_no_warning(spectral_indices())
})

test_that("new cache, update false", {
  invisible(spectral_indices(update_cache = TRUE))
  expect_no_warning(spectral_indices(update_cache = FALSE))
})

test_that("new cache, download false", {
  invisible(spectral_indices(update_cache = TRUE))
  expect_no_warning(spectral_indices(download_indices = FALSE))
})

test_that("new cache, download and update false", {
  invisible(spectral_indices(update_cache = TRUE))
  expect_no_warning(spectral_indices(download_indices = FALSE, update_cache = FALSE))
})

test_that("new cache, update true", {
  invisible(spectral_indices(update_cache = TRUE))
  expect_no_warning(spectral_indices(update_cache = TRUE))
})

test_that("new cache, download true", {
  invisible(spectral_indices(update_cache = TRUE))
  expect_no_warning(spectral_indices(download_indices = TRUE))
})

test_that("new cache, download and update true", {
  invisible(spectral_indices(update_cache = TRUE))
  expect_no_warning(spectral_indices(download_indices = TRUE, update_cache = TRUE))
})

test_that("old cache", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  invisible(spectral_indices(update_cache = TRUE))
  Sys.setFileTime(indices_path, "1970-01-01")
  expect_no_warning(spectral_indices())
})

test_that("old cache, update false", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  invisible(spectral_indices(update_cache = TRUE))
  Sys.setFileTime(indices_path, "1970-01-01")
  expect_no_warning(spectral_indices(update_cache = FALSE))
})

test_that("old cache, download false", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  invisible(spectral_indices(update_cache = TRUE))
  Sys.setFileTime(indices_path, "1970-01-01")
  expect_no_warning(spectral_indices(download_indices = FALSE))
})

test_that("old cache, download and update false", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  invisible(spectral_indices(update_cache = TRUE))
  Sys.setFileTime(indices_path, "1970-01-01")
  expect_no_warning(spectral_indices(download_indices = FALSE, update_cache = FALSE))
})

test_that("old cache, update true", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  invisible(spectral_indices(update_cache = TRUE))
  Sys.setFileTime(indices_path, "1970-01-01")
  expect_no_warning(spectral_indices(update_cache = TRUE))
})

test_that("old cache, download true", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  invisible(spectral_indices(update_cache = TRUE))
  Sys.setFileTime(indices_path, "1970-01-01")
  expect_no_warning(spectral_indices(download_indices = TRUE))
})

test_that("old cache, download and update true", {
  indices_path <- file.path(tools::R_user_dir("rsi"), "indices.rda")
  invisible(spectral_indices(update_cache = TRUE))
  Sys.setFileTime(indices_path, "1970-01-01")
  expect_no_warning(spectral_indices(download_indices = TRUE, update_cache = TRUE))
})

test_that("download false and update true", {
  expect_snapshot(spectral_indices(download_indices = FALSE, update_cache = TRUE), error = TRUE)
})
