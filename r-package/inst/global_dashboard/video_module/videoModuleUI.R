videoModuleUI <- function(id) {
  ns <- NS(id)
  
  # Top row for the demographic filtering panel.
  fluidPage(fluidRow(bsCollapse( id=ns('demo_dropdown_collapse'), multiple=TRUE, open = "Apply filters",
                                 bsCollapsePanel("Apply filters",
                                                 splitLayout(cellWidths = c("15%", "10%", "20%", "30%", "15%", "10%"),
                                                             selectInput(ns("activity_level"),
                                                                         "Activity Level:",
                                                                         choices = c("All" = "all",
                                                                                     "Under 30 mins" = "under_30_min",
                                                                                     "30 mins to 5 hrs" = "30_min_to_5_hr",
                                                                                     "Over 5 hrs" = "over_5_hr"),
                                                                         selected = "all"),
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
                                                             selectInput(ns("module"),
                                                                         "Module:",
                                                                         choices = append("All",chap_name),
                                                                         selected = "All"),
                                                             
                                                             h5(textOutput(ns("num_students")), align="center"),
                                                             
                                                             h3(actionButton(ns("reset_filters"), "Reset"),align="center"),
                                                             
                                                             tags$head(tags$style(HTML("
                                                                                       .shiny-split-layout > div {
                                                                                       overflow: visible;
                                                                                       }
                                                                                       "))),
                                                             tags$style(type='text/css', "#num_students {margin-top: 30px;}")),
                                                 style = "primary"))),
            # Most viewed
            fluidRow(
              bsCollapse(id=ns("most_views"), multiple=TRUE, open = "Which of my videos is watched the most?",
                         bsCollapsePanel("Which of my videos is watched the most?",
                                         plotly::plotlyOutput(ns("most_viewed")),
                                         style='primary'))),
            
            
            # Video heat map:
            fluidRow(
              bsCollapse(id=ns("heat_map"), multiple=TRUE,
                         bsCollapsePanel("Which part of my videos are being watched the most?",
                                         plotly::plotlyOutput(ns("video_heatmap")), 
                                         style='primary'))),
            
            # Up until plot
            fluidRow(
              bsCollapse(id=ns("up_unt"), multiple=TRUE,
                         bsCollapsePanel("What part are students watching up until?",
                                         plotly::plotlyOutput(ns("up_until")),
                                         style='primary'))),
            
            # Top Heat
            fluidRow(
              bsCollapse(id=ns("top_surprise"), multiple=TRUE,
                         bsCollapsePanel("Which part of my videos are the most surprising?",
                                         plotly::plotlyOutput(ns("surprising")), 
                                         selectInput(ns("top_selection"),
                                                     "Select segments to highlight:",
                                                     choices = c("Top 10" = 10,
                                                                 "Top 25" = 25,
                                                                 "Top 50" = 50),
                                                     selected = 10),
                                         style='primary'))),
            
            
            # Summary table:
            fluidRow(
              bsCollapse(id=ns("summary_table"), multiple=TRUE,
                         bsCollapsePanel("Summary Table",
                                         dataTableOutput("summary_tbl"),
                                         br(),
                                         style='primary')
              )))
}