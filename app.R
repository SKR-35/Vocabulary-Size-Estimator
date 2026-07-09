library(shiny)
library(bslib)
library(dplyr)
library(readr)
library(ggplot2)
library(DT)

invisible(lapply(list.files("R", pattern = "\\.R$", full.names = TRUE), source))
invisible(lapply(list.files("modules", pattern = "\\.R$", full.names = TRUE), source))

ui <- page_sidebar(
  title = "Vocabulary Size Estimator",
  sidebar = sidebar(
    p("Estimate passive vocabulary size using stratified samples from a frequency list."),
    p("Use the Sample page to tick words you recognize, then update labels and estimate your vocabulary size."),
    tags$hr(),
    tags$small("Default columns: rank/index, word, frequency.")
  ),
  navset_tab(
    nav_panel("1 Upload", mod_upload_ui("upload")),
    nav_panel("2 Sample & Label", mod_sampling_ui("sampling")),
    nav_panel("3 Estimate", mod_estimation_ui("estimation")),
    nav_panel("4 Milestones", mod_milestones_ui("milestones"))
  )
)

server <- function(input, output, session) {
  freq <- mod_upload_server("upload")
  sample <- mod_sampling_server("sampling", freq)
  mod_estimation_server("estimation", sample)
  mod_milestones_server("milestones")
}

shinyApp(ui, server)
