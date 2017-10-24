#' Apply the selected filter settings to the forum data.
#' @param input_df The input dataframe.
#' @param forum_elements The forum elements dataframe.
#' @param activity_level One of \code{under_30_min}, \code{30_min_to_5_hr}, \code{over_5_hr}, or (default) \code{All}.
#' @param gender One of \code{male}, \code{female}, \code{other}, or (default) \code{All}.
#' @param registration_status One of \code{audit}, \code{verified}, or (default) \code{All}.
#' @param category One of the forum categories.
#' @return \code{filtered_df} A dataframe filtered by the selected settings.
#' @export
#' @examples
#' apply_forum_filters(forum_posts, forum_elements, "All", "All", "All")
apply_forum_filters <-
  function(input_df,
           forum_elements,
           activity_level = "All",
           gender = "All",
           registration_status = "All",
           category = "All") {
    filtered_df <- input_df

    if (gender == "female") {
      filtered_df <- filtered_df %>% filter(gender == "f")

    }

    if (gender == "male") {
      filtered_df <- filtered_df %>% filter(gender == "m")

    }

    if (gender == "other") {
      filtered_df <- filtered_df %>% filter(gender == "o")

    }

    if (activity_level == "under_30_min") {
      filtered_df <-
        filtered_df %>% filter(activity_level == "under_30_min")

    }

    if (activity_level == "30_min_to_5_hr") {
      filtered_df <-
        filtered_df %>% filter(activity_level == "30_min_to_5_hr")

    }

    if (activity_level == "over_5_hr") {
      filtered_df <- filtered_df %>% filter(activity_level == "over_5_hr")

    }

    if (registration_status == "audit") {
      filtered_df <-
        filtered_df %>% filter(registration_status == "audit")

    }

    if (registration_status == "verified") {
      filtered_df <-
        filtered_df %>% filter(registration_status == "verified")

    }

    if (category != "All") {
      if (!"discussion_category" %in% names(filtered_df)) {
        filtered_df

      } else {
        filtered_df <- filtered_df %>%
          filter(discussion_category == category)
        forum_elements <- forum_elements %>%
          filter(discussion_category == category)

      }

    }

    # If all students have been filtered out, return forum_elements with
    # nothing in it.
    if (dim(filtered_df)[1] == 0 &
        !"search_query" %in% names(filtered_df)) {
      filtered_df <- right_join(forum_elements, filtered_df)
      return(filtered_df)

    } else {
      return(filtered_df)

    }

  }


#' Get the top words for each subcategory.
#' @param input_forum The input dataframe containing a row for each word in the forum.
#' @return \code{word_counts} A dataframe containing the counts for each word in each subcategory.
#' @export
#' @examples
#' get_target_word_counts(wrangled_forum_words)
get_target_word_counts <- function(input_forum) {
  # Get the word counts for each word in each subcategory.
  word_counts <- input_forum %>%
    group_by(display_name, word) %>%
    count(sort = TRUE)

  # Return the relative counts for each word in each subcategory.
  return(word_counts)

}


#' Count the number of posts for each subcategory in an input forum.
#' @param input_forum The input dataframe containing a row for each post in the forum.
#' @param wrangled_forum_elements A dataframe containing information about each of the forum subcategories.
#' @return \code{post_counts} A dataframe containing the post counts for each subcategory in the forum.
#' @export
#' @examples
#' count_posts(wrangled_forum_posts)
count_posts <- function(input_forum, wrangled_forum_elements) {
  # Make sure there is a row for every permutation of display names and post types.
  types_dummy_set <- data_frame(
    "commentable_id" = rep(wrangled_forum_elements$commentable_id, each = 4),
    "type" = rep(
      c("Discussion", "Question", "Response", "Comment"),
      times = dim(wrangled_forum_elements)[1]
    )
  )

  # Count up all the posts.
  post_counts <- input_forum %>%
    group_by(commentable_id, display_name, type) %>%
    summarize(posts = n_distinct(mongoid, na.rm = TRUE)) %>%
    right_join(types_dummy_set) %>%
    tidyr::spread(key = type,
                  value = posts,
                  drop = FALSE) %>%
    mutate(posts = sum(Discussion, Question, Response, Comment, na.rm = TRUE))

  post_counts$posts[is.na(post_counts$posts)] <- 0
  post_counts$Discussion[is.na(post_counts$Discussion)] <- 0
  post_counts$Question[is.na(post_counts$Question)] <- 0
  post_counts$Response[is.na(post_counts$Response)] <- 0
  post_counts$Comment[is.na(post_counts$Comment)] <- 0

  return(post_counts)
}


