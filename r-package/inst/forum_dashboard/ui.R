library(shiny)

# Define UI.
shinyUI(
        
        fluidPage(
                
                # Top row for the demographic filtering panel.
                fluidRow(
                        
                        bsCollapse(
                                id = "demo_dropdown_collapse", multiple = TRUE, open = "Apply filters",
                                bsCollapsePanel(
                                        "Apply filters",
                                        splitLayout(
                                                cellWidths = c("25%", "25%", "25%", "12.5%", "12.5%", "0%"),
                                                selectInput("activity_level",
                                                            "Activity Level:",
                                                            choices = c("All",
                                                                        "Less than 30 minutes" = "under_30_min",
                                                                        "30 minutes - 5 hours" = "30_min_to_5_hr",
                                                                        "More than 5 hours" = "over_5_hr"),
                                                            selected = "All"),
                                                selectInput("gender",
                                                            "Gender:",
                                                            choices = c("All",
                                                                        "Male" = "male",
                                                                        "Female" = "female",
                                                                        "Other" = "other"),
                                                            selected = "All"),
                                                selectInput("registration_status",
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
                                                       
                                                       h5(textOutput("author_count"), align="right"),
                                                       h5(textOutput("viewer_count"), align="right")
                                                       
                                                       ),
                                                
                                                h3(actionButton("reset_filters", "Reset"),align="center"),
                                                
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
                                
                                id = "main_plots", multiple = TRUE, open = "What are students talking about in the discussion forums?",
                                
                                bsCollapsePanel(
                                        "What are students talking about in the discussion forums?",
                                        
                                        splitLayout(cellWidths = c("33%", "0%", "33%", "33%", "0%"),
                                                    
                                                    column(width = 12,
                                                           selectInput("x_axis",
                                                                       label = "X-Axis:",
                                                                       choices = c("Post counts" = "posts", "Author counts" = "authors", "View counts" = "views"),
                                                                       selected = "posts"),
                                                           conditionalPanel("input.x_axis == 'posts'",
                                                                            checkboxInput("breakdown",
                                                                                          label = "Show post types",
                                                                                          value = FALSE)
                                                           )
                                                    ),
                                                    
                                                    tags$head(tags$style(HTML("
                                                                              .shiny-split-layout > div {
                                                                              overflow: visible;
                                                                              }
                                                                              "))),
                                                    
                                                    selectInput("category",
                                                                "Category:",
                                                                choices = append(list("All"), as.character(wrangled_forum_elements$discussion_category)),
                                                                selected = "All"),
                                                    
                                                    conditionalPanel("input.category != 'All'",
                                                                     selectInput("subcategory",
                                                                                 "Subcategory:",
                                                                                 choices = '')
                                                    ),
                                                    
                                                    tags$style(type='text/css', "#back_button {margin-top: 5px;}")
                                                    ),
                                        
                                        fluidRow(
                                                # Show the forum posts/views plot.
                                                column(width = 8,
                                                       h4(htmlOutput("forum_plot_title")),
                                                       plotOutput("forum_plot")
                                                       
                                                ),
                                                
                                                # Show the wordcloud.
                                                column(width = 4,
                                                       h4(htmlOutput("wordcloud_title"), align="center"),
                                                       plotOutput("wordcloud")
                                                )
                                        ),
                                        
                                        # Third row for the threads table.
                                        fluidRow(
                                                # Put it in a column so that the margins are aligned with the above plots.
                                                column(width = 12,
                                                       h4(htmlOutput("forum_threads_title")),
                                                       h5("(Filter applies to authors)"),
                                                       dataTableOutput("forum_threads")
                                                )
                                        ),
                                        
                                        style = "primary"
                                        
                                                    )
                                        )
                                ),
                
                # Fourth row for the top search terms.
                fluidRow(
                        bsCollapse(id = "searches_dropdown_collapse", multiple = TRUE, open = "What are students searching for in the discussion forums?",
                                   
                                   bsCollapsePanel(
                                           "What are students searching for in the discussion forums?",
                                           dataTableOutput("searches"),
                                           style = "primary"
                                   )
                                   
                        )
                )
                                                )
        
                                                )
