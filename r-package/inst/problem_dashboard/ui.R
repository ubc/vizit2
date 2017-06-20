# Define UI for the application.
shinyUI(
        fluidPage(
                # Top row for the demographic filtering panel.
          fluidRow(
            column(
              width=12,
              h4("This dashboard aims to display student engagement with problems in your course."),
              h5("Filter learners by demographics below:"),
              br(),
              splitLayout(cellWidths = c("15%", "10%", "20%", "30%", "15%", "10%"),
                          selectInput("gender", "Gender:",
                                      choices = c("All" = "all",
                                                  "Male" = "male",
                                                  "Female" = "female",
                                                  "Other" = "other"),
                                      selected = "all"),

                          selectInput("mode",
                                      "Mode:",
                                      choices = c("All" = "all",
                                                  "Verified" = "verified",
                                                  "Audit" = "audit"),
                                      selected = "all"),

                          selectInput("activity_level",
                                      "Activity Level:",
                                      choices = c("All" = "all",
                                                  "Under 30 mins" = "under_30_min",
                                                  "30 mins to 5 hrs" = "30_min_to_5_hr",
                                                  "Over 5 hrs" = "over_5_hr"),
                                      selected = "all"),

                          selectInput("chapter",
                                      "Module:",
                                      choices = append("All", chap_name),
                                      selected = "All"),

                          h5(textOutput("num_students"), align="center"),
                          h3(actionButton("reset_filters", "Reset"),align="center"),
                          tags$head(tags$style(HTML("
                                          .shiny-split-layout > div {
                                          overflow: visible;
                                          }
                                          "))),
                          tags$style(type='text/css', "#num_students {margin-top: 30px;}")
              ),
              style = "primary"
                        )
                ),

                fluidRow(
                  bsCollapse(id = "overview_panel", multiple = TRUE,

                             bsCollapsePanel("How did students do in each module?",
                         plotOutput("overview_plot"),
                         style = "primary"
                               )
                  )
                  ),


                fluidRow(
                  bsCollapse(id = "bottom_questions_panel",
                             bsCollapsePanel("What are the three hardest problems?",
                         plotOutput("bottom_questions", height = "600px"),
                         style = "primary"
                  ))),
                fluidRow(
                  bsCollapse(id = "assessment_panel",
                       bsCollapsePanel("How were students assessed on assignments?",
                                       plotOutput("assessment_plot"),
                                       style = "primary"
                       ))),

                fluidRow(
                  bsCollapse(id = "chapter_overview_panel",
                             bsCollapsePanel("How did students do on each problem?",
                                             DT::dataTableOutput("chapter_table"),
                                             style = "primary"
                             )))
      )
)