#' Count the number of authors for each subcategory in an input forum.
#' @param input_forum The input dataframe containing a row for each post in the forum.
#' @param wrangled_forum_elements A dataframe containing information about each of the forum subcategories.
#' @return \code{author_counts} A dataframe containing the unique author counts for each subcategory in the forum.
#' @examples
#' count_authors(wrangled_forum_posts)
count_authors <- function(input_forum, wrangled_forum_elements) {
  author_counts <- input_forum %>%
    group_by(commentable_id, display_name) %>%
    summarize(authors = n_distinct(author_id)) %>%
    arrange(desc(authors))

  author_counts <-
    right_join(wrangled_forum_elements, author_counts)
  author_counts$authors[is.na(author_counts$authors)] <- 0

  return(author_counts)

}


#' Count the number of view events for each subcategory in an input forum.
#' @param input_forum The input dataframe containing a row for each read event in the forum.
#' @param wrangled_forum_elements A dataframe containing information about each of the forum subcategories.
#' @return \code{view_counts} A dataframe containing the read counts for each subcategory in the forum.
#' @examples
#' count_views(wrangled_forum_views)
count_views <- function(input_forum, wrangled_forum_elements) {
  view_counts <- input_forum %>%
    group_by(commentable_id, display_name) %>%
    count() %>%
    mutate(views = n) %>%
    select(-n) %>%
    arrange(desc(views))

  view_counts <-
    right_join(wrangled_forum_elements, view_counts)
  view_counts$views[is.na(view_counts$views)] <- 0

  return(view_counts)
}


#' Determines whether the plot types breakdown will be shown.
#' @param plot_variable One of (default) \code{posts}, \code{authors}, or \code{views}.
#' @param breakdown One of \code{TRUE} or (default) \code{FALSE}.
#' @return \code{TRUE} or \code{FALSE}
#' @examples
#' set_breakdown(plot_variable = "posts", breakdown = FALSE)
#' @details
#' This option only comes into play if the plot variable is 'posts'.
set_breakdown <- function(plot_variable, breakdown) {
  if (plot_variable == "posts") {
    return(breakdown)

  } else {
    return(FALSE)

  }

}


#' Filter the forum elements by the selected filter variables.
#' @param forum_elements The forum elements dataframe that was passed in from the wrangling script.
#' @param category The forum category that the user has selected.
#' @return \code{filtered_forum_elements} The same dataframe, filtered by category if appropriate.
#' @examples
#' filter_forum_elements(wrangled_forum_elements, "Part 1")
#' @details
#' The forum elements dataframe only needs to be filtered by category, since it doesn't include any variables related to students.
filter_forum_elements <- function(forum_elements,
                                  category) {
  if (category == "All") {
    filtered_forum_elements <- forum_elements

    return(filtered_forum_elements)

  } else {
    filtered_forum_elements <- forum_elements %>%
      filter(discussion_category == category)

    return(filtered_forum_elements)

  }

}


#' Resets all the user-defined filters to "All".
#' @param session A Shiny session object. See https://shiny.rstudio.com/reference/shiny/latest/session.html
#' @return None.
#' @examples
#' reset_filters(session)
#' @details
#' The function is called when the user presses the "Reset" button.
reset_filters <- function(session) {
  # Update the activity level.
  activity_level <- reactive({
    "All"
  })

  # Update the gender.
  gender <- reactive({
    "All"
  })

  # Update the registration status.
  registration_status <- reactive({
    "All"
  })

  # Update the category.
  category <- reactive({
    "All"
  })

  updateSelectInput(session,
                    inputId = "activity_level",
                    selected = activity_level())

  updateSelectInput(session,
                    inputId = "gender",
                    selected = gender())

  updateSelectInput(session,
                    inputId = "registration_status",
                    selected = registration_status())

  updateSelectInput(session,
                    inputId = "category",
                    selected = category())

}


#' Calculates the number of unique users who searched for each search query, given the selected filters.
#' @param forum_searches The wrangled forum searches dataframe.
#' @param forum_elements The forum elements dataframe.
#' @param activity_level The activity level of the students.
#' @param gender The gender of the students.
#' @param registration_status The registration status of the students.
#' @param category The forum category.
#' @return \code{forum_searches} The filtered forum searches dataframe.
#' @export
#' @examples
#' calculate_forum_searches(wrangled_forum_searches, "under_30_min", "female", "verified", "Part 3")
calculate_forum_searches <-
  function(forum_searches = wrangled_forum_searches,
           forum_elements,
           activity_level,
           gender,
           registration_status,
           category) {
    # Filter by the selected demographics.
    filtered <- apply_forum_filters(
      input_df = forum_searches,
      forum_elements = forum_elements,
      activity_level = activity_level,
      gender = gender,
      registration_status = registration_status,
      category = category
    )

    # If the filtered data still contains students...
    if (dim(filtered)[1] != 0) {
      # Count the number of unique users for each search query.
      forum_searches <- filtered %>%
        group_by(`Search Query` = search_query) %>%
        summarize(`Unique Users` = n_distinct(user_id)) %>%
        arrange(desc(`Unique Users`))

      return(forum_searches)

    } else {
      forum_searches <- NULL

      return(forum_searches)

    }

  }


