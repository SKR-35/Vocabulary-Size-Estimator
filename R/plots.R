plot_band_estimates <- function(band_estimates) {
  ggplot2::ggplot(band_estimates, ggplot2::aes(x = band_label, y = estimate)) +
    ggplot2::geom_col() +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = estimate_lower, ymax = estimate_upper), width = 0.2) +
    ggplot2::labs(x = "Rank band", y = "Estimated known words", title = "Vocabulary estimate by frequency band") +
    ggplot2::theme_minimal()
}

plot_band_heatmap <- function(band_estimates) {
  plot_df <- band_estimates |>
    dplyr::mutate(
      label = paste0(
        band_label, "\n",
        round(known_ratio * 100), "% known\n",
        round(estimate), " words"
      )
    )

  ggplot2::ggplot(plot_df, ggplot2::aes(x = band_label, y = "Known ratio", fill = known_ratio)) +
    ggplot2::geom_tile(color = "white", linewidth = 1.2) +
    ggplot2::geom_text(ggplot2::aes(label = label), size = 3.6) +
    ggplot2::scale_fill_continuous(labels = scales::percent_format(accuracy = 1), limits = c(0, 1)) +
    ggplot2::labs(x = "Rank band", y = NULL, fill = "Known", title = "Known vocabulary heatmap by frequency band") +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      axis.text.y = ggplot2::element_blank(),
      axis.ticks.y = ggplot2::element_blank(),
      panel.grid = ggplot2::element_blank()
    )
}
