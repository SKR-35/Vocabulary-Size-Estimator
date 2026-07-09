default_bands <- function() {
  data.frame(
    band_id = 1:6,
    lower = c(1, 1001, 3001, 5001, 10001, 20001),
    upper = c(1000, 3000, 5000, 10000, 20000, 50000),
    stringsAsFactors = FALSE
  ) |>
    transform(
      band_label = paste0(lower, "-", upper),
      band_size = upper - lower + 1
    )
}

default_milestones <- function() {
  data.frame(
    rank = c(75, 200, 524, 1257, 2925, 7444, 13374, 25508),
    coverage = c(0.40, 0.50, 0.60, 0.70, 0.80, 0.90, 0.95, 0.99)
  )
}
