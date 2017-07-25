# Define the server logic.
shinyServer(function(input, output, session) {

  requested_dashboard <- reactive({
    query <- parseQueryString(session$clientData$url_search)

    if ("dash" %in% names(query)) {
      query$dash
    } else {
      "general"
    }
  })

  observe({run_dashboard_server(requested_dashboard())})

  output$chosenUI <- renderUI({
    run_dashboard_ui(requested_dashboard())
  })

})