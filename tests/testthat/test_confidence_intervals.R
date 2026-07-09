test_that("Wilson interval stays inside zero and one", {
  ci <- wilson_interval(5, 10, alpha = 0.05)
  expect_true(ci[["lower"]] >= 0)
  expect_true(ci[["upper"]] <= 1)
})
