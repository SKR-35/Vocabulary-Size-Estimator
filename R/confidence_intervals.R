wilson_interval <- function(successes, n, alpha = 0.05) {
  if (n == 0) return(c(lower = NA_real_, upper = NA_real_))
  z <- stats::qnorm(1 - alpha / 2)
  p <- successes / n
  denom <- 1 + z^2 / n
  center <- (p + z^2 / (2 * n)) / denom
  margin <- (z * sqrt((p * (1 - p) / n) + (z^2 / (4 * n^2)))) / denom
  c(lower = max(0, center - margin), upper = min(1, center + margin))
}
