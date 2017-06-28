linkpageModuleUI <- function(id) {
  ns <- NS(id)
  
  # Add filtering panel       
  fluidPage( fluidRow(
                        bsCollapse(id= ns('demo_dropdown_collapse'), multiple=TRUE, open = "Apply filters",
                                    bsCollapsePanel("Apply filters",  
                        splitLayout(cellWidths =  c("17.5%", "17.5%", "17.5%", "17.5%", "15%", "15%", "0%"),
                          
                                  
                                    
                                    
                        # Add filtering 4 select box            
                                    selectInput(ns("activity_level"),
                                                "Activity Level:",
                                                choices = c("All",
                                                            " Under 30 mins" = "under_30_min",
                                                            " 30 mins to 5 hrs" = "30_min_to_5_hr",
                                                            " Over 5 hrs" = "over_5_hr"),
                                                selected = "All"),
                          
                                    selectInput(ns("gender"),
                                                "Gender:",
                                                choices = c("All",
                                                            "Male" = "male",
                                                            "Female" = "female",
                                                            "Other" = "other"),
                                                            selected = "All"),
                          
                                    selectInput(ns("mode"),
                                                "Registration Status:",
                                                choices = c("All",
                                                            "Verified" = "verified",
                                                            "Audit" = "audit"),
                                                selected = "All"),
                                    
                                    htmlOutput(ns("chap_name_linkpage")),
                          
                                    column(width = 1.2,
                                                       
                                                # Add text for showing the click median and pageview median
                                                tags$head(tags$style(HTML("
                                                                                 #category_header, #click_median, #pageview_median {
                                                                                 text-align: center;
                                                                                 }
                                                                                 div.box-header {
                                                                                 text-align: center;
                                                                                 }
                                                                                 "))),
                                                       
                                                       
                                                       h6(textOutput(ns("click_median"))),
                                                       h6(textOutput(ns("pageview_median")))
                                                        
),
                          
                          
                                    # Add filtering reset button
                                    h3(actionButton(ns("reset_filters"), "Reset"),align="center"),
                                    
                                   
                                    tags$head(tags$style(HTML("
                                                              .shiny-split-layout > div {
                                                              overflow: visible;
                                                              }
                                                              ")))
                                    )
                                ,style = "primary"))),
          
          # Display link summary table
          fluidRow(
                 bsCollapse(id= ns("link"), multiple=TRUE,
                 bsCollapsePanel("External Link Summary",
                                 h5(strong(" Click 'Number of Click' header below to change link sort order")),
                                 br(),
                                 DT::dataTableOutput(ns("link_summary")),
                                 style='primary')
                                 )),
          
          
          
          
          
          
          # Display page summary table
          fluidRow(
                 bsCollapse(id= ns("page"), multiple=TRUE,
                 bsCollapsePanel("Non-video/Non-problem Page Summary",
                                 h5(strong("Click 'Pageview' header below to quickly find the most / least viewed pages")),
                                 DT::dataTableOutput(ns("page_summary")),
                                 br(),
                                 style='primary')
                                 ))
          
          
                    )

}