test_that("known labels accept only 1, 0, or NA", {
  expect_true(validate_known_labels(c(1, 0, NA)))
  expect_error(validate_known_labels(c(1, 2)))
})
