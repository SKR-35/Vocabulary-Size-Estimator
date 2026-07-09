validate_known_labels <- function(x) {
  valid <- is.na(x) | x %in% c(0, 1)
  if (!all(valid)) stop("Known labels must be 1, 0, or blank/NA.", call. = FALSE)
  TRUE
}
