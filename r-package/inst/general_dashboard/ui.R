# Define UI for the application.
shinyUI(
  fluidPage(
    # Top row for the demographic filtering panel.
    fluidRow(bsCollapse(id="demo_dropdown_collapse", multiple=TRUE, open="Select demographics",
                        bsCollapsePanel( "Select demographics",
                                         splitLayout(cellWidths = c("20%", "20%", "20%", "20%", "20%"),
                                                     selectInput("activity_level",
                                                                 "Activity Level:",
                                                                 choices = c("All" = "all",
                                                                             "Under 30 mins" = "under_30_min",
                                                                             "30 mins to 5 hrs" = "30_min_to_5_hr",
                                                                             "Over 5 hrs" = "over_5_hr"),
                                                                 selected = "All"),
                                                     selectInput("gender", "Gender:",
                                                                 choices = c("All" = "all",
                                                                             "Male" = "male",
                                                                             "Female" = "female",
                                                                             "Other" = "other"),
                                                                 selected = "all"), 
                                                     selectInput("mode",
                                                                 "Registration Status:",
                                                                 choices = c("All" = "all",
                                                                             "Verified" = "verified",
                                                                             "Audit" = "audit"),
                                                                 selected = "all"),
                                                     
                                                     h5(textOutput("num_students"), align="center"),
                                                     
                                                     h3(actionButton("reset_filters", "Reset"),align="center"),
                                                     
                                                     tags$head(tags$style(HTML("
                                                                               .shiny-split-layout > div {
                                                                               overflow: visible;
                                                                               }
                                                                               "))),
                                                     tags$style(type='text/css', "#num_students {margin-top: 30px;}")),
                                         style = "primary"))),
    
    # Education
    fluidRow(
      bsCollapse(id="level_of_education", multiple=TRUE, open="What kind of education do my students have?",
                 bsCollapsePanel("What kind of education do my students have?",
                                 plotOutput("loe_demo"),
                                 style='primary'))),
    
    # Location
    fluidRow(
      bsCollapse(id="location", multiple=TRUE,
                 bsCollapsePanel("Where are my students from?",
                                 plotOutput("continent_demo"),
                                 style='primary'))),
    
    # Language
    fluidRow(
      bsCollapse(id="language", multiple=TRUE,
                 bsCollapsePanel("What languages do my students speak?",
                                 plotOutput("language_demo"),
                                 style='primary'))),
    
    # Age
    fluidRow(
      bsCollapse(id="age", multiple=TRUE,
                 bsCollapsePanel("What age are my students?",
                                 plotOutput("age_demo"),
                                 style='primary')))
  )
)