#' Get the options for the subcategory options, given the selected category.
#' @param category The selected category.
#' @param filtered_forum_elements The forum elements dataframe, filtered by the selected category.
#' @return \code{subcategory_options} A list of options for the user to select from.
#' @export
#' @examples
#' get_subcategory_options("Part 1", filtered_forum_elements)
get_subcategory_options <- function(category,
                                    filtered_forum_elements) {
  subcategory_options <- c("All")

  if (category == "All") {
    subcategory_options <- append(subcategory_options,
                                  as.character(unique(
                                    filtered_forum_elements$discussion_category
                                  )))

    return(subcategory_options)

  } else {
    subcategory_options <- append(subcategory_options,
                                  as.character(filtered_forum_elements$display_name))

    return(subcategory_options)

  }

}


#' Update the post, view, and author counts for the selected filters.
#' @param forum_posts The forum posts dataframe passed in from the wrangling script.
#' @param forum_views The forum views dataframe passed in from the wrangling script.
#' @param forum_elements The forum elements dataframe passed in from the wrangling script.
#' @param activity_level The activity level of the students.
#' @param gender The gender of the students.
#' @param registration_status The registration status of the students.
#' @param category The forum category.
#' @return \code{filtered_forum_data} A dataframe with one row per subcategory (or category), and counts for each variable.
#' @export
#' @examples
#' update_forum_data(wrangled_forum_posts, wrangled_forum_views, filtered_forum_elements(), "over_5_hr", "other", "audit", "All")
update_forum_data <- function(forum_posts,
                              forum_views,
                              forum_elements,
                              activity_level,
                              gender,
                              registration_status,
                              category) {
  withProgress(message = "Filtering forum data.", value = 0, {
    incProgress(1 / 7, detail = "Applying filters.")

    # Filter the posts.
    filtered_posts <- apply_forum_filters(
      forum_posts,
      forum_elements = forum_elements,
      activity_level = activity_level,
      gender = gender,
      registration_status = registration_status,
      category = category
    )

    incProgress(1 / 7, detail = "Counting posts.")

    # If no students are left, return forum_elements with zeros filled in.
    if (dim(filtered_posts)[1] == 0) {
      post_counts <- forum_elements
      post_counts$posts <- 0
      post_counts$Discussion <- 0
      post_counts$Question <- 0
      post_counts$Response <- 0
      post_counts$Comment <- 0


      # Otherwise...
    } else {
      # Count the posts.
      post_counts <- filtered_posts %>%
        count_posts(wrangled_forum_elements = forum_elements) %>%
        filter(!is.na(posts))

    }

    incProgress(1 / 7, detail = "Counting authors.")

    # If no students are left, return forum_elements with zeros filled in.
    if (dim(filtered_posts)[1] == 0) {
      author_counts <- forum_elements
      author_counts$authors <- 0

    } else {
      # Count the authors.
      author_counts <- filtered_posts %>%
        count_authors(wrangled_forum_elements = forum_elements) %>%
        filter(!is.na(authors))

    }

    incProgress(1 / 7, detail = "Counting views.")

    # Filter the views.
    filtered_views <- apply_forum_filters(
      forum_views,
      forum_elements = forum_elements,
      activity_level = activity_level,
      gender = gender,
      registration_status = registration_status,
      category = category
    )

    # If no students are left, return forum_elements with zeros filled in.
    if (dim(filtered_views)[1] == 0) {
      view_counts <- forum_elements
      view_counts$views <- 0

      # Otherwise...
    } else {
      # Count the views
      view_counts <- filtered_views %>%
        count_views(wrangled_forum_elements = forum_elements) %>%
        filter(!is.na(views))

    }

    incProgress(1 / 7, detail = "Joining posts, authors, and views.")

    # Join posts and views.
    joined_forum_data <- post_counts %>%
      left_join(author_counts) %>%
      left_join(view_counts)

    # Join with forum elements in case there are no students left.
    updated_forum_data <-
      left_join(forum_elements, joined_forum_data)

    # Set NA values to 0.
    updated_forum_data$posts[is.na(updated_forum_data$posts)] <-
      0
    updated_forum_data$Discussion[is.na(updated_forum_data$Discussion)] <-
      0
    updated_forum_data$Question[is.na(updated_forum_data$Question)] <-
      0
    updated_forum_data$Response[is.na(updated_forum_data$Response)] <-
      0
    updated_forum_data$Comment[is.na(updated_forum_data$Comment)] <-
      0
    updated_forum_data$authors[is.na(updated_forum_data$authors)] <-
      0
    updated_forum_data$views[is.na(updated_forum_data$views)] <-
      0

    incProgress(1 / 7, detail = "Checking if all categories are selected.")

    if (category == "All") {
      updated_forum_data <- updated_forum_data %>%
        group_by(discussion_category) %>%
        summarize(
          course_order = min(course_order),
          posts = sum(posts, na.rm = TRUE),
          Discussion = sum(Discussion, na.rm = TRUE),
          Question = sum(Question, na.rm = TRUE),
          Response = sum(Response, na.rm = TRUE),
          Comment = sum(Comment, na.rm = TRUE),
          authors = sum(authors, na.rm = TRUE),
          views = sum(views, na.rm = TRUE)
        )

    }


    incProgress(1 / 7, detail = "Done.")

    return(updated_forum_data)

  })

}


