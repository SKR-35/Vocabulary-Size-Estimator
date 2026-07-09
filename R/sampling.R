assign_bands <- function(freq_df, bands = default_bands()) {
  freq_df$band_id <- NA_integer_
  freq_df$band_label <- NA_character_

  for (i in seq_len(nrow(bands))) {
    idx <- freq_df$rank >= bands$lower[i] & freq_df$rank <= bands$upper[i]
    freq_df$band_id[idx] <- bands$band_id[i]
    freq_df$band_label[idx] <- bands$band_label[i]
  }

  freq_df[!is.na(freq_df$band_id), ]
}

allocate_sample <- function(sample_size, bands = default_bands()) {
  base <- floor(sample_size / nrow(bands))
  remainder <- sample_size %% nrow(bands)
  n <- rep(base, nrow(bands))
  if (remainder > 0) n[seq_len(remainder)] <- n[seq_len(remainder)] + 1
  transform(bands, sample_n = n)
}

stratified_sample_words <- function(freq_df, sample_size = 120, bands = default_bands(), seed = 42) {
  stopifnot(sample_size > 0)
  set.seed(seed)

  df <- assign_bands(freq_df, bands)
  allocation <- allocate_sample(sample_size, bands)

  samples <- lapply(seq_len(nrow(allocation)), function(i) {
    band_words <- df[df$band_id == allocation$band_id[i], ]
    n_i <- min(allocation$sample_n[i], nrow(band_words))
    if (n_i == 0) return(NULL)
    band_words[sample(seq_len(nrow(band_words)), n_i), ]
  })

  out <- do.call(rbind, samples)
  out$known <- NA_integer_
  rownames(out) <- NULL
  out
}
