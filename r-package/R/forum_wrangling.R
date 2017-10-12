#' Write the forum posts and forum words to csv.
#'
#' @param posts_input_path The path to the CSV file containing the forum posts data.
#' @param views_input_path The path to the CSV file containing the forum reads data.
#' @param searches_input_path The path to the CSV file containing the forum searches data.
#' @param json_input_path The path to the JSON file containing data on all course elements.
#' @param xml_input_path The path to the XML file containing data on the course structure.
#' @param posts_output_path The desired path to which to write the prepared forum posts dataframe.
#' @param words_output_path The desired path to which to write the prepared forum words dataframe.
#' @param views_output_path The desired path to which to write the prepared forum views dataframe.
#' @param searches_output_path The desired path to which to write the prepared forum searches dataframe.
#' @param elements_output_path The desired path to which to write the prepared forum elements dataframe.
#' @return None.
#' @export
#' @examples
#' wrangle_forum(csv_path, json_path, xml_path)
wrangle_forum <- function(posts_input_path,
                          views_input_path,
                          searches_input_path,
                          json_input_path,
                          xml_input_path,
                          posts_output_path,
                          words_output_path,
                          views_output_path,
                          searches_output_path,
                          elements_output_path) {

        # Read in the necessary files.
        print("Reading in the necessary files...")
        forum_posts <- read_csv(file = posts_input_path)
        forum_views <- read_csv(file = views_input_path)
        forum_searches <- read_csv(file = searches_input_path)
        course_json <- jsonlite::fromJSON(txt = json_input_path)
        course_xml <- tryCatch({
                xmlInternalTreeParse(file = xml_input_path)
        }, error = function(e) {
                # In case the XML is malformed.
                print("XML is malformed. Using htmlInternalTreeParse.")
                XML::htmlTreeParse(file = xml_input_path, useInternalNodes = TRUE)
        })

        # Prepare the forum views data.
        print("Preparing the forum views data...")
        forum_views <- prepare_views(forum = forum_views)

        # Prepare the forum posts data.
        print("Preparing the forum posts data...")
        forum_posts <- prepare_posts(forum = forum_posts)

        # Add the views variable to the posts.
        forum_posts <- forum_views %>%
                group_by(comment_thread_id) %>%
                count() %>%
                ungroup() %>%
                mutate(views = n) %>%
                select(comment_thread_id,
                       views) %>%
                right_join(forum_posts, by = c("comment_thread_id" = "mongoid")) %>%
                mutate(mongoid = comment_thread_id,
                       comment_thread_id = comment_thread_id.y) %>%
                select(-comment_thread_id.y)
        
        # For the posts that had no views, set views to zero.
        forum_posts$views[is.na(forum_posts$views)] <- 0

        # Prepare the forum words data.
        print("Preparing the forum words data...")
        forum_words <- prepare_words(forum = forum_posts)

        # Prepare the forum searches data.
        print("Preparing the forum searches data...")
        wrangled_forum_searches <- prepare_searches(forum = forum_searches)

        # Prepare the JSON elements.
        print("Preparing the JSON elements...")
        forum_elements_json <- prepare_json(json = course_json)

        # Prepare the XML elements.
        print("Preparing the XML elements...")
        forum_elements_xml <- prepare_xml(xml = course_xml)

        # The JSON file will have more dimensions than the JSON file, because it took the `discussion_topics` as well
        # as the discussion_category/discussion_target pairs. Get that difference in dimensions.
        extra_dim <- dim(forum_elements_json)[1] - dim(forum_elements_xml)[1]

        # Store only those extra topics.
        extra_topics <- forum_elements_json[!forum_elements_json$display_name %in% forum_elements_xml$display_name, ]

        # Assign their orders and remove the superfluous column.
        extra_topics$target_order <- 1:extra_dim
        extra_topics$category_order <- 1:extra_dim
        extra_topics <- extra_topics %>%
                select(-commentable_id)

        # Add the extra order numbers to the XML data.
        forum_elements_xml <- forum_elements_xml %>%
                mutate(category_order = category_order + extra_dim,
                       target_order = target_order + extra_dim)

        # Row-bind the xml with the extra topics from the JSON.
        forum_elements_xml <- rbind(extra_topics, forum_elements_xml)

        # Combine the JSON elements and the XML elements.
        print("Combining the JSON and XML elements...")
        wrangled_forum_elements <- left_join(forum_elements_json, forum_elements_xml) %>%
                arrange(target_order) %>%
                # Keep only the ones that have been assigned a target order.
                filter(!is.na(target_order)) %>%
                # Keep only the ones that actually appear in the data.
                filter(commentable_id %in% as.character(levels(forum_posts$commentable_id)))

        # Add a variable which corresponds with the order in which the subcategories will be plotted.
        print("Adding the course order to forum_elements...")
        wrangled_forum_elements$course_order <- 1:dim(wrangled_forum_elements)[1]

        # Combine the posts with the forum_elements.
        print("Joining everything with forum elements...")
        wrangled_forum_posts <- left_join(forum_posts, wrangled_forum_elements)

        # Reorder the variables in wrangled_forum_posts so they're easier to read by a human.
        wrangled_forum_posts <- wrangled_forum_posts %>%
                select(author_id,
                       author_username,
                       gender,
                       registration_status,
                       activity_level,
                       mongoid,
                       type,
                       commentable_id,
                       comment_thread_id,
                       parent_id,
                       responses,
                       comments,
                       views,
                       discussion_category,
                       category_order,
                       discussion_target,
                       target_order,
                       display_name,
                       course_order,
                       title,
                       body)

        # Combine the forum words with the forum elements.
        wrangled_forum_words <- left_join(forum_words, wrangled_forum_elements)

        # Keep only the necessary variables.
        wrangled_forum_words <- wrangled_forum_words %>%
                select(activity_level,
                       gender,
                       registration_status,
                       discussion_category,
                       display_name,
                       word)

        # Combine the forum views with the forum elements.
        wrangled_forum_views <- left_join(forum_views, wrangled_forum_elements)

        # Write each dataframe to csv.
        print("Saving everything to CSV...")
        readr::write_csv(x =  wrangled_forum_posts, path = posts_output_path)
        write_csv(x = wrangled_forum_words, path = words_output_path)
        write_csv(x = wrangled_forum_views, path = views_output_path)
        write_csv(x = wrangled_forum_searches, path = searches_output_path)
        write_csv(x = wrangled_forum_elements, path = elements_output_path)

        print("Complete. `wrangled_forum_posts`, `wrangled_forum_words`, `wrangled_forum_views`, `wrangled_forum_searches`, and `wrangled_forum_elements` have been saved to csv.")
}