#' Filter the wordcloud data by the selected filters.
#' @param forum_words The forum words dataframe passed in from the wrangling script.
#' @param forum_elements The forum elements dataframe.
#' @param activity_level The activity level of the students.
#' @param gender The gender of the students.
#' @param registration_status The registration status of the students.
#' @param category The forum category.
#' @return \code{filtered_wordcloud_data} The filtered forum words dataframe.
#' @examples
#' filter_wordcloud_data(wrangled_forum_words, forum_elements, "30_min_to_5_hr", "female", "All", "General")
filter_wordcloud_data <- function(forum_words,
                                  forum_elements,
                                  activity_level,
                                  gender,
                                  registration_status,
                                  category) {
  withProgress(message = "Filtering wordcloud data.", value = 0, {
    filtered_wordcloud_data <- apply_forum_filters(
      forum_words,
      forum_elements = forum_elements,
      activity_level = activity_level,
      gender = gender,
      registration_status = registration_status,
      category = category
    )
    incProgress(1, detail = "Done.")

    return(filtered_wordcloud_data)

  })

}


#' Specify which subcategory has been selected.
#' @param updated_forum_data The dataframe containing the counts for each (sub)category.
#' @param category The selected category.
#' @param selected_subcategory The selected subcategory.
#' @return \code{forum_w_selection} The same dataframe with a new column, \code{selected}.
#' @examples
#' specify_forum_data_selection(updated_forum_data, "Part 1", "Part 1 Video Discussion")
specify_forum_data_selection <- function(updated_forum_data,
                                         category,
                                         selected_subcategory) {
  forum_w_selection <- updated_forum_data

  # Set the selection to FALSE by default.
  forum_w_selection$selected <- "FALSE"

  if (category == "All") {
    # If there is a selection match, set it to TRUE.
    forum_w_selection$selected[forum_w_selection$discussion_category == selected_subcategory] <-
      "TRUE"

  } else {
    # If there is a selection match, set it to TRUE.
    forum_w_selection$selected[forum_w_selection$display_name == selected_subcategory] <-
      "TRUE"

  }

  # And if there is no selection, set everything to TRUE.
  if (selected_subcategory == "All") {
    forum_w_selection$selected <- "TRUE"
  }

  return(forum_w_selection)

}


#' Set the title of the main barplot, according to the relevant variable and category.
#' @param plot_variable One of (default) \code{posts}, \code{authors}, or \code{views}.
#' @return \code{forum_plot_title} A string for the plot title.
#' @examples
#' set_forum_plot_title("views", "Part 1")
set_forum_plot_title <- function(plot_variable,
                                 category) {
  if (plot_variable == "posts") {
    if (category == "All") {
      forum_plot_title <- "Post counts all categories"

      return(forum_plot_title)

    } else {
      forum_plot_title <- paste0("Post counts in ", tags$em(category))

      return(forum_plot_title)

    }

  } else if (plot_variable == "authors") {
    if (category == "All") {
      forum_plot_title <- "Author counts all categories"

      return(forum_plot_title)

    } else {
      forum_plot_title <- paste0("Author counts in ", tags$em(category))

      return(forum_plot_title)

    }

  } else {
    if (category == "All") {
      forum_plot_title <- "View counts in all categories"

      return(forum_plot_title)

    } else {
      forum_plot_title <- paste0("View counts in ", tags$em(category))

      return(forum_plot_title)

    }
  }

}


