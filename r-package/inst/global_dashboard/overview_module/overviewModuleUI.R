overviewModuleUI <- function(id) {
  ns <- NS(id)
  
  # Add filtering panel       
  fluidPage(
    
    fluidRow(
      tags$p("Welcome! In this course section, you can view a sequence of 
             dashboards that show how students are engaging with various
             elements of your course. For example, on this dashboard, you can 
             see how many learners accessed each video and problem page in your 
             course.<br><br>As you proceed to further dashboards, you will see
             information about 1) the demographics of your learners, 2) the
             pages and links that learners use most, 3) discussion forum
             activity, 4) success rates on multiple-choice problems (if
             applicable), and 5) engagement with course videos.")
    ),
    
    fluidRow(
            bsCollapse(id= ns('demo_dropdown_collapse'), multiple=TRUE, open = "Apply filters",
                               bsCollapsePanel("Apply filters",   
                               splitLayout(
                                     cellWidths = c("20%", "20%", "20%", "20%", "10%", "10%", "0%"),
                                 
                                      
                                      
                                      # Add 4 select boxes
                                      selectInput(ns("activity_level"),
                                                  "Activity Level:",
                                               choices = c("All",
                                                             "Under 30 mins" = "under_30_min",
                                                             "30 mins to 5 hrs" = "30_min_to_5_hr",
                                                             "Over 5 hrs" = "over_5_hr"),
                                                            selected = "All"),
                                      selectInput(ns("gender"),
                                                 "Gender:",
                                                 choices = c("All",
                                                            "Male" = "male",
                                                            "Female" = "female",
                                                            "Other" = "other"),
                                                             selected = "All"),
                                 
                                 
                                      selectInput(ns("mode"),
                                                "Registration Status: ",
                                                choices = c("All",
                                                            "Verified" = "verified",
                                                            "Audit" = "audit"),
                                                            selected = "All"), 
                                 
                                      htmlOutput(ns("chap_name_overview")),
                                 
                                      
                                        
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
                                                       
                                            
                                            h5(textOutput(ns("student_count")))
                                                        
                                                ),
                                                
                                     h3(actionButton(ns("reset_filters"), "Reset"),align="center"),
                                                
                                     tags$head(tags$style(HTML("
                                                                        .shiny-split-layout > div {
                                                                          overflow: visible;
                                                                          }
                                                                          ")))
                                    
                                    ),style = "primary"))
            ),
          
          # Add effiel tower panel
          fluidRow(
                 bsCollapse(id=ns("effiel_towerplot"), multiple=TRUE,open = "How many students engaged with each course element?",
                 bsCollapsePanel("How many students engaged with each course element?",
                                 h4("Hover your mouse on each bar below for further details."),
                                 plotly::plotlyOutput(ns("tower_plot"),height='800px'),
                                 
                                 style='primary
                   ')))
  )

}