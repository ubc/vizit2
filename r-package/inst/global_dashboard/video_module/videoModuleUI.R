videoModuleUI <- function(id) {
  ns <- NS(id)
  
  # Top row for the demographic filtering panel.
  fluidPage(
    fluidRow(
      bsCollapse(
        id = ns('demo_dropdown_collapse'),
        multiple = TRUE,
        open = "Apply filters",
        bsCollapsePanel(
          title = "Apply filters",
          splitLayout(
            cellWidths = c("20%", "20%", "20%", "20%", "20%", "0%"),
            selectInput(
              inputId = ns("activity_level"),
              label = "Activity Level:",
              choices = c("All" = "all",
                          "Under 30 mins" = "under_30_min",
                          "30 mins to 5 hrs" = "30_min_to_5_hr",
                          "Over 5 hrs" = "over_5_hr"),
              selected = "all"),
            selectInput(
              inputId = ns("gender"), 
              label = "Gender:",
              choices = c("All" = "all",
                          "Male" = "male",
                          "Female" = "female",
                          "Other" = "other"),
              selected = "all"),
            selectInput(
              inputId = ns("mode"),
              label = "Registration Status:",
              choices = c("All" = "all",
                          "Verified" = "verified",
                          "Audit" = "audit"),
              selected = "all"),
            htmlOutput(ns("moduleSelection")),
            h3(actionButton(ns("reset_filters"), "Reset"), align = "center"),
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
    
    # Most viewed
    fluidRow(
      bsCollapse(
        id = ns("most_views"),
        multiple = TRUE,
        open = "Which of my videos are watched the most?",
        bsCollapsePanel(
          title = "Which of my videos are watched the most?",
          plotly::plotlyOutput(ns("most_viewed")),
          style = 'primary'
        )
      )
    ),
    
    # Video heat map:
    fluidRow(
      bsCollapse(
        id = ns("heat_map"),
        multiple = TRUE,
        bsCollapsePanel(
          title = "Which segments of my videos are being viewed the most?",
          plotly::plotlyOutput(ns("video_heatmap")),
          style = 'primary'
        )
      )
    ),
    
    # Developer note: This plot was removed and to be re-implemented 
    # pending usability testing results
    #
    # Up until plot
    # fluidRow(
    #   bsCollapse(id=ns("up_unt"), multiple=TRUE,
    #              bsCollapsePanel("What part are students watching up until?",
    #                              plotly::plotlyOutput(ns("up_until")),
    #                              style='primary'))),
    
    # Top Heat
    fluidRow(
      bsCollapse(
        id = ns("top_surprise"),
        multiple = TRUE,
        bsCollapsePanel(
          title = "Which video segments have abnormally high or low watch rates?",
          selectInput(
            inputId = ns("top_selection"),
            label = "Select segments to highlight:",
            choices = c("Top 10" = 10,
                        "Top 25" = 25,
                        "Top 50" = 50),
            selected = 10),
          plotly::plotlyOutput(ns("surprising")), 
          style = 'primary'
        )
      )
    ),
        
    # Summary table:
    fluidRow(
      bsCollapse(
        id = ns("summary_table"),
        multiple = TRUE,
        bsCollapsePanel(
          title = "Summary Table",
          dataTableOutput(ns("summary_tbl")),
          br(),
          style = 'primary'
        )
      )
    )
  )
}