#' Prepare the forum views dataframe.
#'
#' @param forum A dataframe with one read event per row.
#' @return The prepared forum views data.
#' @examples
#' prepare_views(forum)
prepare_views <- function(forum) {

        # Get the activity level of the users.
        forum_views <- forum %>%
                get_activity_levels()

        # Add an event ID, just in case.
        forum_views$event_id <- 1:dim(forum_views)[1]

        return(forum_views)
}


#' Prepare the forum posts.
#'
#' @param forum A dataframe with one post per row.
#' @return The prepared forum posts data.
#' @examples
#' prepare_posts(forum)
#' @export
prepare_posts <- function(forum) {

        # Change the text from factor to character.
        forum$body <- as.character(forum$body)

        # Get the activity level of the users.
        print("     Getting activity levels...")
        forum_w_activity_levels <- forum %>%
                get_activity_levels()

        # Mutate and add a column that says initial post, response post, and comment
        print("     Getting post types...")
        forum_w_post_types <- forum_w_activity_levels %>%
                get_post_types()

        # Link response posts back to initial posts to get their commentable_id.
        print("     Inferring post subcategories...")
        forum_w_inferred_subcategories <- forum_w_post_types %>%
                infer_post_subcategories()

        # Rename the post types once more to distinguish between discussions and questions.
        forum_posts <- forum_w_inferred_subcategories %>% mutate(type = case_when(
                .$post_type == "initial_post" & .$initial_post_type == "discussion" ~ "Discussion",
                .$post_type == "initial_post" & .$initial_post_type == "question" ~ "Question",
                .$post_type == "response_post" ~ "Response",
                .$post_type == "comment_post" ~ "Comment"
        )) %>%
                select(-post_type)

        return(forum_posts)
}


