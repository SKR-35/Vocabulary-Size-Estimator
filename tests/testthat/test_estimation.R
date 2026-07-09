test_that("estimate is weighted by band size", {
  bands <- default_bands()[1:2, ]
  sample <- data.frame(
    band_id = c(rep(1, 10), rep(2, 10)),
    known = c(rep(1, 10), rep(0, 10))
  )
  est <- estimate_vocabulary(sample, bands = bands)
  expect_equal(est$totals$estimate, bands$band_size[1])
})
