mod_upload_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h3("Frequency list"),
    shiny::fluidRow(
      shiny::column(
        4,
        shiny::wellPanel(
          shiny::h4("How to read this page"),
          shiny::p("The app starts with the default frequency list from data/raw when it is available."),
          shiny::tags$ul(
            shiny::tags$li("Use rank/index for word order: 1 is the most frequent word."),
            shiny::tags$li("Use word for the vocabulary item."),
            shiny::tags$li("Use frequency for the raw count."),
            shiny::tags$li("Upload another CSV only when you want to test another language or list.")
          ),
          shiny::p(shiny::strong("Supported default filenames:")),
          shiny::code("data/raw/raw_Polish.csv"), shiny::br(),
          shiny::code("data/raw/raw-Polish.csv")
        )
      ),
      shiny::column(
        8,
        shiny::fileInput(ns("freq_file"), "Browse / upload another frequency CSV", accept = ".csv"),
        shiny::uiOutput(ns("source_note")),
        shiny::helpText("Required columns: rank/index, word, frequency/freq/count."),
        DT::DTOutput(ns("preview"))
      )
    )
  )
}

mod_upload_server <- function(id) {
  shiny::moduleServer(id, function(input, output, session) {
    default_paths <- c(
      file.path("data", "raw", "raw_Polish.csv"),
      file.path("data", "raw", "raw-Polish.csv"),
      file.path("inst", "extdata", "polish_frequency_demo.csv")
    )

    selected_default <- shiny::reactive({
      existing <- default_paths[file.exists(default_paths)]
      if (length(existing) > 0) existing[[1]] else system.file("extdata", "polish_frequency_demo.csv", package = "")
    })

    freq_source <- shiny::reactive({
      if (is.null(input$freq_file)) selected_default() else input$freq_file$datapath
    })

    freq <- shiny::reactive({
      load_frequency_csv(freq_source())
    })

    output$source_note <- shiny::renderUI({
      if (is.null(input$freq_file)) {
        shiny::div(
          class = "alert alert-info",
          shiny::strong("Using default file: "),
          shiny::code(normalizePath(selected_default(), winslash = "/", mustWork = FALSE))
        )
      } else {
        shiny::div(
          class = "alert alert-success",
          shiny::strong("Using uploaded file: "),
          input$freq_file$name
        )
      }
    })

    output$preview <- DT::renderDT({
      DT::datatable(utils::head(freq(), 20), options = list(pageLength = 10, scrollX = TRUE))
    })

    freq
  })
}
