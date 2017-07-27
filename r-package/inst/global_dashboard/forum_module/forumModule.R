forumModule <- function(input, output, session) {
        
        observe({
                
                # Get the requested course.
          requested_course <- reactive({
            query <- parseQueryString(session$clientData$url_search)
            
            if ("course" %in% names(query)) {
              get_unhashed_course(query$course, 
                                  read_csv("../../data/.hashed_courses.csv"))
            } else {
              "no_course_selected"
            }
          })
                
                # Read in the data.
                root <- "../../data/"

                wrangled_forum_posts_csv <- reactiveFileReader(10000,
                                                           session,
                                                           paste0(root, requested_course(), "/wrangled_forum_posts.csv"),
                                                           read_csv)

                wrangled_forum_posts <- reactive({
                  validate(need(try(nrow(wrangled_forum_posts_csv()) > 0), "No forum posts found."))
                  wrangled_forum_posts_csv()
                })
                
                wrangled_forum_words_csv <- reactiveFileReader(10000,
                                                           session,
                                                           paste0(root, requested_course(), "/wrangled_forum_words.csv"),
                                                           read_csv)
                
                wrangled_forum_words <- reactive({
                  validate(need(try(nrow(wrangled_forum_words_csv()) > 0), "No forum words found."))
                  wrangled_forum_words_csv()
                })
                
                wrangled_forum_views_csv <- reactiveFileReader(10000,
                                                           session,
                                                           paste0(root, requested_course(), "/wrangled_forum_views.csv"),
                                                           read_csv)
                
                wrangled_forum_views <- reactive({
                  validate(need(try(nrow(wrangled_forum_views_csv()) > 0), "No forum views found."))
                  wrangled_forum_views_csv()
                })
                
                wrangled_forum_elements_csv <- reactiveFileReader(10000,
                                                              session,
                                                              paste0(root, requested_course(), "/wrangled_forum_elements.csv"),
                                                              read_csv)
                
                wrangled_forum_elements <- reactive({
                  validate(need(try(nrow(wrangled_forum_elements_csv()) > 0), "No forum elements found."))
                  wrangled_forum_elements_csv()
                })
                
                wrangled_forum_searches_csv <- reactiveFileReader(10000,
                                                              session,
                                                              paste0(root, requested_course(), "/wrangled_forum_searches.csv"),
                                                              read_csv)
                
                wrangled_forum_searches <- reactive({
                  validate(need(try(nrow(wrangled_forum_searches_csv()) > 0), "No forum searches found."))
                  wrangled_forum_searches_csv()
                })

                # Update the activity level.
                activity_level <- reactive({
                        
                        input$activity_level
                        
                })
                
                # Update the gender.
                gender <- reactive({
                        
                        input$gender
                        
                })
                
                # Update the registration status.
                registration_status <- reactive({

                        input$registration_status
                        
                })
                
                # Get the category options, based on the course.
                output$category_select <- renderUI({
                        
                        ns <- NS("forumID")
                        
                        selectInput(ns("category"),
                                    "Category:",
                                    choices = append(c("All"), unique(as.character(wrangled_forum_elements()$discussion_category))),
                                    selected = "All")
                        
                })
                
                # Update the category.
                category <- reactive({
                        
                        if (is.null(input$category)) {
                                return("All")
                        } else {
                                input$category
                        }
                        
                })
                
                # Update the plot variable.
                plot_variable <- reactive({
                        
                        input$x_axis
                        
                })
                
                # Update the breakdown variable.
                breakdown <- reactive({
                        
                        set_breakdown(plot_variable = plot_variable(),
                                      breakdown = input$breakdown)
                        
                })
                
                # Update the forum elements according to the category filter.
                filtered_forum_elements <- reactive({
                        
                        filter_forum_elements(forum_elements = wrangled_forum_elements(),
                                              category = category())
                        
                })
                
                # If the user presses the "Reset" button, reset all the filters to "All".
                observeEvent(input$reset_filters, autoDestroy = FALSE, {
                        
                        reset_filters(session = session)
                        
                })
                
                # Calculate the top forum searches for the selected demographics.
                forum_searches <- reactive({
                        
                        calculate_forum_searches(forum_searches = wrangled_forum_searches(),
                                                 forum_elements = wrangled_forum_elements(),
                                                 activity_level = activity_level(),
                                                 gender = gender(),
                                                 registration_status = registration_status(),
                                                 category = category())
                        
                })
                
                # Get the options for the subcategory selection.
                subcategory_options <<- reactive({
                        
                        get_subcategory_options(category = category(),
                                                filtered_forum_elements = filtered_forum_elements())
                        
                })
                
                output$subcategory_select <- renderUI({
                        
                        ns <- NS("forumID")
                        
                        selectInput(ns("subcategory"),
                                    "Subcategory:",
                                    choices = get_subcategory_options(category = category(),
                                                                      filtered_forum_elements = filtered_forum_elements()),
                                    selected = "All")
                })
                
                # Update the selected subcategory.
                selected_subcategory <- reactive({
                        
                        if (is.null(input$subcategory)) {
                                return("All")
                        } else {
                                input$subcategory
                        }
                        
                })
                
                # Update the counts for the forum data, based on the selected filters.
                updated_forum_data <- reactive({
                        
                        update_forum_data(forum_posts = wrangled_forum_posts(),
                                          forum_views = wrangled_forum_views(),
                                          forum_elements = filtered_forum_elements(),
                                          activity_level = activity_level(),
                                          gender = gender(),
                                          registration_status = registration_status(),
                                          category = category())
                        
                })
                
                # Filter the wordcloud data.
                filtered_wordcloud_data <- reactive({
                        
                        filter_wordcloud_data(forum_words = wrangled_forum_words(),
                                              forum_elements = wrangled_forum_elements(),
                                              activity_level = activity_level(),
                                              gender = gender(),
                                              registration_status = registration_status(),
                                              category = category())
                        
                })
                
                # Update the selected subcategory in the forum data.
                forum_data <- reactive({
                        
                        specify_forum_data_selection(updated_forum_data = updated_forum_data(),
                                                     category = category(),
                                                     selected_subcategory = selected_subcategory())
                        
                })
                
                # Render the forum plot title.
                output$forum_plot_title <- renderText({
                        
                        set_forum_plot_title(plot_variable = plot_variable(),
                                             category = category())
                        
                })
                
                # Render the forum plot subtitle.
                output$forum_plot_subtitle <- renderText({
                        paste0("Selected subcategory: ", tags$em(selected_subcategory()))
                })
                
                # Update the forum plot y-axis label.
                forum_plot_ylabel <- reactive({
                        
                        set_forum_plot_ylabel(plot_variable = plot_variable())
                        
                })
                
                # Get the wordcloud data.
                wordcloud_data <- reactive({
                        
                        get_wordcloud_data(filtered_wordcloud_data = filtered_wordcloud_data(),
                                           filtered_forum_elements = filtered_forum_elements(),
                                           category = category(),
                                           selected_subcategory = selected_subcategory())
                        
                })
                
                # Get the lengths of the labels on the barplot.
                label_lengths <- reactive({
                        
                        get_label_lengths(forum_data = forum_data(),
                                          category = category())
                        
                })
                
                # Set the limit of the horizontal axis on the main barplot.
                axis_limit <- reactive({
                        
                        set_axis_limit(forum_data = forum_data(),
                                       plot_variable = plot_variable(),
                                       label_lengths = label_lengths(),
                                       min_axis_length = 0.1,
                                       percent_addition_per_char = 0.023)
                        
                })
                
                # Get the string representing the function to call in aes_string() in the main barplot.
                reactive_xvar_string <- reactive({
                        
                        get_reactive_xvar_string(category = category())
                        
                })
                
                # Set the fill value for the main barplot.
                fill_value <- reactive({
                        
                        set_fill_value(plot_variable = plot_variable())
                        
                })
                
                
                # Make the main forum barplot.
                forum_barplot <- reactive({
                        
                        make_forum_barplot(forum_data = forum_data(),
                                           xvar_string = reactive_xvar_string(),
                                           plot_variable = plot_variable(),
                                           fill_value = fill_value(),
                                           axis_limit = axis_limit(),
                                           category = category(),
                                           ylabel = forum_plot_ylabel(),
                                           breakdown = breakdown())
                        
                })
                
                # Render the author count.
                output$author_count <- renderText({
                        
                        get_author_count(forum_posts = wrangled_forum_posts(),
                                         forum_elements = wrangled_forum_elements(),
                                         activity_level = activity_level(),
                                         gender = gender(),
                                         registration_status = registration_status(),
                                         category = category())
                        
                })
                
                # Render the viewer count.
                output$viewer_count <- renderText({
                        
                        get_viewer_count(forum_views = wrangled_forum_views(),
                                         forum_elements = wrangled_forum_elements(),
                                         activity_level = activity_level(),
                                         gender = gender(),
                                         registration_status = registration_status(),
                                         category = category())
                        
                })
                
                # Render the main plot.
                output$forum_plot <- renderPlot({
                        
                        forum_barplot()
                        
                })
                
                # Render the wordcloud title.
                output$wordcloud_title <- renderText({
                        
                        set_wordcloud_title(category = category(),
                                            selected_subcategory = selected_subcategory())
                        
                })
                
                # Render the forum threads table title.
                output$forum_threads_title <- renderText({
                        
                        set_forum_threads_title(category = category(),
                                                selected_subcategory = selected_subcategory())
                        
                })
                
                # Render the wordcloud.
                output$wordcloud <- renderPlot({
                        
                        make_wordcloud(wordcloud_data = wordcloud_data(),
                                       max_words = 20,
                                       scale = c(3.5,1))
                        
                })
                
                # Render the forum threads table.
                output$forum_threads <- renderDataTable(
                        
                        {
                                get_forum_threads(forum_posts = wrangled_forum_posts(),
                                                  forum_elements = wrangled_forum_elements(),
                                                  activity_level = activity_level(),
                                                  gender = gender(),
                                                  registration_status = registration_status(),
                                                  category = category(),
                                                  selected_subcategory = selected_subcategory())
                                
                        },
                        
                        # Show five threads, by default.
                        options = list(pageLength = 5)
                        
                )
                
                output$searches <- renderDataTable(
                        
                        # Show five search queries, by default.
                        options = list(pageLength = 5),
                        
                        {
                                
                                forum_searches()
                                
                        }
                )
                
        })
        
}