#' Set the label of the y-axis in the main barplot.
#' @param plot_variable One of (default) \code{posts}, \code{authors}, or \code{views}.
#' @return \code{forum_plot_ylabe} The label of the y-axis in the main barplot.
#' @examples
#' set_forum_plot_ylabel("authors")
set_forum_plot_ylabel <- function(plot_variable) {
  if (plot_variable == "posts") {
    forum_plot_ylabel <- "Posts"

    return(forum_plot_ylabel)

  } else if (plot_variable == "authors") {
    forum_plot_ylabel <- "Authors"

    return(forum_plot_ylabel)

  } else {
    forum_plot_ylabel <- "Views"

    return(forum_plot_ylabel)

  }

}


#' Get the counts of each word in the selected subcategories.
#' @param filtered_wordcloud_data The filtered forum words dataframe.
#' @param filtered_forum_elements The filtered forum elements dataframe.
#' @param category The selected category.
#' @param selected_subcategory The selected subcategory.
#' @return \code{wordcloud_data} A dataframe with the counts of each word in the selected subcategory(ies).
#' @export
#' @examples
#' get_wordcloud_data(filtered_wordcloud_data, filtered_forum_elements, "Part 1", "Part 1 Lecture 1 Discussion")
get_wordcloud_data <- function(filtered_wordcloud_data,
                               filtered_forum_elements,
                               category,
                               selected_subcategory) {
  withProgress(message = "Counting words in filtered wordcloud data.",
               value = 0, {
    # If there are no students left...
    if (dim(filtered_wordcloud_data)[1] == 0) {
      wordcloud_data <- filtered_forum_elements
      wordcloud_data$word <- "placeholder"
      wordcloud_data$n <- 0

      incProgress(1, detail = "Done.")

      return(wordcloud_data)

    } else {
      # If no category has been selected...
      if (category == "All") {
        wordcloud_data <- filtered_wordcloud_data %>%
          group_by(word) %>%
          count(sort = TRUE) %>%
          mutate(n = n / dim(filtered_wordcloud_data)[1])

        incProgress(1, detail = "Done.")

        return(wordcloud_data)

      } else {
        if (selected_subcategory == "All") {
          filtered_selected <- filtered_wordcloud_data

        } else {
          filtered_selected <- filtered_wordcloud_data %>%
            filter(display_name == selected_subcategory)

        }

        # If the selected subcategory has no words in it...
        if (dim(filtered_selected)[1] == 0) {
          wordcloud_data <- filtered_forum_elements
          wordcloud_data$word <-
            "placeholder"
          wordcloud_data$n <- 0

          if (category == "All") {
            wordcloud_data <- wordcloud_data %>%
              filter(discussion_category == selected_subcategory)

          } else {
            wordcloud_data <- wordcloud_data %>%
              filter(display_name == selected_subcategory)

          }

          incProgress(1, detail = "Done.")

          return(wordcloud_data)

        } else {
          wordcloud_data <- filtered_selected %>%
            group_by(word) %>%
            count(sort = TRUE) %>%
            mutate(n = n / dim(filtered_selected)[1])
          incProgress(1, detail = "Done.")

          return(wordcloud_data)

        }

      }

    }

  })

}


#' Set the title of the wordcloud.
#' @param category The selected category.
#' @param selected_subcategory The selected subcategory.
#' @return \code{wordcloud_title} A string for the wordcloud title.
#' @examples
#' set_wordcloud_title("Part 3", "All")
set_wordcloud_title <- function(category,
                                selected_subcategory) {
  if (category == "All") {
    wordcloud_title <- "Most used words in all categories"

    return(wordcloud_title)

  } else {
    if (selected_subcategory == "All") {
      wordcloud_title <- paste0("Most used words in ", tags$em(category))

      return(wordcloud_title)

    } else {
      wordcloud_title <-
        paste0("Most used words in ", tags$em(selected_subcategory))

      return(wordcloud_title)

    }
  }

}


#' Set the title of the forum threads table.
#' @param category The selected category.
#' @param selected_subcategory The selected subcategory.
#' @return \code{forum_threads_title} A string for the title of the forum threads table.
#' @examples
#' set_forum_threads_title("Part 3", "All")
set_forum_threads_title <- function(category,
                                    selected_subcategory) {
  if (category == "All") {
    forum_threads_title <- "Threads in all categories"

    return(forum_threads_title)

  } else {
    if (selected_subcategory == "All") {
      forum_threads_title <- paste0("Threads in ", tags$em(category))

      return(forum_threads_title)

    } else {
      forum_threads_title <-
        paste0("Threads in ", tags$em(selected_subcategory))

      return(forum_threads_title)

    }
  }

}


#' Get the lengths of the labels on the main barplot (either the categories or the subcategories).
#' @param forum_data The forum data for the main barplot.
#' @param category The selected category.
#' @return \code{label_lengths} A list with the lengths (in characters) of each label on the main plot.
#' @export
#' @examples
#' get_label_lengths(forum_data, "Technical Questions")
get_label_lengths <- function(forum_data,
                              category) {
  if (category == "All") {
    label_lengths <- nchar(as.character(forum_data$discussion_category))

    return(label_lengths)

  } else {
    label_lengths <- nchar(as.character(forum_data$display_name))

    return(label_lengths)

  }

}


