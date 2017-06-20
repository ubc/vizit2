

# Define server logic 
shinyServer(function(input, output, session){
  
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
    
  
  # Get the dataframe for making eiffel tower page plot 
  #reactive_page_tower <- reactive({
    
    # change Page_Category to two levels : module sperator and pages 
    
    # insert module items to dataframe (insert rows)
    
    
    # Change "chapter" to " module split line" for making plot later more clearly
    # page_df <- reactive_page() %>% mutate(Page_Category=replace(Page_Category, Page_Category=="chapter", "module seperator"))
    

    # If the table is not emtpy after filtering
    # if (all(is.na(page_df$Page_Description)) == FALSE){
  
  
    # Create a new index column based on the filtered table
    # page_df["plot_index_asc"] <- seq(nrow(page_df))
    # page_df["plot_index_desc"] <- (max(page_df$plot_index_asc)+1) - page_df$plot_index_asc
  
    # Compute the nactive maximum for plotting later
    # max_pageview <- as.numeric(page_df %>% 
    # filter(Page_Category != "module seperator") %>% 
    # mutate(max_pageview = max(Pageview)) %>% 
    # select(max_pageview) %>% 
    # head(1))

    # Set all chapter nactive value to the nactive maximum to draw equal long module split line later 
    # page_df <- page_df %>% 
    # mutate(Pageview=replace(Pageview, Page_Category=="module seperator", max_pageview)) 

    # Add hovering text: for chapter item, only show item name ; for other items, show detail information 
    # page_df$my_text <- ifelse(page_df$Page_Category == "module seperator",
      #                page_df$Page_Description,
       #               paste(page_df$Page_Description, page_df$Pageview,"views", sep="<br>"))
    #}else{
    
    # If the filtered table is empty, set each column to zero, 
      
    #page_df <- page_df %>% 
     #        mutate(Pageview = "Sorry,no data matched this filtering condition",
      #              plot_index_desc = 0,
       #             my_text = 0,
        #            Page_Category = 0)
        
  #}
  # output the tower table  
  #return(page_df)
  
  #})
  
  
  # Render pages table  
  output$page_summary <- renderDataTable({
    
    page_df <- creat_page_table(page_summary = reactive_page())
    
    datatable(page_df,escape=FALSE) 
    
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
  output$link_summary <- renderDataTable({
    
    link_df <- creat_link_table(link_summary = reactive_link_dat())
    
    datatable(link_df,escape=FALSE)
  
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
  
  
})