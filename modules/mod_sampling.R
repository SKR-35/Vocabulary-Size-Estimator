mod_sampling_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h3("Sample & label"),
    shiny::fluidRow(
      shiny::column(
        4,
        shiny::wellPanel(
          shiny::h4("How to read this page"),
          shiny::p("This page draws a small test from the full frequency list."),
          shiny::tags$ul(
            shiny::tags$li(shiny::strong("Sample size: "), "how many words you want to test."),
            shiny::tags$li(shiny::strong("Random seed: "), "keeps the random sample reproducible. Same seed + same list = same sample."),
            shiny::tags$li(shiny::strong("Stratified sample: "), "words are drawn from several rank bands, not only from one part of the list."),
            shiny::tags$li(shiny::strong("Known checkbox: "), "tick a word when you recognize its meaning. Unticked means unknown."),
            shiny::tags$li("After labeling, click Update labels / estimates once. This avoids slow table refresh after every tick.")
          )
        )
      ),
      shiny::column(
        8,
        shiny::numericInput(ns("sample_size"), "Sample size", value = 120, min = 30, max = 600, step = 10),
        shiny::numericInput(ns("seed"), "Random seed", value = 42, min = 1, step = 1),
        shiny::actionButton(ns("draw"), "Draw stratified sample"),
        shiny::actionButton(ns("apply_labels"), "Update labels / estimates"),
        shiny::downloadButton(ns("download_sample"), "Download sample CSV"),
        shiny::helpText("Tick words you know. Then click 'Update labels / estimates'.")
      )
    ),
    shiny::br(),
    DT::DTOutput(ns("sample_table"))
  )
}

mod_sampling_server <- function(id, freq_reactive) {
  shiny::moduleServer(id, function(input, output, session) {
    sample_rv <- shiny::reactiveVal(NULL)

    shiny::observeEvent(input$draw, {
      sample_rv(stratified_sample_words(freq_reactive(), input$sample_size, seed = input$seed))
    })

    output$sample_table <- DT::renderDT({
      shiny::req(sample_rv())
      df <- sample_rv()

      display_df <- df
      display_df$row_id <- seq_len(nrow(display_df))
      display_df$known <- sprintf(
        '<input type="checkbox" class="known-checkbox" data-row="%s" %s/>',
        display_df$row_id,
        ifelse(display_df$known == 1, "checked", "")
      )

      row_id_col <- which(names(display_df) == "row_id") - 1
      known_col <- which(names(display_df) == "known") - 1

      DT::datatable(
        display_df,
        escape = FALSE,
        rownames = FALSE,
        selection = "none",
        options = list(
          pageLength = 20,
          lengthMenu = c(20, 50, 100, 120, 300),
          scrollX = TRUE,
          stateSave = TRUE,
          columnDefs = list(
            list(targets = row_id_col, visible = FALSE),
            list(targets = known_col, orderable = FALSE)
          )
        ),
        callback = DT::JS(sprintf(
          "
          var applyButton = $('#%s');

          applyButton.off('click.vocabLabels').on('click.vocabLabels', function() {
            var states = [];

            table.$('input.known-checkbox').each(function() {
              states.push({
                row: parseInt($(this).attr('data-row')),
                value: $(this).is(':checked') ? 1 : 0
              });
            });

            Shiny.setInputValue('%s', {
              states: states,
              nonce: Math.random()
            }, {priority: 'event'});
          });
          ",
          session$ns("apply_labels"),
          session$ns("known_checkbox_state")
        ))
      )
    })

    shiny::observeEvent(input$known_checkbox_state, {
      info <- input$known_checkbox_state
      df <- sample_rv()
      shiny::req(df, info$states)

      for (state in info$states) {
        df$known[state$row] <- as.integer(state$value)
      }

      validate_known_labels(df$known)
      sample_rv(df)
    })

    output$download_sample <- shiny::downloadHandler(
      filename = function() paste0("vocab_sample_", Sys.Date(), ".csv"),
      content = function(file) readr::write_csv(sample_rv(), file)
    )

    sample_rv
  })
}
