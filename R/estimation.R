estimate_vocabulary <- function(sample_df, bands = default_bands(), alpha = 0.05) {
  if (!all(c("band_id", "known") %in% names(sample_df))) {
    stop("sample_df must contain band_id and known columns.", call. = FALSE)
  }

  rows <- lapply(seq_len(nrow(bands)), function(i) {
    b <- bands[i, ]
    x <- sample_df[sample_df$band_id == b$band_id & sample_df$known %in% c(0, 1), ]
    n <- nrow(x)
    successes <- sum(x$known == 1)
    ratio <- if (n == 0) NA_real_ else successes / n
    ci <- wilson_interval(successes, n, alpha)

    data.frame(
      band_id = b$band_id,
      band_label = b$band_label,
      band_size = b$band_size,
      labeled_n = n,
      known_n = successes,
      known_ratio = ratio,
      ci_lower_ratio = ci[["lower"]],
      ci_upper_ratio = ci[["upper"]],
      estimate = ratio * b$band_size,
      estimate_lower = ci[["lower"]] * b$band_size,
      estimate_upper = ci[["upper"]] * b$band_size
    )
  })

  band_estimates <- do.call(rbind, rows)

  totals <- data.frame(
    band_id = NA_integer_,
    band_label = "Overall",
    band_size = sum(band_estimates$band_size, na.rm = TRUE),
    labeled_n = sum(band_estimates$labeled_n, na.rm = TRUE),
    known_n = sum(band_estimates$known_n, na.rm = TRUE),
    known_ratio = sum(band_estimates$known_n, na.rm = TRUE) / sum(band_estimates$labeled_n, na.rm = TRUE),
    ci_lower_ratio = NA_real_,
    ci_upper_ratio = NA_real_,
    estimate = sum(band_estimates$estimate, na.rm = TRUE),
    estimate_lower = sum(band_estimates$estimate_lower, na.rm = TRUE),
    estimate_upper = sum(band_estimates$estimate_upper, na.rm = TRUE),
    alpha = alpha
  )

  list(bands = band_estimates, totals = totals)
}

estimate_table_with_overall <- function(estimation_result) {
  bands <- estimation_result$bands
  totals <- estimation_result$totals

  totals_for_table <- totals[, names(bands), drop = FALSE]
  rbind(bands, totals_for_table)
}
