overviewModuleUI <- function(id) {
  ns <- NS(id)
  
  # Add filtering panel       
  fluidPage(
    
    fluidRow(
      
      bsCollapse(
        
        id = ns('demo_dropdown_collapse'),
        multiple = TRUE,
        open = "↕ Apply filters",
        
        bsCollapsePanel(
          "↕ Apply filters",
          splitLayout(
            cellWidths = c("20%", "20%", "20%", "20%", "20%", "0%"),
            
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
            
            h3(actionButton(ns("reset_filters"), "Reset"),align = "center"),
            
            tags$head(tags$style(HTML("
                                      .shiny-split-layout > div {
                                      overflow: visible;
                                      }
                                      ")))
            
            ),
          
          style = "primary"
          
          )
      
        )
      
      ),
    
    # Add eiffel tower panel
    fluidRow(
      bsCollapse(
        id = ns("effiel_towerplot"),
        multiple = TRUE,
        open = "↕ How many learners have engaged with each course element?",
        
        bsCollapsePanel(
          "↕ How many learners have engaged with each course element?",
          plotly::plotlyOutput(ns("tower_plot"),height = '800px'),
          style = 'primary')
        
      )
      
    )
          
  )

}