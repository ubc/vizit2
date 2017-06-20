library(forcats)
library(ggthemes)
library(lubridate)
library(RColorBrewer)
library(reshape2)
library(scales)
library(shiny)
library(shinyBS)
library(tidytext)
library(tidyverse)
library(wordcloud)

library(DT)

source("../../R/forum_server.R")

# Select the course.
course <- "creative_writing"

# If you want to use the full dataset, set `root` to `nongit_path` (warning: the data won't exist unless you put it there...)
nongit_path <- "../../../../nongit_data/"
git_path <- "../../data/"
root <- git_path

# Read in the wrangled data.
wrangled_forum_posts <- read_csv(paste0(root, course, "/wrangled_forum_posts.csv"))
wrangled_forum_words <- read_csv(paste0(root, course, "/wrangled_forum_words.csv"))
wrangled_forum_views <- read_csv(paste0(root, course, "/wrangled_forum_views.csv"))
wrangled_forum_elements <- read_csv(paste0(root, course, "/wrangled_forum_elements.csv"))
wrangled_forum_searches <- read_csv(paste0(root, course, "/wrangled_forum_searches.csv"))

# wrangled_forum_posts <- read_csv("wrangled_forum_posts.csv")
# wrangled_forum_words <- read_csv("wrangled_forum_words.csv")
# wrangled_forum_views <- read_csv("wrangled_forum_views.csv")
# wrangled_forum_elements <- read_csv("wrangled_forum_elements.csv")
# wrangled_forum_searches <- read_csv("wrangled_forum_searches.csv")