#' Convert sum_dt to activity_level.
#'
#' @param forum A forum dataframe.
#' @return The same dataframe with a new column for activity_level.
#' @examples
#' get_activity_levels(forum)
#' @export
get_activity_levels <- function(forum) {

        # Get the activity level of the users.
        forum_w_activity_levels <- forum %>%
                mutate(activity_level = case_when(

                        (.$sum_dt < 1800) ~ "under_30_min",
                        (.$sum_dt >= 1800) & (.$sum_dt < 18000) ~ "30_min_to_5_hr",
                        (.$sum_dt >= 18000) ~ "over_5_hr",
                        is.na(.$sum_dt) ~ "NA"

                )) %>%
                select(-sum_dt)

        return(forum_w_activity_levels)

}


#' Get the post types.
#'
#' @param forum A forum dataframe.
#' @return The same dataframe with a new column for post_type.
#' @examples
#' get_post_types(forum)
#' @export
get_post_types <- function(forum) {

        forum_w_post_types <- forum %>% mutate(post_type = case_when(
                .$bq_post_type == "CommentThread" ~ "initial_post",
                (.$bq_post_type == "Comment") & (is.na(.$parent_id) == TRUE) ~ "response_post",
                (.$bq_post_type == "Comment") & (is.na(.$parent_id) == FALSE) ~ "comment_post"

        ))

        forum_w_post_types <- forum_w_post_types %>%
                select(-bq_post_type)

        return(forum_w_post_types)

}


#' Infer the subcategories of each post, even if it's a response post or a comment.
#'
#' @param forum A forum dataframe.
#' @return The same dataframe with commentable_id filled in for everything.
#' @examples
#' infer_post_subcategories(forum)
#' @export
infer_post_subcategories <- function(forum) {

        # Get only the initial posts.
        initial_posts <- forum %>%
                filter(post_type == "initial_post")
        
        # Remove extraneous variables for the join with response posts.
        initial_posts_for_join <- initial_posts %>%
                select(mongoid, commentable_id)

        # Get only the response posts.
        response_posts <- forum %>%
                filter(post_type == "response_post")
        
        # Get only the comment posts.
        comment_posts <- forum %>%
                filter(post_type == "comment_post")

        # For each response post, map back to initial posts.
        response_posts_w_sc <- response_posts %>%
                left_join(initial_posts_for_join, by = c("comment_thread_id" = "mongoid")) %>%
                mutate(commentable_id = commentable_id.y) %>%
                select(-commentable_id.x, -commentable_id.y)
        
        # Remove extraneous columns for the join with comment posts.
        response_posts_w_sc_for_join <- response_posts_w_sc %>%
                select(mongoid, commentable_id)

        # For each comment post, map back to response posts.
        comment_posts_w_sc <- comment_posts %>%
                left_join(response_posts_w_sc_for_join, by = c("parent_id" = "mongoid")) %>%
                mutate(commentable_id = commentable_id.y) %>%
                select(-commentable_id.x, -commentable_id.y)
        
        # Bind them all together.
        forum_w_inferred_subcategories <- initial_posts %>%
                rbind(response_posts_w_sc) %>%
                rbind(comment_posts_w_sc)
        
        # Count the number of comments for each response post.
        print("          Counting comments...")
        comment_counts <- comment_posts_w_sc %>%
                group_by(comment_thread_id, parent_id) %>%
                summarise(comments = n_distinct(mongoid)) %>%
                ungroup() %>% 
                right_join(response_posts_w_sc_for_join, by = c("parent_id" = "mongoid")) %>% 
                mutate(initial_post_id = comment_thread_id,
                       response_post_id = parent_id) %>%
                select(-comment_thread_id, -parent_id
                       #-commentable_id.x, -commentable_id.y
                       )
        
        comment_counts$comments[is.na(comment_counts$comments)] <- 0
        
        # Count up all the responses and comments for each initial post.
        print("          Counting responses...")
        response_counts <- response_posts_w_sc %>%
                group_by(comment_thread_id) %>%
                summarise(responses = n_distinct(mongoid, na.rm = TRUE)) %>% 
                ungroup() %>% 
                right_join(initial_posts_for_join, by = c("comment_thread_id" = "mongoid")) %>%
                mutate(initial_post_id = comment_thread_id)
        
        
        print("          Replacing null response counts in response_counts with 0...")
        response_counts$responses[is.na(response_counts$responses)] <- 0
        
        comment_counts_on_init <- comment_counts %>% 
                group_by(initial_post_id) %>% 
                summarise(comments = sum(comments))
        
        both_counts <- response_counts %>% 
                left_join(comment_counts_on_init) %>% 
                mutate(mongoid = initial_post_id) %>% 
                select(-initial_post_id, -comment_thread_id)
        
        print("          Replacing null comment counts in both_counts with 0...")
        both_counts$comments[is.na(both_counts$comments)] <- 0
        
        print("          Replacing null response counts in both_counts with 0...")
        both_counts$responses[is.na(both_counts$responses)] <- 0
        
        print("          Setting responses in comment_counts to 0...")
        comment_counts$responses <- 0
        comment_counts <- comment_counts %>% 
                mutate(mongoid = response_post_id) %>% 
                select(-initial_post_id, -response_post_id)
        
        zero_counts <- comment_posts_w_sc %>% 
                select(mongoid, commentable_id)
        
        print("          Setting responses in zero_counts to 0...")
        zero_counts$responses <- 0
        
        print("          Setting comments in zero_counts to 0...")
        zero_counts$comments <- 0
        
        counts <- both_counts %>% 
                rbind(comment_counts) %>% 
                rbind(zero_counts)
        
        forum_posts <- forum_w_inferred_subcategories %>% 
                left_join(counts)

        # Wherever the number of responses or comments is NA, set to zero.
        forum_posts$responses[is.na(forum_posts$responses)] <- 0
        forum_posts$responses <- as.integer(forum_posts$responses)
        forum_posts$comments[is.na(forum_posts$comments)] <- 0
        forum_posts$comments <- as.integer(forum_posts$comments)
        
        # Convert commentable_id to a factor.
        forum_posts$commentable_id <- as.factor(forum_posts$commentable_id)

        return(forum_posts)

}


