linkpageModule <- function(input, output, session) {
  
  # Import requested course 
  requested_course <- reactive({
    query <- parseQueryString(session$clientData$url_search)
    
    if ("course" %in% names(query)) {
      get_unhashed_course(query$course, 
                          read_csv("../../data/.hashed_courses.csv"))
    } else {
      "no_course_selected"
    }
  })

  
  # Import clean overview dashboard data
  root <- "../../data/"
  result_root <- "../../results/"

  course_axis_csv <- reactiveFileReader(10000,
                session,
                paste0(root, requested_course(), "/course_axis.csv"),
                read_csv)

  course_axis <- reactive({
    validate(need(try(nrow(course_axis_csv()) > 0), "No course axis found."))
    course_axis_csv()
  })
 
  link_dat_csv <- reactiveFileReader(10000,
                session,
                paste0(root, requested_course(), "/external_link.csv"),
                read_csv)
  
  link_dat <- reactive({
    validate(need(try(nrow(link_dat_csv()) > 0), "No links found."))
    link_dat_csv()
  })
  
  log_dat_csv <- reactiveFileReader(10000,
                session,
                paste0(root, requested_course(), "/page.csv"),
                read_csv)
  
  log_dat <- reactive({
    validate(need(try(nrow(log_dat_csv()) > 0), "No log data found."))
    log_dat_csv()
  })
  
  page_name_csv <- reactiveFileReader(10000,
                session,
                paste0(root, requested_course(), "/page_name.csv"),
                read_csv)
  
  page_name <- reactive({
    validate(need(try(nrow(page_name_csv()) > 0), "No pages found."))
    page_name_csv()
  })
  
 
  # Create module name vector for module filtering
  

  
   output$chap_name_linkpage <- renderUI({
                        
                        ns <- NS("linkpageID")
                        
                        selectInput(ns("module"),
                                    "Module:",
                                    choices = append("All",get_module_vector(item_df = page_name())[-1]),
                                    selected = "All")
    })
  
  
  
 #set all threshold
 student_num_threshold <- 10
 min_click_threshold <- 5
  
  
  
  
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
  
  # Filter student demograpgic
  log_dat_filtered <- reactive({
    
    log_dat <- filter_demographics(log_dat(), gender = input$gender, mode = input$mode,activity_level = input$activity_level)
  
    return(log_dat)
  })
  
 
  
  
  reactive_page <- reactive({
    
  # Compute the pageview of each page
  
  page_student <- get_pageview(filtered_log_df = log_dat_filtered())
  
  # If there are no pages existent after summarization and filtering 
  
  if (nrow(page_student)==0){
  
    all_pages <- data.frame('Warning'= 'No page found.')
    
  
  # If there are pages still existent  
    
  }else{
  
  
  # Join two tables for getting the name of each page, common column is path (two hash strings)
  page_name_mapping <- inner_join(page_student,page_name(),by = "path") 
  
  
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
    

  link_dat <- filter_demographics(link_dat(), gender = input$gender, mode = input$mode,activity_level = input$activity_level)
  
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
        paste0("Click Median: "," ",median(reactive_link_dat()$number_of_click,na.rm = TRUE))
        })
  
  output$pageview_median <- renderText({
        paste0("Pageview Median: "," ",median(reactive_page()$Pageview,na.rm = TRUE))
        })
}