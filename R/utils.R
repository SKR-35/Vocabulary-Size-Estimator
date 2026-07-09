source_project_files <- function() {
  files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
  invisible(lapply(files, source))
}