#' Prepare the forum words.
#'
#' @param forum A dataframe with one row per post.
#' @return The dataframe with each row containing a word, prepared for joining with the forum elements.
#' @examples
#' prepare_words(forum)
#' @export
prepare_words <- function(forum) {

        # Get one word per row.
        tidy_words <- forum %>%
                tidytext::unnest_tokens(word, body)

        # Remove stop words.
        forum_words <- tidy_words %>%
                anti_join(tidytext::stop_words)

        # Keep only the relevant variables.
        forum_words <- forum_words %>%
                select(activity_level,
                       gender,
                       registration_status,
                       commentable_id,
                       word)

        # Return the prepared forum words.
        return(forum_words)
}


#' Prepare the forum searches dataframe.
#'
#' @param forum A dataframe with one search event per row.
#' @return The forum searches data with a new column for activity level.
#' @examples
#' prepare_searches(forum)
#' @export
prepare_searches <- function(forum) {

        # Get the activity level of the users.
        forum_searches <- forum %>%
                get_activity_levels()

        return(forum_searches)
}


#' Prepare the JSON file for joining with the XML file.
#'
#' @param json A JSON file containing information about the course elements.
#' @return A dataframe with four columns: \code{commentable_id}, \code{display_name}, \code{discussion_category}, and \code{discussion_target}.
#' @examples
#' prepare_json(json)
#' @export
prepare_json <- function(json) {

        commentable_id = c()
        display_name = c()
        discussion_category = c()
        discussion_target = c()

        for (i in 1:length(json)) {

                if ("course" %in% as.character(json[[i]])) {

                        print("Getting `discussion_topics`")

                        for (name in 1:length(names(json[[i]]$metadata$discussion_topics))) {

                                commentable_id <- append(commentable_id, as.character(json[[i]]$metadata$discussion_topics[[name]]))
                                display_name <- append(display_name, names(json[[i]]$metadata$discussion_topics[name]))
                                discussion_category <- append(discussion_category, names(json[[i]]$metadata$discussion_topics[name]))
                                discussion_target <- append(discussion_target, names(json[[i]]$metadata$discussion_topics[name]))
                        }

                }

        }

        discussion_topics <- data.frame(
                commentable_id = commentable_id,
                display_name = display_name,
                discussion_category = discussion_category,
                discussion_target = discussion_target
        )

        # As a relic of the JSON parsing, the naming of discussion_id doesn't always come out right.
        if ("id" %in% names(discussion_topics)) {
                discussion_topics <- discussion_topics %>%
                        mutate(commentable_id = id) %>%
                        select(-id)
        }

        # Apply `get_discussion_vars` across all elements of the JSON file.
        forum_elements_mat <- do.call(rbind,
                                  lapply(X = 1:length(json),
                                         FUN = get_discussion_vars_json,
                                         all_elements = json))

        # Combine into a dataframe.
        forum_elements_df <- data.frame("commentable_id" = forum_elements_mat[,1],
                                        "display_name" = forum_elements_mat[,2],
                                        "discussion_category" = forum_elements_mat[,3],
                                        "discussion_target" = forum_elements_mat[,4])

        json_forum_elements <- rbind(discussion_topics, forum_elements_df)

        # Return the forum elements dataframe.
        return(json_forum_elements)
}


