generalModuleUI <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    
    # Top row for the demographic filtering panel.
    fluidRow(
      
      bsCollapse(
        
        id = ns("demo_dropdown_collapse"), 
        multiple = TRUE, 
        open = "Apply filters",
        
        bsCollapsePanel(
          
          title = "Apply filters",
          
          splitLayout(
            
            cellWidths = c("25%", "25%", "25%", "25%", "0%"),
            
            selectInput(ns("activity_level"),
                        "Activity Level:",
                        choices = c("All" = "all",
                                    "Under 30 mins" = "under_30_min",
                                    "30 mins to 5 hrs" = "30_min_to_5_hr",
                                    "Over 5 hrs" = "over_5_hr"),
                        selected = "All"),
            selectInput(ns("gender"), "Gender:",
                        choices = c("All" = "all",
                                    "Male" = "male",
                                    "Female" = "female",
                                    "Other" = "other"),
                        selected = "all"), 
            selectInput(ns("mode"),
                        "Registration Status:",
                        choices = c("All" = "all",
                                    "Verified" = "verified",
                                    "Audit" = "audit"),
                        selected = "all"),
            
            h3(actionButton(ns("reset_filters"), "Reset"),align = "center"),
            
            tags$head(tags$style(HTML("
                                      .shiny-split-layout > div {
                                      overflow: visible;
                                      }
                                      "))),
            
            tags$style(type = 'text/css', "#num_students {margin-top: 30px;}")),
                      
          style = "primary"
                         
          )
                        
        )
      
    ),
    
    # Education
    fluidRow(
      bsCollapse(id = ns("level_of_education"), 
                 multiple = TRUE, 
                 open = "What are my learners' levels of education?",
                 bsCollapsePanel("What are my learners' levels of education?",
                                 plotOutput(ns("loe_demo")),
                                 style = 'primary'))),

    # Location
    fluidRow(
      bsCollapse(id = ns("location"),
                 multiple = TRUE,
                 bsCollapsePanel("Where are my learners located? (top 10 countries)",
                                 plotOutput(ns("continent_demo")),
                                 style = 'primary'))),

    # Language
    fluidRow(
      bsCollapse(id = ns("language"), 
                 multiple = TRUE,
                 bsCollapsePanel("What languages do my learners speak? (top 10 languages)",
                                 plotOutput(ns("language_demo")),
                                 style = 'primary'))),

    # Age
    fluidRow(
      bsCollapse(id = ns("age"), 
                 multiple = TRUE,
                 bsCollapsePanel("What age are my learners?",
                                 plotOutput(ns("age_demo")),
                                 style = 'primary')))
    
  )
  
}