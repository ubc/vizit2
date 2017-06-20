generalModuleUI <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    # Top row for the demographic filtering panel.
    fluidRow(bsCollapse(id=ns("demo_dropdown_collapse"), multiple=TRUE, open="Select demographics",
                        bsCollapsePanel( "Select demographics",
                                         splitLayout(cellWidths = c("20%", "20%", "20%", "20%", "20%"),
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
                                                     
                                                     h5(textOutput(ns("num_students")), align="center"),
                                                     
                                                     h3(actionButton(ns("reset_filters"), "Reset"),align="center"),
                                                     
                                                     tags$head(tags$style(HTML("
                                                                               .shiny-split-layout > div {
                                                                               overflow: visible;
                                                                               }
                                                                               "))),
                                                     tags$style(type='text/css', "#num_students {margin-top: 30px;}")),
                                         style = "primary"))
             ),
    
    # Education
    fluidRow(
      bsCollapse(id=ns("level_of_education"), multiple=TRUE, open="What kind of education do my students have?",
                 bsCollapsePanel("What kind of education do my students have?",
                                 plotOutput(ns("loe_demo")),
                                 style='primary'))),

    # Location
    fluidRow(
      bsCollapse(id=ns("location"), multiple=TRUE,
                 bsCollapsePanel("Where are my students from?",
                                 plotOutput(ns("continent_demo")),
                                 style='primary'))),

    # Language
    fluidRow(
      bsCollapse(id=ns("language"), multiple=TRUE,
                 bsCollapsePanel("What languages do my students speak?",
                                 plotOutput(ns("language_demo")),
                                 style='primary'))),

    # Age
    fluidRow(
      bsCollapse(id=ns("age"), multiple=TRUE,
                 bsCollapsePanel("What age are my students?",
                                 plotOutput(ns("age_demo")),
                                 style='primary')))
                        )
}