#' Prepare the XML file for joining with the JSON file.
#'
#' @param xml An XML file containing information about the course elements.
#' @return A dataframe with three columns: \code{display_name}, \code{discussion_category}, and \code{discussion_target}.
#' @examples
#' prepare_xml(xml)
#' @export
prepare_xml <- function(xml) {
        # Get the discussion nodes.
        discussion_nodes <- XML::xpathApply(xml, "//discussion")

        # Get the attributes of each discussion node.
        all_parameters <- sapply(discussion_nodes, XML::xmlAttrs)

        # Get the parameters of interest and save them as a dataframe.
        if (class(all_parameters) == "list") {  ## Some course XMLs spit out a nested list of discussion node parameters.
                forum_elements_xml <- data.frame(
                        do.call(
                                rbind,
                                lapply(X = 1:length(all_parameters),
                                       FUN = get_discussion_vars_xml,
                                       all_parameters = all_parameters)
                        )
                )
        } else {  ## Other course XMLs spit out a matrix of discussion node parameters.
                forum_elements_xml <- data.frame(t(all_parameters))
        }

        # Add a variable to store the order of the discussion targets.
        forum_elements_xml$target_order <- 1:dim(forum_elements_xml)[1]

        # Add a variable to store the order of the discussion categories.
        current_cat <- forum_elements_xml$discussion_category[1]  ## Start with the first discussion category. NOTE: should fix in case first element is NA.
        current_cat_lev <- 1
        category_levels <- c()  ## Initialize a vector to store the order of the discussion categories.
        for (i in 1:dim(forum_elements_xml)[1]) {
                if (is.na(forum_elements_xml$discussion_category[i])) {  ## Sometimes a discussion category will be NA (e.g. in Creative Writing)
                        category_levels <- append(category_levels, NA)
                } else {
                        if (forum_elements_xml$discussion_category[i] != current_cat) {
                                current_cat_lev <- current_cat_lev + 1
                                current_cat <- forum_elements_xml$discussion_category[i]
                        }
                        category_levels <- append(category_levels, current_cat_lev)
                }
        }

        # Add the category ordering to the forum elements dataframe.
        forum_elements_xml$category_order <- as.integer(category_levels)

        # Return the XML forum elements.
        return(forum_elements_xml)
}


#' Get the variables associated with each forum element in the JSON file. (for use in \code{prepare_json}).
#'
#' @param i An iterator.
#' @param all_elements A nested list containing attributes for each course element.
#' @return A vector containing the \code{commentable_id}, \code{display_name}, \code{discussion_category}, and \code{discussion_target} of a course element.
#' @examples
#' get_discussion_vars_json(i, all_elements)
#' @export
get_discussion_vars_json <- function(i, all_elements){

        if ("discussion" %in% as.character(all_elements[[i]])) {
                c(all_elements[[i]]$metadata$discussion_id,
                  all_elements[[i]]$metadata$display_name,
                  all_elements[[i]]$metadata$discussion_category,
                  all_elements[[i]]$metadata$discussion_target)
        }
}


#' Get the variables associated with each forum element in the XML file (for use in \code{prepare_xml}).
#'
#' @param i An iterator.
#' @param all_parameters An XML tree containing all the parameters associated with each discussion node.
#' @return A vector containing the \code{display_name}, \code{discussion_category}, and \code{discussion_target} of a course element.
#' @examples
#' get_discussion_vars_xml(i, all_parameters)
#' @export
get_discussion_vars_xml <- function(i, all_parameters) {
        c(all_parameters[[i]]['display_name'],
          all_parameters[[i]]['discussion_category'],
          all_parameters[[i]]['discussion_target'])
}