#' Set the horizontal axis limit of the main barplot.
#' @param forum_data The forum data for the main barplot.
#' @param plot_variable One of (default) \code{posts}, \code{authors}, or \code{views}.
#' @param label_lengths A list containing the lengths (in characters) of each label on the barplot.
#' @param min_axis_length The axis length to set if all the values are set to zero (i.e. all students have been filtered out). Default is 0.1 so that the axis is minimally affected when values are small.
#' @param percent_addition_per_char The percentage by which to expand the axis per character in the label of the longest bar. Default is 0.023 because that tends to look good.
#' @return \code{axis_limit} The maximum axis limit for the horizontal axis in the main barplot.
#' @examples
#' set_axis_limit(forum_data, "views", c(15,12,14,7))
#' @details
#' Usually, the variance in bar lengths is greater than the variance in label lengths.
#' If this is not the case, it is possible that the axis limit will need to be expanded further.
#' For example, the second-longest bar may have a label that is twice as long as the label of the longest bar.
#' In the future, it will be desirable to account for these cases.
#' @export
set_axis_limit <- function(forum_data,
                           plot_variable,
                           label_lengths,
                           min_axis_length = 0.1,
                           percent_addition_per_char = 0.023) {
  # Get the lenghts of the bars.
  bar_lengths <- forum_data[plot_variable]

  # Get the longest length.
  max_bar_length <- max(bar_lengths)

  # Get the length of the label of the longest bar.
  if (max_bar_length != 0) {
    # If there are many longest bars, take the longest label of those bars
    label_longest <-
      max(label_lengths[bar_lengths == max_bar_length])

  } else {
    label_longest <- max(label_lengths)

  }

  axis_limit <-
    max_bar_length + (max_bar_length *
                        percent_addition_per_char *
                        label_longest) + min_axis_length

  return(axis_limit)

}


#' Get the function to pass into the x value of aes_string() in the main barplot.
#' @param category The selected category.
#' @return \code{reactive_xvar_string} A string that matches the function to call for the x value of aes_string().
#' @examples
#' get_reactive_xvar_string("Part 2")
get_reactive_xvar_string <- function(category) {
  if (category == "All") {
    reactive_xvar_string <-
      "forcats::fct_reorder(discussion_category, course_order, .desc = TRUE)"

    return(reactive_xvar_string)

  } else {
    reactive_xvar_string <-
      "forcats::fct_reorder(display_name, course_order, .desc = TRUE)"

    return(reactive_xvar_string)

  }

}


#' Set the fill value of the bars in the main barplot, given the plot variable.
#' @param plot_variable One of (default) \code{posts}, \code{authors}, or \code{views}.
#' @return \code{fill_value} A hex value representing the color for the bar fill.
#' @examples
#' set_fill_value("views")
set_fill_value <- function(plot_variable) {
  if (plot_variable == "posts") {
    # Orange
    fill_value <- "#fdc086"

  } else if (plot_variable == "authors") {
    # Purple
    fill_value <- "#beaed4"

  } else {
    # Red
    fill_value <- "#fb8072"

  }

  return(fill_value)

}


#' Make the main barplot for displaying the forum data.
#' @param forum_data The forum data for the main barplot.
#' @param xvar_string A string that matches the function to call for the x value of aes_string().
#' @param plot_variable One of (default) \code{posts}, \code{authors}, or \code{views}.
#' @param fill_value A hex value representing the color for the bar fill.
#' @param axis_limit The maximum axis limit for the horizontal axis in the main barplot.
#' @param category The selected category.
#' @param ylabel The label of the y-axis in the main barplot.
#' @param breakdown One of \code{TRUE} or \code{FALSE}; determines whether the post types breakdown is shown.
#' @return \code{forum_barplot} A ggplot2 object to be rendered as the main forum barplot.
#' @export
#' @examples
#' make_forum_barplot(forum_data, xvar_string = "fct_reorder(discussion_category, course_order, .desc = TRUE)", plot_variable = "authors", fill_value = "red", axis_limit = 100, category = "All", ylabel = "Category", breakdown = FALSE)
make_forum_barplot <- function(forum_data,
                               xvar_string,
                               plot_variable,
                               fill_value,
                               axis_limit,
                               category,
                               ylabel,
                               breakdown) {
  # Set the alpha values of the selected vs unselected subcategories.
  alphas <- c("FALSE" = 0.3, "TRUE" = 0.8)

  if (category == "All") {
    grouping_var <- "discussion_category"
    xlabel <- "Category"

  } else {
    grouping_var <- "display_name"
    xlabel <- "Subcategory"

  }

  if (breakdown == TRUE) {
    gathered <- gather_post_types(forum_data = forum_data,
                                  grouping_var = grouping_var)

    forum_barplot <-
      make_forum_breakdown_barplot(
        gathered = gathered,
        xvar_string = xvar_string,
        grouping_var = grouping_var,
        axis_limit = axis_limit,
        xlabel = xlabel
      )

  } else {
    forum_barplot <- ggplot(forum_data,
                            aes_string(x = xvar_string,
                                       y = plot_variable,
                                       alpha = "selected")) +
      geom_bar(stat = "identity", fill = fill_value) +
      geom_text(aes_string(label = plot_variable, hjust = "0")) +
      geom_text(
        mapping = aes_string(
          y = "Inf",
          label = grouping_var,
          hjust = "1"
        ),
        color = "black",
        alpha = 1
      ) +
      scale_alpha_manual(values = alphas) +
      scale_y_continuous(limits = c(0, axis_limit), position = "right") +
      guides(color = FALSE) +
      coord_flip() +
      ggthemes::theme_few(base_family = "GillSans") +
      theme(
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        legend.position = "none"
      ) +
      ylab(ylabel) +
      xlab(xlabel)

  }

  return(forum_barplot)

}


