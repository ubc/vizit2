overviewModule <- function(input, output, session) {
  
  

  
  
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
   
  
  
  
  
   ##################################################
   ############        Tower  Plot      ############# 
   ##################################################
  
   # Filter student demographic 
   filtered_tower_engage <- reactive({
  
   
       tower_engage <- filter_demographics_overview(tower_engage, 
                                           gender = input$gender, 
                                           mode = input$mode,
                                           activity_level = input$activity_level)
  
     
       # Summarize how many learners engaged with each course item
       tower_engage <- get_nactive(detail_df = tower_engage)
       
       return(tower_engage)
       
   
   })
   
   # Filter chapter 
   filtered_tower_item <- reactive({
   
       tower_item <- filter_chapter_overview(input_df = tower_item_new,module = input$module)
   
       return(tower_item)
   
   })
   
   
  # Join engagement dataframe and item dataframe together 
  reactive_tower_df <- reactive({ 
    
        
       tower_df <- join_engagement_item(filtered_engagement = filtered_tower_engage(),
                                        filtered_item = filtered_tower_item())
    
       return(tower_df)
   
  })
  
  
  
  # Compute the number of filtered student who engaged with the filtered module
  reactive_student_num <- reactive({
  
       student_num <- get_module_nactive(tower_df = reactive_tower_df())
       return(student_num)
    
    
  })
  
  # Render the number of student count
  output$student_count <- renderText({
                        paste0(reactive_student_num())
  })
  
  
  
  # Make tower plot visualization
  output$tower_plot <- plotly::renderPlotly ({
    
         make_engagement_eiffel_tower(reactive_tower_df())
    
})
  
  output$df <- renderDataTable(reactive_tower_df())

  
}