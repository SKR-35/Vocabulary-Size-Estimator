mod_milestones_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h4("Coverage milestones"),
    DT::DTOutput(ns("milestones"))
  )
}

mod_milestones_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    output$milestones <- DT::renderDT({
      m <- default_milestones()
      m$coverage_label <- paste0(round(m$coverage * 100), "%")
      DT::datatable(m, options = list(pageLength = 8, searching = FALSE))
    })
  })
}
