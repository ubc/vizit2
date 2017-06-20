shinyServer(function(input, output, session) {

  gender <- reactive({
    input$gender
  })

  activity_level <- reactive({
    input$activity_level
  })

  mode <- reactive({
    input$mode
  })

  chapter <- reactive({
    input$chapter
  })

  filtered_general <- reactive({
    filter_demographics(joined_users_problems,
                        gender=gender(),
                        activity_level=activity_level(),
                        mode=mode())
  })

  filtered_students <- reactive({
    filt_segs <- filtered_general()
    n_distinct(filt_segs$user_id)
  })

  reactive_bottom_melted_problems <- reactive({


    filtered_joined_problems <- filter_demographics(joined_users_problems,
                                                    gender = gender(),
                                                    mode = mode(),
                                                    activity_level = activity_level()) %>%
      filter_chapter(input$chapter)

    bottom_questions <- filtered_joined_problems %>%
      get_mean_scores(lookup_table) %>%
      get_extreme_summarised_scores(-3)

    aggregate_melted_problems(filtered_joined_problems, bottom_questions)


  })

  output$bottom_questions <- renderPlot({

    plot_aggregated_problems(reactive_bottom_melted_problems())

  })

  reactive_overview <- reactive({

    filter_summary_scores <- problems_tbl %>%
      filter_demographics(gender = gender(),
                          mode = mode(),
                          activity_level = activity_level()) %>%
      get_mean_scores_filterable()

    chapter_scores <- summarise_scores_by_chapter(filter_summary_scores, lookup_table)

  })

  output$overview_plot <- renderPlot({

    plot_problem_chapter_summaries(reactive_overview())

  })

  reactive_chapter_overview <- reactive({


    filter_joined_users_problems <- problems_tbl %>%
      filter_demographics(gender = gender(),
                          mode = mode(),
                          activity_level = activity_level())

    chapter_filtered_users_problems <- filter_joined_users_problems %>%
      filter_chapter(input$chapter)

    final_result <- chapter_filtered_users_problems %>%
      get_mean_scores_filterable() %>%
      prepare_filterable_problems(lookup_table)

  })

  output$chapter_table <- DT::renderDataTable({

    reactive_chapter_overview()

  })

  reactive_assessment <- reactive({

    extracted_assessment_tbl %>%
      filter_demographics(gender = gender(),
                          mode = mode(),
                          activity_level = activity_level()) %>%
    join_extracted_assessment_data(extracted_content) %>%
    summarise_joined_assessment_data()


  })

  output$assessment_plot <- renderPlot({

    plot_assessment(reactive_assessment())

  })

  output$num_students <- renderText({
    paste0(filtered_students(), " students")
  })

  observe({
    observeEvent(input$reset_filters, autoDestroy = FALSE, {

      # Update the activity level.
      activity_level <- reactive({
        "all"
      })

      # Update the gender.
      gender <- reactive({
        "all"
      })

      # Update the registration status.
      mode <- reactive({
        "all"
      })

      # Update the category.
      module <- reactive({
        "All"
      })

      updateSelectInput(session,
                        inputId = "activity_level",
                        selected = activity_level())

      updateSelectInput(session,
                        inputId = "gender",
                        selected = gender())

      updateSelectInput(session,
                        inputId = "mode",
                        selected = mode())

      updateSelectInput(session,
                        inputId = "module",
                        selected = module())

    })
  })

})
