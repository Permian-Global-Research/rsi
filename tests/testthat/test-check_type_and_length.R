test_that("check_type_and_length works", {
  expect_true(check_type_and_length())
  expect_error(
    check_type_and_length(2),
    class = "rsi_unnamed_check_args"
  )
  f1 <- function(x = 2L) {
    check_type_and_length(x = character(1))
  }
  expect_error(
    f1(),
    class = "rsi_incorrect_type_or_length"
  )
})

test_that("integers are valid numerics", {
  f1 <- function(x = 2L) {
    check_type_and_length(x = numeric(1))
  }
  expect_true(f1())
})

test_that("integer-ish are valid integers", {
  f1 <- function(x = 2) {
    check_type_and_length(x = integer(1))
  }
  expect_true(f1())
})
