linkpageModule <- function(input, output, session) {
  
  # Obtain user input for filters and selections:
  gender <- reactive({input$gender})
  activity_level <- reactive({input$activity_level})
  mode <- reactive({input$mode})
  module <- reactive({input$module})
  
  # Add reset filtering function
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
  
  
  
  
  
  
  #############################################################
  ############        Page summary table            ########### 
  ############################################################# 
  
  reactive_page <- reactive({
    
    
  # Filter student demograpgic
  log_dat <- filter_demographics_overview(log_dat, gender = input$gender, mode = input$mode,activity_level = input$activity_level)

    
  # Compute the pageview of each page
  
  page_student <- get_pageview(filtered_log_df = log_dat)
  
  # If there are no pages existent after summarization and filtering 
  
  if (nrow(page_student)==0){
  
    all_pages <- data.frame('Warning'= 'No page found.')
    
  
  # If there are pages still existent  
    
  }else{
  
  
  # Join two tables for getting the name of each page, common column is path (two hash strings)
  page_name_mapping <- inner_join(page_student,page_name,by = "path") 
  
  
  ## Filter page by chapter
  page_name_mapping <- filter_chapter_linkpage(page_name_mapping,module = input$module)
  

  # Get page name
  each_page <- get_page_name(page_name_df = page_name_mapping)
    
  
  # Remove duplicated name for each page
  all_pages <- get_unique_page_name(each_page_df = each_page)

  
}
    
   
  return(all_pages)
  
      
  
  })
    
  
  # Render pages table  
  output$page_summary <- DT::renderDataTable({
    
    page_df <- creat_page_table(page_summary = reactive_page())
    
    DT::datatable(page_df,escape=FALSE) 
    
  })
  
  ############################################################### 
  ############  external link summary table         ############# 
  ############################################################### 
  
  # Filter demograhics
  reactive_link_dat <- reactive({
    

  link_dat <- filter_demographics_overview(link_dat, gender = input$gender, mode = input$mode,activity_level = input$activity_level)
  
  ## Filter chapter
  link_dat <- filter_chapter_linkpage(link_dat,module = input$module)

  # compute the total click of each external link  
  get_click_per_link(link_df = link_dat)
   
  })
  
  
  # Render link summary table
  output$link_summary <- DT::renderDataTable({
    
    link_df <- creat_link_table(link_summary = reactive_link_dat())
    
    DT::datatable(link_df,escape=FALSE)
  
})
  
  #########################################################
  ################ median statistic  ######################
  #########################################################
  
  output$click_median <- renderText({
        paste0("Click Median:",median(reactive_link_dat()$number_of_click,na.rm = TRUE))
        })
  
  output$pageview_median <- renderText({
        paste0("Pageview Median:",median(reactive_page()$Pageview,na.rm = TRUE))
        })
  
  
  
  
 
  
}