#' Gather the post types into a single column for easy plotting.
#' @param forum_data The forum data for the main barplot.
#' @param grouping_var grouping_var One of \code{discussion_category} or \code{display_name}, depending on whether a category has been selected.
#' @return \code{gathered} A dataframe with the post types gathered into a single column.
#' @export
#' @examples
#' gather_post_types(forum_data, grouping_var = "discussion_category")
gather_post_types <- function(forum_data,
                              grouping_var) {
  gathered <- forum_data %>%
    tidyr::gather(key = `Post Type`,
                  value = count,
                  Comment,
                  Discussion,
                  Question,
                  Response) %>%
    mutate(tot_posts = posts) %>%
    select(-posts)

  gathered$`Post Type` <- as.character(gathered$`Post Type`)
  gathered$`Post Type` <- factor(gathered$`Post Type`,
                                 levels = c("Comment", "Response",
                                            "Question", "Discussion"))

  return(gathered)

}


#' Make the main forum barplot with the post types breakdown.
#' @param forum_data The forum data for the main barplot.
#' @param xvar_string A string that matches the function to call for the x value of aes_string().
#' @param grouping_var grouping_var One of \code{discussion_category} or \code{display_name}, depending on whether a category has been selected.
#' @param axis_limit The maximum axis limit for the horizontal axis in the main barplot.
#' @param xlabel The label of the x-axis in the main barplot.
#' @return \code{forum_breakdown_barplot} A ggplot2 object to be rendered as the main forum barplot.
#' @export
#' @examples
#' make_forum_breakdown_barplot(forum_data = forum_data, xvar_string = "fct_reorder(discussion_category, course_order, .desc = TRUE)", axis_limit = 100, grouping_var = "discussion_category", xlabel = "Category")
make_forum_breakdown_barplot <- function(gathered,
                                         xvar_string,
                                         grouping_var,
                                         axis_limit,
                                         xlabel) {
  # Set the alpha values of the selected vs unselected subcategories.
  alphas <- c("FALSE" = 0.3, "TRUE" = 0.8)

  forum_breakdown_barplot <- ggplot(
    gathered,
    aes_string(
      x = xvar_string,
      y = "count",
      alpha = "selected",
      fill = "`Post Type`"
    )
  ) +
    geom_bar(stat = "identity") +
    geom_text(aes(y = tot_posts, label = tot_posts, hjust = 0), alpha = 0.25) +
    geom_text(
      mapping = aes_string(y = "Inf", label = grouping_var, hjust = "1"),
      color = "black",
      alpha = 0.25
    ) +
    scale_alpha_manual(values = alphas) +
    scale_y_continuous(limits = c(0, axis_limit), position = "right") +
    guides(alpha = FALSE, fill = guide_legend(nrow = 1, reverse = TRUE)) +
    coord_flip() +
    ggthemes::theme_few(base_family = "GillSans") +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      legend.position = "top"
    ) +
    ylab("Posts") +
    xlab(xlabel)

  return(forum_breakdown_barplot)

}