#' # Set the alpha values of the selected vs unselected subcategories.
#' alphas <- c("FALSE" = 0.3, "TRUE" = 0.8)
#' 
#' #' Find the mode of a vector.
#' #'
#' #' @param x A vector.
#' #' @return The mode of the vector.
#' #' @examples
#' #' find_mode(c(1,3,3,4,5,6))
#' #' [1] 3
#' find_mode <- function(x) {
#'         ux <- unique(x)
#'         ux[which.max(tabulate(match(x, ux)))]
#' }
#' 
#' #' Apply the selected filter settings to the forum data.
#' #' 
#' #' @param input_df The input dataframe.
#' #' @param activity_level One of "under_30_min", "30_min_to_5_hr", "over_5_hr", or (default) "all".
#' #' @param gender One of "male", "female", "other", or (default) "all".
#' #' @param registration_status One of "audit", "verified", or (default) "all".
#' #' @param category One of the forum categories.
#' #' @return A dataframe filtered by the selected demographics.
#' #' @examples
#' #' apply_forum_filters(forum_posts, "all", "all", "all")
#' apply_forum_filters <- function(input_df, activity_level = "All", gender = "All", registration_status = "All", category = "All") {
#'         filtered_df <- input_df
#'         if (gender == "female") {
#'                 filtered_df <- filtered_df %>% filter(gender == "f")
#'         }
#'         if (gender == "male") {
#'                 filtered_df <- filtered_df %>% filter(gender == "m")
#'         }
#'         if (gender == "other") {
#'                 filtered_df <- filtered_df %>% filter(gender == "o")
#'         }
#'         if (activity_level == "under_30_min") {
#'                 filtered_df <- filtered_df %>% filter(activity_level == "under_30_min")
#'         }
#'         if (activity_level == "30_min_to_5_hr") {
#'                 filtered_df <- filtered_df %>% filter(activity_level == "30_min_to_5_hr")
#'         }
#'         if (activity_level == "over_5_hr") {
#'                 filtered_df <- filtered_df %>% filter(activity_level == "over_5_hr")
#'         }
#'         if (registration_status == "audit") {
#'                 filtered_df <- filtered_df %>% filter(registration_status == "audit")
#'         }
#'         if (registration_status == "verified") {
#'                 filtered_df <- filtered_df %>% filter(registration_status == "verified")
#'         }
#'         
#'         if (category != "All") {
#'                 
#'                 if(!"discussion_category" %in% names(filtered_df)) {
#'                         filtered_df
#'                 } else {
#'                         filtered_df <- filtered_df %>% 
#'                                 filter(discussion_category == category)
#'                         wrangled_forum_elements <- wrangled_forum_elements %>% 
#'                                 filter(discussion_category == category)
#'                 }
#'         }
#'         
#'         # If all students have been filtered out, return forum_elements with nothing in it.
#'         if (dim(filtered_df)[1] == 0 & !"search_query" %in% names(filtered_df)) {
#'                 filtered_df <- right_join(wrangled_forum_elements, filtered_df)
#'                 return(filtered_df)
#'         } else {
#'                 return(filtered_df)
#'         }
#' 
#' }
#' 
#' #' Get the top words for each subcategory.
#' #' 
#' #' @param input_forum The input dataframe containing a row for each word in the forum.
#' #' @return A dataframe containing the counts for each word in each subcategory.
#' #' @examples
#' #' get_target_word_counts(wrangled_forum_words)
#' get_target_word_counts <- function(input_forum) {
#'         
#'         # Get the word counts for each word in each subcategory.
#'         word_counts <- input_forum %>%
#'                 group_by(display_name, word) %>% 
#'                 count(sort = TRUE)
#'         
#'         # Join with forum_elements.
#'         output_forum <- word_counts
#'         
#'         # Return the relative counts for each word in each subcategory.
#'         return(output_forum)
#'         
#' }
#' 
#' #' Count the number of posts for each subcategory in an input forum.
#' #' 
#' #' @param input_forum The input dataframe containing a row for each post in the forum.
#' #' @return A dataframe containing the post counts for each subcategory in the forum.
#' #' @examples
#' #' count_posts(wrangled_forum_posts)
#' count_posts <- function(input_forum){
#'         
#'         # Make sure there is a row for every permutation of display names and post types.
#'         types_dummy_set <- data.frame(
#'                 "display_name" = rep(wrangled_forum_elements$display_name, each = 4),
#'                 "type" = rep(c("Discussion", "Question", "Response", "Comment"), times = dim(wrangled_forum_elements)[1])
#'         )
#'         
#'         # Count up all the posts.
#'         output_forum <- input_forum %>% 
#'                 group_by(display_name, type) %>%
#'                 summarize(posts = n_distinct(mongoid, na.rm = TRUE)) %>% 
#'                 right_join(types_dummy_set) %>% 
#'                 spread(key = type, value = posts, drop = FALSE) %>% 
#'                 mutate(posts = sum(Discussion, Question, Response, Comment, na.rm = TRUE))
#'         
#'         output_forum$posts[is.na(output_forum$posts)] <- 0
#'         output_forum$Discussion[is.na(output_forum$Discussion)] <- 0
#'         output_forum$Question[is.na(output_forum$Question)] <- 0
#'         output_forum$Response[is.na(output_forum$Response)] <- 0
#'         output_forum$Comment[is.na(output_forum$Comment)] <- 0
#'         
#'         return(output_forum)
#' }
#' 
#' #' Count the number of unique authors for each subcategory in an input forum.
#' #' 
#' #' @param input_forum The input dataframe containing a row for each post in the forum.
#' #' @return A dataframe containing the unique author counts for each subcategory in the forum.
#' #' @examples
#' #' count_authors(wrangled_forum_posts)
#' count_authors <- function(input_forum){
#'         output_forum <- input_forum %>% 
#'                 group_by(display_name) %>% 
#'                 summarize(authors = n_distinct(author_id)) %>% 
#'                 arrange(desc(authors))
#'         output_forum <- right_join(wrangled_forum_elements, output_forum)
#'         output_forum$authors[is.na(output_forum$authors)] <- 0
#'         return(output_forum)
#' }
#' 
#' #' Count the number of read events for each subcategory in an input forum.
#' #' 
#' #' @param input_forum The input dataframe containing a row for each read event in the forum.
#' #' @return A dataframe containing the read counts for each subcategory in the forum.
#' #' @examples
#' #' count_views(wrangled_forum_reads)
#' count_views <- function(input_forum) {
#'         output_forum <- input_forum %>%
#'                 group_by(display_name) %>% 
#'                 count() %>% 
#'                 mutate(views = n) %>% 
#'                 select(-n) %>% 
#'                 arrange(desc(views))
#'         output_forum <- right_join(wrangled_forum_elements, output_forum)
#'         output_forum$views[is.na(output_forum$views)] <- 0
#'         return(output_forum)
#' }