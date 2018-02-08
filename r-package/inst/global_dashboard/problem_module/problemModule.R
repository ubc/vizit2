problemModule <- function(input, output, session) {
  requested_course <- reactive({
    query <- parseQueryString(session$clientData$url_search)

    if ("course" %in% names(query)) {
      get_unhashed_course(query$course,
                          read_csv("../../inst/data/.hashed_courses.csv"))
    } else {
      "no_course_selected"
    }
  })

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
    filter_demographics(
      joined_users_problems(),
      gender = gender(),
      activity_level = activity_level(),
      mode = mode()
    )
  })

  filtered_students <- reactive({
    validate(need(try(nrow(filtered_general()) > 0), "No students found."))
    filt_segs <- filtered_general()
    n_distinct(filt_segs$user_id)
  })

  root <- "../../inst/data/"
  result_root <- "../../inst/data/"

  output$moduleSelection <- renderUI({
    ns <- NS("problemID")
    selectInput(ns("chapter"),
                "Module:",
                choices = get_module_options(chap_name()),
                selected = "All")
  })

  temp_raw_problems_tbl <- reactiveFileReader(
    1000,
    session,
    paste0(
      root,
      requested_course(),
      "/demographic_multiple_choice.csv"
    ),
    read_csv
  )

  raw_problems_tbl <- reactive({
    temp_raw_problems_tbl() %>%
      clean_multiple_choice()
  })

  temp_lookup_table <- reactiveFileReader(
    1000,
    session,
    paste0(
      result_root,
      requested_course(),
      "/multiple_choice_questions.json"
    ),
    tidyjson::read_json
  )

  lookup_table <- reactive({
    temp_lookup_table() %>%
      create_question_lookup_from_json()
  })

  problems_tbl <- reactive({
    join_problems_to_lookup(raw_problems_tbl(), lookup_table())
  })

  summarised_scores <- reactive({
    problems_tbl() %>%
      get_mean_scores(lookup_table())
  })

  joined_users_problems <- reactive({
    problems_tbl() %>%
      join_users_problems(summarised_scores())
  })

  chap_name <- reactive({
    validate(need(try(unique(joined_users_problems()$chapter))
                  , "No Chapters Found"))
    chapters <- unique(joined_users_problems()$chapter)
    chapters[!is.na(chapters)]
  })

  extracted_content <- reactiveFileReader(
    1000,
    session,
    paste0(
      root,
      requested_course(),
      "/wrangled_assessment_json_info.csv"
    ),
    read_csv
  )

  extracted_assessment_tbl <- reactiveFileReader(
    1000,
    session,
    paste0(
      root,
      requested_course(),
      "/wrangled_assessment_csv_info.csv"
    ),
    read_csv
  )

  bottom_melted_problems <- reactive({
    
    validate(
      need(
        try(
          (nrow(joined_users_problems())) > 0 
          & (sum(!is.na(joined_users_problems()$problem)) > 0)
      ),
      message = "No multiple choice problems found."
      )
    )
    
    filtered_joined_problems <-
      filter_demographics(
        joined_users_problems(),
        gender = gender(),
        mode = mode(),
        activity_level = activity_level()
      ) %>%
      filter_chapter(chapter())

    bottom_questions <- filtered_joined_problems %>%
      get_mean_scores(lookup_table()) %>%
      get_extreme_summarised_scores(-3)

    aggregate_melted_problems(lookup_table(),
                              filtered_joined_problems,
                              bottom_questions)
  })

  output$bottom_questions <- renderPlot({
    plot_aggregated_problems(bottom_melted_problems())
  })

  reactive_overview <- reactive({
    validate(
      need(
        try(nrow(problems_tbl()) > 0 & sum(!is.na(problems_tbl()$problem)) > 0), 
        "No multiple choice problems found."
      )
    )
    filter_summary_scores <- problems_tbl() %>%
      filter_demographics(
        gender = gender(),
        mode = mode(),
        activity_level = activity_level()
      ) %>%
      get_mean_scores_filterable()

    summarise_scores_by_chapter(filter_summary_scores, lookup_table())
  })

  output$overview_plot <- renderPlot({
    plot_problem_chapter_summaries(reactive_overview())
  })

  reactive_chapter_overview <- reactive({
    validate(need(try(nrow(problems_tbl()) > 0)
                  , "No problems found."))
    filter_joined_users_problems <- problems_tbl() %>%
      filter_demographics(
        gender = gender(),
        mode = mode(),
        activity_level = activity_level()
      )

    chapter_filtered_problems <- filter_joined_users_problems %>%
      filter_chapter(input$chapter)

    final_result <- chapter_filtered_problems %>%
      get_mean_scores_filterable() %>%
      prepare_filterable_problems(lookup_table())
  })

  output$chapter_table <- DT::renderDataTable({
    reactive_chapter_overview()
  })

  reactive_assessment <- reactive({
    validate(need(try(nrow(extracted_assessment_tbl()) > 0)
                  , "No assessments found."))
    extracted_assessment_tbl() %>%
      filter_demographics(
        gender = gender(),
        mode = mode(),
        activity_level = activity_level()
      ) %>%
      join_extracted_assessment_data(extracted_content()) %>%
      summarise_joined_assessment_data()
  })

  output$assessment_plot <- renderPlot({
    plot_assessment(reactive_assessment())
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

      updateSelectInput(session, inputId = "activity_level",
                        selected = activity_level())
      updateSelectInput(session, inputId = "gender", selected = gender())
      updateSelectInput(session, inputId = "mode", selected = mode())
      updateSelectInput(session, inputId = "module", selected = module())
    })
  })
}