#' Get the number of authors for which the selected filter settings apply.
#' @param forum_posts The forum posts dataframe that was passed in from the wrangling script.
#' @param forum_elements The forum elements dataframe.
#' @param activity_level The activity level of the students.
#' @param gender The gender of the students.
#' @param registration_status The registration status of the students.
#' @param category The forum category.
#' @return \code{author_count} A string showing the number of authors.
#' @examples
#' get_author_count(wrangled_forum_posts, forum_elements, "All", "male", "verified", "All")
get_author_count <- function(forum_posts,
                             forum_elements,
                             activity_level,
                             gender,
                             registration_status,
                             category) {
  authors <- apply_forum_filters(
    forum_posts,
    forum_elements = forum_elements,
    activity_level = activity_level,
    gender = gender,
    registration_status = registration_status,
    category = category
  )

  author_count <-
    paste0(length(unique(authors$author_id)), " authors")

  return(author_count)

}


#' Get the number of viewers for which the selected filter settings apply.
#' @param forum_views The forum views dataframe that was passed in from the wrangling script.
#' @param forum_elements The forum elements dataframe.
#' @param activity_level The activity level of the students.
#' @param gender The gender of the students.
#' @param registration_status The registration status of the students.
#' @param category The forum category.
#' @return \code{author_count} A string showing the number of authors.
#' @examples
#' get_viewer_count(wrangled_forum_views, forum_elements, "All", "male", "verified", "All")
get_viewer_count <- function(forum_views,
                             forum_elements,
                             activity_level,
                             gender,
                             registration_status,
                             category) {
  viewers <- apply_forum_filters(
    forum_views,
    forum_elements = forum_elements,
    activity_level = activity_level,
    gender = gender,
    registration_status = registration_status,
    category = category
  )

  viewer_count <-
    paste0(length(unique(viewers$user_id)), " viewers")

  return(viewer_count)

}


#' Make the wordcloud.
#' @param wordcloud_data A dataframe showing the counts of the top words in the selected subcategory.
#' @param max_words The maximum number of words to show in the wordcloud. Default is 20.
#' @param scale A list giving the range of sizes to for the display of words in the wordcloud. Default is c(3.5,1).
#' @return A wordcloud object.
#' @export
#' @examples
#' make_wordcloud(wordcloud_data, max_words = 30, scale = c(4,1.5))
make_wordcloud <- function(wordcloud_data,
                           max_words = 20,
                           scale = c(3.5, 1)) {
  if (sum(wordcloud_data$n, na.rm = TRUE) == 0) {
    wordcloud <- NULL

  } else {
    wordcloud <- wordcloud::wordcloud(
      wordcloud_data$word,
      freq = wordcloud_data$n,
      max.words = max_words,
      random.order = F,
      rot.per = 0,
      scale = scale
    )
  }

  return(wordcloud)

}


#' Get the forum threads for the authors who match the filter settings.
#' @param forum_posts The forum posts dataframe that was passed in from the wrangling script.
#' @param forum_elements The forum elements dataframe.
#' @param activity_level The activity level of the students.
#' @param gender The gender of the students.
#' @param registration_status The registration status of the students.
#' @param category The selected forum category.
#' @param selected_subcategory The selected forum subcategory.
#' @return \code{forum_threads} The forum threads that were authored by students for which the filter settings apply.
#' @export
#' @examples
#' get_forum_threads(forum_posts = wrangled_forum_posts, forum_elements, "over_5_hr", "female", "audit", "All", "All")
get_forum_threads <- function(forum_posts,
                              forum_elements,
                              activity_level,
                              gender,
                              registration_status,
                              category,
                              selected_subcategory) {
  # Filter the threads.
  filtered_posts <- forum_posts %>%
    apply_forum_filters(
      forum_elements = forum_elements,
      activity_level = activity_level,
      gender = gender,
      registration_status = registration_status,
      category = category
    ) %>%
    filter(type != "Response",
           type != "Comment")

  # If none are selected...
  if (category == "All") {
    # And if there are still students left after filtering.
    if (dim(filtered_posts)[1] != 0) {
      forum_threads <- filtered_posts %>%
        select(
          Subcategory = display_name,
          ## Select the variables to be displayed in the table.
          Author = author_id,
          Text = body,
          Views = views,
          Responses = responses,
          Comments = comments
        ) %>%
        arrange(desc(Views))

    } else {
      forum_threads <- NULL

    }

  } else {
    ## Otherwise...

    if (selected_subcategory == "All") {
      filtered_selected <- filtered_posts


    } else {
      filtered_selected <- filtered_posts %>%
        filter(display_name == selected_subcategory)

    }

    # If the subcategory is not empty...
    if (dim(filtered_selected)[1] != 0) {
      forum_threads <- filtered_selected %>%
        select(
          Subcategory = display_name,
          ## Select the variables to be displayed in the table.
          Author = author_id,
          Text = body,
          Views = views,
          Responses = responses,
          Comments = comments
        ) %>%
        arrange(desc(Views))

    } else {
      forum_threads <- NULL

    }

  }

  return(forum_threads)

}
