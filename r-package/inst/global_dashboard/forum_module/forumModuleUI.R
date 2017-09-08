forumModuleUI <- function(id) {

        ns <- NS(id)
        
        fluidPage(
                
                # Top row for the demographic filtering panel.
                fluidRow(
                        
                        bsCollapse(
                                id = ns("demo_dropdown_collapse"), multiple = TRUE, open = "Apply filters",
                                bsCollapsePanel(
                                        "Apply filters",
                                        splitLayout(
                                                cellWidths = c("25%", "25%", "25%", "12.5%", "12.5%", "0%"),
                                                selectInput(ns("activity_level"),
                                                            "Activity Level:",
                                                            choices = c("All",
                                                                        "Less than 30 minutes" = "under_30_min",
                                                                        "30 minutes - 5 hours" = "30_min_to_5_hr",
                                                                        "More than 5 hours" = "over_5_hr"),
                                                            selected = "All"),
                                                selectInput(ns("gender"),
                                                            "Gender:",
                                                            choices = c("All",
                                                                        "Male" = "male",
                                                                        "Female" = "female",
                                                                        "Other" = "other"),
                                                            selected = "All"),
                                                selectInput(ns("registration_status"),
                                                            "Registration Status:",
                                                            choices = c("All",
                                                                        "Verified" = "verified",
                                                                        "Audit" = "audit"),
                                                            selected = "All"),
                                                
                                                column(width = 1.2,
                                                       
                                                       # Right-align the text showing the author/viewer counts.
                                                       tags$head(tags$style(HTML("
                                                                                 #category_header, #author_count, #viewer_count {
                                                                                 text-align: center;
                                                                                }
                                                                                div.box-header {
                                                                                text-align: center;
                                                                                }
                                                                                "))),
                                                       
                                                       h5(textOutput(ns("author_count")), align="right"),
                                                       bsTooltip(ns("author_count"),
                                                                 "This is the number of unique users who posted at least once in the discussion forums.",
                                                                 placement = "bottom", trigger = "hover",
                                                                 options = NULL),
                                                       h5(textOutput(ns("viewer_count")), align="right"),
                                                       bsTooltip(ns("viewer_count"),
                                                                 "This is the number of unique users who viewed at least one post in the discussion forums.",
                                                                 placement = "bottom", trigger = "hover",
                                                                 options = NULL)
                                                       
                                                       ),
                                                
                                                h3(actionButton(ns("reset_filters"), "Reset"),align="center"),
                                                
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
                
                
                
                # Second row for the forum posts/views and the word cloud.
                fluidRow(

                        bsCollapse(

                                id = ns("main_plots"), multiple = TRUE, open = "What are students talking about in the discussion forums?",

                                bsCollapsePanel(
                                        "What are students talking about in the discussion forums?",

                                        splitLayout(cellWidths = c("33%", "0%", "33%", "33%", "0%"),

                                                    column(width = 12,
                                                           selectInput(ns("x_axis"),
                                                                       label = "X-Axis:",
                                                                       choices = c("Post counts" = "posts", "Author counts" = "authors", "View counts" = "views"),
                                                                       selected = "posts"),
                                                           conditionalPanel("input['forumID-x_axis'] == 'posts'",
                                                                            checkboxInput(ns("breakdown"),
                                                                                          label = "Show post types",
                                                                                          value = TRUE)
                                                           )
                                                    ),

                                                    tags$head(tags$style(HTML("
                                                                              .shiny-split-layout > div {
                                                                              overflow: visible;
                                                                              }
                                                                              "))),
                                                    
                                                    htmlOutput(ns("category_select")),

                                                    conditionalPanel("input['forumID-category'] != 'All'",
                                                                     htmlOutput(ns("subcategory_select"))
                                                    ),

                                                    tags$style(type='text/css', "#back_button {margin-top: 5px;}")
                                                    ),

                                        fluidRow(
                                                # Show the forum posts/views plot.
                                                column(width = 8,
                                                       h4(htmlOutput(ns("forum_plot_title"))),
                                                       conditionalPanel("input['forumID-category'] != 'All'",
                                                               h5(htmlOutput(ns("forum_plot_subtitle")))
                                                       ),
                                                       plotOutput(ns("forum_plot"))

                                                ),

                                                # Show the wordcloud.
                                                column(width = 4,
                                                       h4(htmlOutput(ns("wordcloud_title")), align="center"),
                                                       plotOutput(ns("wordcloud"))
                                                )
                                        ),

                                        # Third row for the threads table.
                                        fluidRow(
                                                # Put it in a column so that the margins are aligned with the above plots.
                                                column(width = 12,
                                                       h4(htmlOutput(ns("forum_threads_title"))),
                                                       h5("(Filter applies to authors)"),
                                                       dataTableOutput(ns("forum_threads"))
                                                )
                                        ),

                                style = "primary"

                                )
                        )
                ),

                # Fourth row for the top search terms.
                fluidRow(
                        bsCollapse(id = ns("searches_dropdown_collapse"), multiple = TRUE, open = "What are students searching for in the discussion forums?",

                                   bsCollapsePanel(
                                           "What are students searching for in the discussion forums?",
                                           dataTableOutput(ns("searches")),
                                           style = "primary"
                                   )

                        )
                )
        )
}