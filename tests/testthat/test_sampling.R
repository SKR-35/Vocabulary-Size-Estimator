test_that("sample allocation sums to requested sample size", {
  allocation <- allocate_sample(120)
  expect_equal(sum(allocation$sample_n), 120)
})

test_that("stratified sample returns known column", {
  df <- data.frame(rank = 1:50000, word = paste0("w", 1:50000), frequency = rev(1:50000))
  s <- stratified_sample_words(df, sample_size = 60, seed = 1)
  expect_true("known" %in% names(s))
  expect_equal(nrow(s), 60)
})
