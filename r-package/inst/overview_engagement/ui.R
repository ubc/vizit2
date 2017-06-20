# Define UI for the application
shinyUI(fluidPage(
          
          # Add filtering panel       
          fluidRow(
            bsCollapse(id='demo_dropdown_collapse', multiple=TRUE, open = "Apply filters",
                               bsCollapsePanel("Apply filters",   
                               splitLayout(
                                     cellWidths = c("20%", "20%", "20%", "20%", "10%", "10%", "0%"),
                                 
                                      
                                      
                                      # Add 4 select boxes
                                      selectInput("activity_level",
                                                "Activity Level:",
                                               choices = c("All",
                                                             "Under 30 mins" = "under_30_min",
                                                             "30 mins to 5 hrs" = "30_min_to_5_hr",
                                                             "Over 5 hrs" = "over_5_hr"),
                                                            selected = "All"),
                                      selectInput("gender",
                                                 "Gender:",
                                                 choices = c("All",
                                                            "Male" = "male",
                                                            "Female" = "female",
                                                            "Other" = "other"),
                                                             selected = "All"),
                                 
                                 
                                      selectInput("mode",
                                                "Registration Status: ",
                                                choices = c("All",
                                                            "Verified" = "verified",
                                                            "Audit" = "audit"),
                                                            selected = "All"), 
                                 
                                      selectInput("module",
                                                  "Module:",
                                                   choices = append("All",chap_name[-1]), 
                                                   selected = "All"),
                                 
                                      
                                        
                                    # Add filtering reset button here
                                    column(width = 1.2,
                                                       
                                            # Right-align the text showing the author/viewer counts.
                                            tags$head(tags$style(HTML("#student_count {
                                                                                 text-align: right;
                                                                                 }
                                                                                 div.box-header {
                                                                                 text-align: right;
                                                                                 }
                                                                                 "))),
                                                       
                                            
                                            h5(textOutput("student_count"))
                                                        
                                                ),
                                                
                                     h3(actionButton("reset_filters", "Reset"),align="center"),
                                                
                                     tags$head(tags$style(HTML("
                                                                        .shiny-split-layout > div {
                                                                          overflow: visible;
                                                                          }
                                                                          ")))
                                    
                                    ),style = "primary"))),
          
          # Add effiel tower panel
          fluidRow(
                 bsCollapse(id="effiel_towerplot", multiple=TRUE,open = "How many student engaged with each course element?",
                 bsCollapsePanel("How many student engaged with each course element?",
                                 h4("Hover your mouse on each bar below for further details"),
                                 plotlyOutput("tower_plot",height='800px'),
                                 
                                 style='primary
                   ')))
          
          
          
))
        
