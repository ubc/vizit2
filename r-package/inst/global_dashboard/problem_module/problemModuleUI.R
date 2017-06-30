# Define UI for the application.
problemModuleUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    fluidRow(
      bsCollapse(
        id=ns('demo_dropdown_collapse'),
        multiple=TRUE, open = "Apply filters",
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

                    htmlOutput(ns("moduleSelection")),

                    h5(textOutput(ns("num_students")),
                                  align = "center"),

                    h3(actionButton(ns("reset_filters"),
                                       "Reset", align = "center")),

                    tags$head(tags$style(HTML("
                      .shiny-split-layout > div {
                      overflow: visible;
                      }"))),

                    tags$style(type = "text/css", "#num_students {margin-top: 30px;}")),
                    style = "primary"))),

    fluidRow(
        bsCollapse(id = ns("overview_panel"),
                   multiple = TRUE,
                   bsCollapsePanel("How did students do in each module?",
                                   plotOutput(ns("overview_plot")),
                                   style = "primary"))),

    fluidRow(
      bsCollapse(id = ns("bottom_questions_panel"),
                 bsCollapsePanel("What are the three hardest problems?",
                                 plotOutput(ns("bottom_questions"), height = "600px"),
                                 style = "primary"))),

    fluidRow(
      bsCollapse(id = ns("assessment_panel"),
                 bsCollapsePanel("How were students assessed on Open Response Assignments?",
                                 plotOutput(ns("assessment_plot")),
                                 style = "primary"))),

    fluidRow(
      bsCollapse(id = ns("chapter_overview_panel"),
                 bsCollapsePanel("How did students do on each problem?",
                                 DT::dataTableOutput(ns("chapter_table")),
                                 style = "primary")))
    )
}