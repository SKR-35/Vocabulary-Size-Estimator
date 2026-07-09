mod_estimation_ui <- function(id) {
  ns <- shiny::NS(id)
  shiny::tagList(
    shiny::h3("Estimate"),
    shiny::fluidRow(
      shiny::column(
        4,
        shiny::wellPanel(
          shiny::h4("How to read this page"),
          shiny::p("This page turns your known/unknown labels into a passive vocabulary estimate."),
          shiny::tags$ul(
            shiny::tags$li(shiny::strong("Alpha: "), "the error level. Alpha 0.05 means a 95% confidence interval."),
            shiny::tags$li(shiny::strong("Confidence interval: "), "a plausible lower and upper range, not a guarantee."),
            shiny::tags$li(shiny::strong("Wilson interval: "), "a stable way to estimate uncertainty for yes/no samples, especially when the sample is small."),
            shiny::tags$li(shiny::strong("Overall estimate: "), "the sum of estimated known words across all rank bands."),
            shiny::tags$li("Small samples can produce wide intervals. Use a larger sample size for a narrower estimate.")
          )
        )
      ),
      shiny::column(
        8,
        shiny::selectInput(ns("alpha"), "Alpha", choices = c("0.10 = 90% interval" = 0.10, "0.05 = 95% interval" = 0.05, "0.01 = 99% interval" = 0.01), selected = 0.05),
        shiny::actionButton(ns("estimate"), "Estimate vocabulary"),
        shiny::verbatimTextOutput(ns("summary"))
      )
    ),
    DT::DTOutput(ns("overall_table")),
    shiny::plotOutput(ns("band_heatmap"), height = "220px"),
    shiny::plotOutput(ns("band_plot"), height = "320px"),
    DT::DTOutput(ns("estimate_table")),
    shiny::downloadButton(ns("download_estimates"), "Download estimates CSV")
  )
}

mod_estimation_server <- function(id, sample_reactive) {
  shiny::moduleServer(id, function(input, output, session) {
    est_rv <- shiny::reactiveVal(NULL)

    shiny::observeEvent(input$estimate, {
      shiny::req(sample_reactive())
      est_rv(estimate_vocabulary(sample_reactive(), alpha = as.numeric(input$alpha)))
    })

    output$summary <- shiny::renderPrint({
      shiny::req(est_rv())
      t <- est_rv()$totals
      conf <- round((1 - t$alpha) * 100)
      cat("Estimated passive vocabulary:", round(t$estimate), "words\n")
      cat(conf, "% interval:", round(t$estimate_lower), "-", round(t$estimate_upper), "words\n")
      cat("Labeled sample size:", t$labeled_n, "\n")
    })

    output$overall_table <- DT::renderDT({
      shiny::req(est_rv())
      DT::datatable(
        est_rv()$totals[, c("band_label", "band_size", "labeled_n", "known_n", "known_ratio", "estimate", "estimate_lower", "estimate_upper")],
        rownames = FALSE,
        options = list(dom = "t", pageLength = 1)
      ) |>
        DT::formatRound(c("known_ratio", "estimate", "estimate_lower", "estimate_upper"), digits = 2)
    })

    output$band_heatmap <- shiny::renderPlot({
      shiny::req(est_rv())
      plot_band_heatmap(est_rv()$bands)
    })

    output$band_plot <- shiny::renderPlot({
      shiny::req(est_rv())
      plot_band_estimates(est_rv()$bands)
    })

    output$estimate_table <- DT::renderDT({
      shiny::req(est_rv())
      DT::datatable(estimate_table_with_overall(est_rv()), options = list(pageLength = 10, scrollX = TRUE)) |>
        DT::formatRound(c("known_ratio", "ci_lower_ratio", "ci_upper_ratio", "estimate", "estimate_lower", "estimate_upper"), digits = 2)
    })

    output$download_estimates <- shiny::downloadHandler(
      filename = function() paste0("vocab_estimates_", Sys.Date(), ".csv"),
      content = function(file) readr::write_csv(estimate_table_with_overall(est_rv()), file)
    )

    est_rv
  })
}
