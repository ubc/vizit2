# Define UI for the application.
shinyUI(
  fluidPage(
    # Top row for the demographic filtering panel.
    fluidRow(bsCollapse( id='demo_dropdown_collapse', multiple=TRUE, open = "Apply filters",
                         bsCollapsePanel("Apply filters",
                         splitLayout(cellWidths = c("15%", "10%", "20%", "30%", "15%", "10%"),
                                     selectInput("activity_level",
                                                 "Activity Level:",
                                                 choices = c("All" = "all",
                                                             "Under 30 mins" = "under_30_min",
                                                             "30 mins to 5 hrs" = "30_min_to_5_hr",
                                                             "Over 5 hrs" = "over_5_hr"),
                                                 selected = "all"),
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
                                     selectInput("module",
                                                 "Module:",
                                                 choices = append("All",chap_name),
                                                 selected = "All"),
                                     
                                     h5(textOutput("num_students"), align="center"),
                                     
                                     h3(actionButton("reset_filters", "Reset"),align="center"),

                                     tags$head(tags$style(HTML("
                                                               .shiny-split-layout > div {
                                                               overflow: visible;
                                                               }
                                                               "))),
                                     tags$style(type='text/css', "#num_students {margin-top: 30px;}")),
                         style = "primary"))),
    
    # Most viewed
    fluidRow(
      bsCollapse(id="most_views", multiple=TRUE, open = "Which of my videos is watched the most?",
                 bsCollapsePanel("Which of my videos is watched the most?",
                                 plotly::plotlyOutput("most_viewed"),
                                 style='primary'))),
    
    
    # Video heat map:
    fluidRow(
      bsCollapse(id="heat_map", multiple=TRUE,
                 bsCollapsePanel("Which part of my videos are being watched the most?",
                                 plotly::plotlyOutput("video_heatmap"), 
                                 style='primary'))),
    
    # Top Heat
    fluidRow(
      bsCollapse(id="top_heat", multiple=TRUE,
                 bsCollapsePanel("Which part of my videos are the hottest?",
                                 plotly::plotlyOutput("hottest"), 
                                 selectInput("top_selection",
                                             "Select segments to highlight:",
                                             choices = c("Top 10" = 10,
                                                         "Top 25" = 25,
                                                         "Top 50" = 50),
                                             selected = 10),
                                 style='primary'))),
    
    
    # Summary table:
    fluidRow(
      bsCollapse(id="summary_table", multiple=TRUE,
                 bsCollapsePanel("Summary Table",
                                 dataTableOutput("summary_tbl"),
                                 br(),
                                 style='primary')
      ))
    
           ) 

)