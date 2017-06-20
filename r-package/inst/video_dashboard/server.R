# Define the server logic.
shinyServer(function(input, output, session) {
  
  # Obtain user input for filters and selections:
  gender <- reactive({input$gender})
  activity_level <- reactive({input$activity_level})
  mode <- reactive({input$mode})
  module <- reactive({input$module})
  top_selection <- reactive({as.integer(input$top_selection)})
  
  #### Filtering for video heat maps: ###
  filtered_segments <- reactive({
    # Filter students by selected demographics
    filt_segs <- filter_demographics(tidy_segment_df, gender = gender(), activity_level = activity_level(), mode = mode(), module = module())

    # Aggregate data by video (lose student level information)
    aggregate_segment_df <- get_aggregated_df(filt_segs, top_selection())

    return(aggregate_segment_df)
  })
  
  #### Filtering for number of students: ###
  filtered_students <- reactive({
    # Filter students by selected demographics 
    filt_segs <- filter_demographics(tidy_segment_df, gender = gender(), activity_level = activity_level(), mode = mode(), module = module())
    
    # Get number of filtered students
    num_students <- length(unique(filt_segs$username))
    
    return(num_students)
  })
  
  ### Filtering module markers ###
  filtered_ch_markers <- reactive({
    # Filter students by selected demographics
    filt_segs <- filter_demographics(tidy_segment_df, gender = gender(), activity_level = activity_level(), mode = mode(), module = module())
    
    # Obtain module markers for videos:
    ch_markers <- get_ch_markers(filt_segs)
    
    return(ch_markers)
  })
  
  ### Filtering for summary table ###
  filtered_table <- reactive({
    # Filter students by selected demographics
    filt_segs <- filter_demographics(tidy_segment_df, gender = gender(), activity_level = activity_level(), mode = mode(), module = module())
    
    # Obtain length of videos
    vid_lengths <- get_video_lengths(filt_segs)
    
    # Obtain filtered summary table
    summary_tbl <- get_summary_table(filtered_segments(), vid_lengths)
    
    return(summary_tbl)
  })
  
  ### Resetting filters ###
  observe({
    observeEvent(input$reset_filters, autoDestroy = FALSE, {
      # Update the activity level.
      activity_level <- reactive({"all"})
      
      # Update the gender.
      gender <- reactive({"all"})
      
      # Update the registration status.
      mode <- reactive({"all"})
      
      # Update the module.
      module <- reactive({"All"})
      
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
  
  ##############################################################################################
  ########################  Which of my videos is viewed the most?  ############################
  ##############################################################################################
  output$most_viewed <- plotly::renderPlotly({
    g <- get_video_comparison_plot(filtered_segments(), module(), filtered_ch_markers())
  
    plotly::ggplotly(g, tooltip='text') 
  })
  
  ##############################################################################################
  #################  Which part of my videos are being watched the most?  ######################
  ##############################################################################################
  output$video_heatmap <- plotly::renderPlotly({
    g <- get_segment_comparison_plot(filtered_segments(), module(), filtered_ch_markers())
    
    plotly::ggplotly(g, tooltip='text') 
  })
  
  ##############################################################################################
  ######################  Which part of my videos is the hottest?  ############################
  ##############################################################################################
  output$hottest <- plotly::renderPlotly({
    g <- get_top_hotspots_plot(filtered_segments(), module(), filtered_ch_markers())
    
    plotly::ggplotly(g, tooltip='text') 
  })
  
  ################################################
  ################ Overview ######################
  ################################################
  output$summary_tbl <- renderDataTable({
    summary_tbl <- filtered_table()
    DT::datatable(summary_tbl, escape=FALSE)
  })
  
  ##########################################################
  ################ Number of students ######################
  ##########################################################
  output$num_students <- renderText({
    paste0(filtered_students(), " students")
  })
  
})