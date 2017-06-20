generalModule <- function(input, output, session) {
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
    filt_gen <- filter_demographics(demo, gender=gender(), activity_level=activity_level(), mode=mode())
    filt_gen
  })
  
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
  
  filtered_students <- reactive({
    filt_segs <- filtered_general()
    num_students <- n_distinct(filt_segs$username)
    return(num_students)
  })
  
  ##########################################################
  ################ Number of students ######################
  ##########################################################
  output$num_students <- renderText({
    paste0(filtered_students(), " students")
  })
}