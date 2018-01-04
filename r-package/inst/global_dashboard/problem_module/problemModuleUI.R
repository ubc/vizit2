# Define UI for the application.
problemModuleUI <- function(id) {
  ns <- NS(id)
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
            h3(actionButton(ns("reset_filters"),
                            "Reset", align = "center")),
            tags$head(tags$style(HTML("
                                      .shiny-split-layout > div {
                                      overflow: visible;
                                      }"))),
            tags$style(type = "text/css", "#num_students {margin-top: 30px;}")),
        style = "primary"
        )
      )
    ),

    fluidRow(
      bsCollapse(
        id = ns("overview_panel"),
        multiple = TRUE, #open = "How did students do in each module?",
        open = "How did students do in each module?",
        bsCollapsePanel(
          title = "How did students do in each module?",
          #tags$p("This plot shows the average grade achieved by students on the multiple choice problems in each module."),
          plotOutput(ns("overview_plot")),
          style = "primary"
        )
      )
    ),

    fluidRow(
      bsCollapse(
        id = ns("bottom_questions_panel"),
        bsCollapsePanel(
          "What are the three hardest problems?",
          plotOutput(ns("bottom_questions"), height = "600px"),
          style = "primary"
        )
      )
    ),

    fluidRow(
      bsCollapse(
        id = ns("assessment_panel"),
        # tags$p("Open Response Assessments are short essays that are reviewed by
        #        the students themselves, by their peers, and occasionally by 
        #        the instructor. If the instructor has completed an assessment,
        #        it will be recorded as the final grade. Otherwise, the final
        #        grade is determined by the peer assessments."),
        bsCollapsePanel(
          title = "How were students assessed on Open Response Assessments?",
          plotOutput(ns("assessment_plot")),
          style = "primary"
        )
      )
    ),
    
    fluidRow(
      bsCollapse(
        id = ns("chapter_overview_panel"),
        bsCollapsePanel(
          title = "What was the average score on each problem?",
          DT::dataTableOutput(ns("chapter_table")),
          style = "primary"
        )
      )
    )
  )
}
