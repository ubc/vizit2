videoModule <- function(input, output, session)
{

  root <- "../../inst/data/"

  # Obtain user input for filters and selections:
  gender <- reactive({
    input$gender
  })
  activity_level <- reactive({
    input$activity_level
  })
  mode <- reactive({
    input$mode
  })
  module <- reactive({
    if (is.null(input$module))
    {
      "All"
    } else
    {
      input$module
    }
  })
  top_selection <- reactive({
    as.integer(input$top_selection)
  })
  top_selection2 <- reactive({
    as.integer(input$top_selection2)
  })
  daterange <- reactive({
    input$dateRange
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
  tidy_segment_df <- reactiveFileReader(1000,
                                        session,
                                        paste0(root,
                                               requested_course(),
                                               "/wrangled_video_heat.csv"), 
                                        read_csv)
  
  ### Read data for time plot: ###
  events_df <- reactiveFileReader(1000,
                                  session,
                                  paste0(root,
                                         requested_course(),
                                         "/generalized_video_heat.csv"), 
                                  read_csv)
  
  ### Read data for time plot: ###
  axis_df <- reactiveFileReader(1000,
                                  session,
                                  paste0(root,
                                         requested_course(),
                                         "/generalized_video_axis.csv"), 
                                  read_csv)
  
  ### Get Chap Name ###
  chap_name <- reactive({
    validate(need(try(nrow(tidy_segment_df()) > 0), "No chapters found."))
    chap_name <- tidy_segment_df() %>% 
      group_by(chapter) %>% 
      summarise(index_chapter = unique(index_chapter)) %>% 
      arrange(index_chapter) %>% 
      select(chapter)
    
    chap_name <- chap_name$chapter
    return(chap_name)
  })

  ### Get Module selection ###
  output$moduleSelection <- renderUI({
    ns <- NS("videoID")

    selectInput(ns("module"), 
                "Module:", 
                choices = get_module_options(chap_name()),
                selected = "All")
  })

  #### Filtering for video heat maps: ###
  filtered_segments <- reactive({
    validate(need(try(nrow(tidy_segment_df()) > 0), "No segments found."))
    
    # Filter students by selected demographics
    filt_segs <- filter_demographics(tidy_segment_df(),
                                     gender = gender(),
                                     activity_level = activity_level(),
                                     mode = mode())
    filt_segs <- filter_chapter(filt_segs, chapter = module())

    # Aggregate data by video (lose student level information)
    aggregate_segment_df <- get_aggregated_df(filt_segs, 
                                              top_selection())
    
    return(aggregate_segment_df)
  })
  
  #### Filtering for video time plot: ###
  filtered_events <- reactive({
    
    validate(need(try(nrow(tidy_segment_df()) > 0), "No segments found."))
    
    # Filter students by selected demographics
    filt_events <- filter_demographics(events_df(),
                                     gender = gender(),
                                     activity_level = activity_level(),
                                     mode = mode()) %>% 
      dplyr::left_join(axis_df())
    
    # Filter to select only the requested chapters.
    filt_events <- filt_events %>% 
      dplyr::rename(chapter = chapter_name) %>% 
      filter_chapter(chapter = module())
    
    # Filter to select only the requested date range.
    filt_events <- filt_events %>% 
      filter(as.Date(time) >= daterange()[1] & as.Date(time) <= daterange()[2])
    
    return(filt_events)
    
  })

  #### Filtering for number of students: ###
  filtered_students <- reactive({
    validate(need(try(nrow(tidy_segment_df()) > 0), "No students found."))
    # Filter students by selected demographics
    filt_segs <- filter_demographics(tidy_segment_df(), 
                                     gender = gender(),
                                     activity_level = activity_level(), 
                                     mode = mode())
    filt_segs <- filter_chapter(filt_segs, chapter = module())

    # Get number of filtered students
    num_students <- length(unique(filt_segs$user_id))

    return(num_students)
  })

  ### Filtering module markers ###
  filtered_ch_markers <- reactive({
    # Filter students by selected demographics
    filt_segs <- filter_demographics(tidy_segment_df(), 
                                     gender = gender(),
                                     activity_level = activity_level(), 
                                     mode = mode())
    filt_segs <- filter_chapter(filt_segs, chapter = module())

    # Obtain module markers for videos:
    ch_markers <- get_ch_markers(filt_segs)

    return(ch_markers)
  })

  ### Filtering for summary table ###
  filtered_table <- reactive({
    validate(need(try(nrow(tidy_segment_df()) > 0), "No videos found."))
    # Filter students by selected demographics
    filt_segs <- filter_demographics(tidy_segment_df(), 
                                     gender = gender(),
                                     activity_level = activity_level(), 
                                     mode = mode())
    filt_segs <- filter_chapter(filt_segs, chapter = module())

    # Obtain length of videos
    vid_lengths <- get_video_lengths(filt_segs)

    # Obtain average time spent on video
    avg_time_spent <- get_avg_time_spent(filt_segs)

    # Obtain filtered summary table
    summary_tbl <- get_summary_table(filtered_segments(), 
                                     vid_lengths,
                                     avg_time_spent)

    return(summary_tbl)
  })

  ### Resetting filters ###
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

      # Update the module.
      module <- reactive({
        "All"
      })

      updateSelectInput(session, inputId = "activity_level", 
                        selected = activity_level())

      updateSelectInput(session, inputId = "gender", 
                        selected = gender())

      updateSelectInput(session, inputId = "mode", 
                        selected = mode())

      updateSelectInput(session, inputId = "module", 
                        selected = module())

    })
  })

  ### Which of my videos is viewed the most? ###
  output$most_viewed <- plotly::renderPlotly({
    g <- get_video_comparison_plot(filtered_segments(), 
                                   module(), 
                                   filtered_ch_markers())

    plotly::ggplotly(g, tooltip = "text") %>% 
      plotly::config(displayModeBar = FALSE)
  })

  ### Which part of my videos are being watched the most? ###
  output$video_heatmap <- plotly::renderPlotly({
    g <- get_segment_comparison_plot(filtered_segments(), module(),
                                     filtered_ch_markers())

    plotly::ggplotly(g, tooltip = "text") %>% 
      plotly::config(displayModeBar = FALSE)
  })

  ### Which part of my videos is the surprising?###
  output$surprising <- plotly::renderPlotly({
    g <- get_high_low_plot(filtered_segments(), 
                           module(), 
                           filtered_ch_markers())

    plotly::ggplotly(g, tooltip = "text") %>% 
      plotly::config(displayModeBar = FALSE)
  })
  
  ### When have students viewed each video?
  output$across_time <- plotly::renderPlotly({
    g <- make_video_time_plot(filtered_events(),
                              axis_df(),
                              module(),
                              filtered_ch_markers())
    
    plotly::ggplotly(g, tooltip = "text") %>% 
      plotly::config(displayModeBar = FALSE)
  })

  # Overview
  output$summary_tbl <- renderDataTable({
    summary_tab <- filtered_table()
    return(summary_tab)
  }, options = list(pageLength = 10))

  ### Number of students ###
  output$num_students <- renderText({
    paste0(filtered_students(), " students")
  })
}
