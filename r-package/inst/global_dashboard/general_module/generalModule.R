generalModule <- function(input, output, session) {
  root <- "../../inst/data/"

  gender <- reactive({
    input$gender
  })

  activity_level <- reactive({
    input$activity_level
  })

  mode <- reactive({
    input$mode
  })

  filtered_general <- reactive({
    validate(need(try(nrow(demo()) > 0), "No demographics found."))
    filter_demographics(demo(),
                        gender = gender(),
                        activity_level = activity_level(),
                        mode = mode())
  })

  # Obtain requested course to display:
  requested_course <- reactive({
    query <- parseQueryString(session$clientData$url_search)

    if ("course" %in% names(query)) {
      get_unhashed_course(query$course,
                          read_csv("../../inst/data/.hashed_courses.csv"))
    } else {
      "no_course_selected"
    }
  })

  ### Read data frame: ###
  demo <- reactiveFileReader(1000, session, paste0(root, requested_course(),
                                                   "/wrangled_demographics.csv"), read_csv)

  output$loe_demo <- renderPlot({
    # Level of Education:
    loe_df <- get_loe_df(filtered_general())

    # Making plot:
    g <- get_loe_plot(loe_df)

    return(g)
  })

  output$age_demo <- renderPlot({
    # Age:
    age_df <- get_age_df(filtered_general())

    # Making plot:
    g <- get_age_plot(age_df)

    return(g)
  })

  output$continent_demo <- renderPlot({
    # Top number of countries to show:
    top_selection <- 10

    # Get aggregated country dataframe:
    country_df <- get_top_country_df(filtered_general(), top_selection)

    # Making plot:
    g <- get_country_plot(country_df, top_selection)

    return(g)
  })

  output$language_demo <- renderPlot({
    # Top number of languages to show:
    top_selection <- 10

    # Dataframe with student and language code
    language_df <- get_top_language_df(filtered_general(), top_selection)

    # Make plot:
    g <- get_language_plot(language_df, top_selection)

    return(g)

  })

}
