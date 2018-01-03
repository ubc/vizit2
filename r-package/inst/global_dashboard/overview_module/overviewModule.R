overviewModule <- function(input, output, session) {

  # Import requested course
  requested_course <- reactive({
    query <- parseQueryString(session$clientData$url_search)

    if ("course" %in% names(query)) {
      get_unhashed_course(query$course,
                          read_csv("../../inst/data/.hashed_courses.csv"))
    } else {
      "no_course_selected"
    }
  })


  # Import clean overview dashboard data
  root <- "../../inst/data/"
  result_root <- "../../inst/results/"

  tower_item <- reactiveFileReader(10000,
                session,
                paste0(root, requested_course(), "/tower_item.csv"),
                read_csv)


  tower_engage <- reactiveFileReader(10000,
                session,
                paste0(root, requested_course(), "/tower_engage.csv"),
                read_csv)

   # Create module name vector for module filtering

  reactive_get_module_vector <- reactive({
    validate(need(try(nrow(tower_item()) > 0), "No modules found."))
    get_module_vector(item_df = tower_item())[-1]
  })

   output$chap_name_overview <- renderUI({

                        ns <- NS("overviewID")

                        selectInput(ns("module"),
                                    "Module:",
                                    choices = append("All", reactive_get_module_vector()),
                                    selected = "All")
    })



  # Obtain user input for filters and selections:
  gender <- reactive({input$gender})
  activity_level <- reactive({input$activity_level})
  mode <- reactive({input$mode})
  module <- reactive({input$module})



  # Add reset filtering button
  observeEvent(input$reset_filters, autoDestroy = FALSE, {

                        # Update the activity level.
                        activity_level <- reactive({
                                "All"
                        })

                        # Update the gender.
                        gender <- reactive({
                                "All"
                        })

                        # Update the registration status.
                        mode <- reactive({
                                "All"
                        })

                        # Update the category.
                        module <- reactive({
                                "All"
                        })

                        updateSelectInput(session,
                                          inputId = "activity_level",
                                          selected = activity_level()
                        )

                        updateSelectInput(session,
                                          inputId = "gender",
                                          selected = gender()
                        )

                        updateSelectInput(session,
                                          inputId = "mode",
                                          selected = mode()
                        )

                        updateSelectInput(session,
                                          inputId = "module",
                                          selected = module()
                        )

})


  # Create module name column for course items dataframe
  tower_item_new <- reactive({
    validate(need(try(nrow(tower_item()) > 0), "No course components found."))
    create_module_name(item_df = tower_item())
  })

   ##################################################
   ############        Tower  Plot      #############
   ##################################################

   # Filter student demographic
   filtered_tower_engage <- reactive({


       tower_engage <- filter_demographics(tower_engage(),
                                           gender = input$gender,
                                           mode = input$mode,
                                           activity_level = input$activity_level)


       # Summarize how many learners engaged with each course item
       tower_engage <- get_nactive(detail_df = tower_engage)

       return(tower_engage)


   })

   # Filter chapter
   filtered_tower_item <- reactive({
       tower_item <- filter_chapter_overview(input_df = tower_item_new(),
                                             module = input$module)

       return(tower_item)

   })


  # Join engagement dataframe and item dataframe together
  reactive_tower_df <- reactive({
    validate(need(try(nrow(filtered_tower_engage()) > 0), "No engagement found."))
    tower_df <- join_engagement_item(filtered_engagement = filtered_tower_engage(),
                                      filtered_item = filtered_tower_item())
    return(tower_df)

  })

  # Make tower plot visualization
  output$tower_plot <- plotly::renderPlotly ({
    make_engagement_eiffel_tower(reactive_tower_df())

})

  output$df <- renderDataTable(reactive_tower_df())


}
