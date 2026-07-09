normalize_frequency_list <- function(df) {
  names(df) <- tolower(trimws(names(df)))
  names(df) <- gsub("[^a-z0-9_]+", "_", names(df))

  rank_col <- intersect(c("rank", "index", "idx", "position"), names(df))[1]
  word_col <- intersect(c("word", "lemma", "term", "token"), names(df))[1]
  freq_col <- intersect(c("frequency", "freq", "count", "n"), names(df))[1]

  if (is.na(rank_col) || is.na(word_col) || is.na(freq_col)) {
    stop("Input must contain rank/index, word, and frequency/freq/count columns.", call. = FALSE)
  }

  out <- data.frame(
    rank = as.integer(df[[rank_col]]),
    word = as.character(df[[word_col]]),
    frequency = as.numeric(df[[freq_col]]),
    stringsAsFactors = FALSE
  )

  out <- out[!is.na(out$rank) & !is.na(out$word) & !is.na(out$frequency), ]
  out <- out[order(out$rank), ]
  rownames(out) <- NULL
  out
}

load_frequency_csv <- function(path) {
  df <- readr::read_csv(path, show_col_types = FALSE)
  normalize_frequency_list(df)
}
