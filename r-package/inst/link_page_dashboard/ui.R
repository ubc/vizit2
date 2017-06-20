


# Define UI for the application
shinyUI(
        
        fluidPage(
                # Add filtering panel
                fluidRow(
                        bsCollapse( id='demo_dropdown_collapse', multiple=TRUE, open = "Apply filters",
                                    bsCollapsePanel("Apply filters",  
                        splitLayout(cellWidths =  c("20%", "20%", "20%", "20%", "15%", "5%", "0%"),
                          
                                  
                                    
                                    
                        # Add filtering 4 select box            
                                    selectInput("activity_level",
                                                "Activity Level:",
                                                choices = c("All",
                                                            " Under 30 mins" = "under_30_min",
                                                            " 30 mins to 5 hrs" = "30_min_to_5_hr",
                                                            " Over 5 hrs" = "over_5_hr"),
                                                selected = "All"),
                          
                                    selectInput("gender",
                                                "Gender:",
                                                choices = c("All",
                                                            "Male" = "male",
                                                            "Female" = "female",
                                                            "Other" = "other"),
                                                            selected = "All"),
                          
                                    selectInput("mode",
                                                "Registration Status:",
                                                choices = c("All",
                                                            "Verified" = "verified",
                                                            "Audit" = "audit"),
                                                selected = "All"),
                                    
                                   selectInput("module",
                                               "Module:",
                                               choices = append("All",chap_name), 
                                               selected = "All"),
                                    column(width = 1.2,
                                                       
                                                       # Add text for showing the click median and pageview median
                                                       tags$head(tags$style(HTML("
                                                                                 #category_header, #click_median, #pageview_median {
                                                                                 text-align: left;
                                                                                 }
                                                                                 div.box-header {
                                                                                 text-align: left;
                                                                                 }
                                                                                 "))),
                                                       
                                                       
                                                       h6(textOutput("click_median")),
                                                       h6(textOutput("pageview_median"))
                                                        
),
                          
                          
                                    # Add filtering reset button
                                    h3(actionButton("reset_filters", "Reset"),align="center"),
                                    
                                   
                                    tags$head(tags$style(HTML("
                                                              .shiny-split-layout > div {
                                                              overflow: visible;
                                                              }
                                                              ")))
                                    )
                                ,style = "primary"))),
          
          # Display link summary table
          fluidRow(
                 bsCollapse(id="link", multiple=TRUE,
                 bsCollapsePanel("External Link Summary",
                                 h5(strong(" Click 'Number of Click' header below to change link sort order")),
                                 br(),
                                 DT::dataTableOutput("link_summary"),
                                 style='primary')
                                 )),
          
          
          
          
          
          
          # Display page summary table
          fluidRow(
                 bsCollapse(id="page", multiple=TRUE,
                 bsCollapsePanel("Non-video/Non-problem Page Summary",
                                 h5(strong("Click 'Pageview' header below to quickly find the most / least viewed pages")),
                                 DT::dataTableOutput("page_summary"),
                                 br(),
                                 style='primary')
                                 ))
          
          
          
          
          
          
          
          
          
                     
))
        
