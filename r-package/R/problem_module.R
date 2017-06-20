#' Clean a demographic multiple choice CSV
#'
#' This function cleans a CSV retrieved from the `demographic_multiple_choice`
#' SQL script. It transforms the `sum_dt` column into activity_level. It also
#' removes any non-multiple choice problems.
#'
#' @param raw_csv: A dataframe from the read_csv
#'
#' @return A dataframe with the same dimensions as the CSV
clean_multiple_choice <- function(raw_csv) {

  raw_csv  %>%
    mutate(activity_level = case_when((.$sum_dt < 1800) ~ "under_30_min",
                                      (.$sum_dt >= 1800) & (.$sum_dt < 18000) ~ "30_min_to_5_hr",
                                      (.$sum_dt >= 18000) ~ "over_5_hr",
                                      is.na(.$sum_dt) ~ "NA")) %>%
    filter(grepl("choice", item_response)) %>%  # Only multichoice problems
    mutate(item_response = stringr::str_extract_all(item_response, "choice_[0-9]+")) %>%
    select(-sum_dt) %>%
    unnest()
}


#' Parse a JSON object and return it as a flat dataframe.
#'
#' This function is required to convert the JSON derived from the xbundle XML
#' into a format that other dataframes can interact with.
#'
#' @param name_lookup A JSON object contain keys for `id`, `problem`,
#'   `chapter_name`, `chapter_name`, `choices`, `correct_id` and `correct`
#'
#' @return A flat dataframe with the above columns
create_question_lookup_from_json <- function(name_lookup) {

  lookup_table <- name_lookup %>%
    tidyjson::gather_array() %>%
    tidyjson::spread_values(id = tidyjson::jstring("id"),
                            problem = tidyjson::jstring("problem"),
                            chapter = tidyjson::jstring("chapter_name"),
                            chapter_index = tidyjson::jnumber('chapter_index')) %>%
    tidyjson::enter_object("choices") %>%
    tidyjson::gather_array() %>%
    tidyjson::spread_values(choice = tidyjson::jstring("choice"),
                            choice_id = tidyjson::jstring("choice_id"),
                            correct = tidyjson::jstring("correct")) %>%
    select(-document.id, -array.index)
}


#' Filter out invalid multiple choice problems
#'
#' Removes problems that were marked as 100% correct (typically surveys or
#' problems where every answer is correct). Also checks from the dataframe
#' derived from xbundle to ensure that the problem exists in the course.
#'
#' @param problems_tbl The result of `read_multiple_choice_csv`
#' @param lookup_table The result of `create_question_lookup_from_json`
#'
#' @return The filtered problems_tbl
#' @export
filter_valid_questions <- function(problems_tbl, lookup_table) {
  problems_tbl %>%
    filter(avg_problem_pct_score < 100) %>% # Remove perfect scores (Surveys and unmarked)
    filter(problem_url_name %in% lookup_table$id)
}

#' Get mean scores.
#'
#' This function is not affected by filters. If you need a function that is, use
#' `get_mean_scores_filterable`. Removes scores that do not appear in the
#' xbundle XML or have a 100% percent average. This was done to remove survey
#' questions masquerading as multiple choice problems.
#'
#' @param problems_tbl The result of `clean_multiple_choice`
#' @param lookup_table The result of `create_question_lookup_from_json`
#'
#' @return A dataframe with each problem, the number of users that attempted
#'   the problem and the percent score
#' @export
get_mean_scores <- function(problems_tbl, lookup_table) {

  summarised_scores <- filter_valid_questions(problems_tbl, lookup_table) %>%
    group_by(problem_url_name) %>%
    summarise(percent_correct = mean(avg_problem_pct_score) / 100,
              users = n_distinct(user_id)) %>%
    ungroup()

}


#' Count the number of correct answers for each question.
#'
#' @param joined_scores `problems_tbl` and `lookup_table` joined by `id` and
#'   `item_response`
#'
#' @return A summarised dataframe of correct counts
#' @export
tally_correct_answers <- function(joined_scores) {

  joined_scores %>%
    filter(correct == "true") %>%
    group_by(problem_url_name) %>%
    tally() %>%
    rename(n_correct = n)
}


#' Calculate the percent of correct answers
#'
#' Each row represents a problem.
#'
#' @param joined_scores `problems_tbl` and `lookup_table` joined by `id` and
#'   `item_response`
#' @param number_correct the result of `tally_correct_answer`
#'
#' @return A dataframe where each row is a row and the columns show the
#'   percentage and absolute number of students that got the problem correct.
#' @export
calculate_percent_correct_tbl <- function(joined_scores, number_correct) {

  joined_scores %>%
    group_by(problem_url_name) %>%
    tally() %>%
    inner_join(number_correct, by = "problem_url_name") %>%
    mutate(percent_correct = n_correct / n)
}

#' A filterable version of get_mean_scores
#'
#' @param filtered_problems_tbl The result of `read_multiple_choice_csv` filtered
#'   by demographics and chapter
#' @param name_lookup A JSON object contain keys for `id`, `problem`,
#'   `chapter_name`, `chapter_name`, `choices`, `correct_id` and `correct`
#'
#' @return A dataframe where each row is a row and the columns show the
#'   percentage and absolute number of students that got the question correct.
#' @export
get_mean_scores_filterable <- function(filtered_problems_tbl) {

  number_correct <- tally_correct_answers(filtered_problems_tbl)

  percent_correct_tbl <- calculate_percent_correct_tbl(filtered_problems_tbl, number_correct)
}

#' Join the summary and lookup tables
#'
#' @param summarised_scores the result of `get_mean_scores_filterable`
#' @param lookup_table The result of `create_question_lookup_from_json`
#'
#' @return The inner join of the two dataframes
#' @export
join_summary_lookup <- function(summarised_scores, lookup_table) {
  inner_join(summarised_scores,
             lookup_table,
             by = c("problem_url_name" = "id"))
}


#' Summarise scores by chapter
#'
#' Calculates the average score on problems for each of the chapters based.
#'
#' @param summarised_scores the result of `get_mean_scores_filterable`
#' @param lookup_table The result of `create_question_lookup_from_json`
#'
#' @return A dataframe where each row is a chapter that contains the average
#'   score on that chapter
#' @export
summarise_scores_by_chapter <- function(summarised_scores, lookup_table) {

  chapter_summarised_scores <- join_summary_lookup(summarised_scores, lookup_table)

  chapter_summary_tbl <- chapter_summarised_scores %>%
    distinct(problem_url_name, .keep_all = TRUE) %>%
    group_by(chapter, chapter_index) %>%
    summarise(percent_correct = mean(percent_correct)) %>%
    ungroup() %>%
    mutate(chapter = forcats::as_factor(chapter)) %>%
    mutate(chapter = forcats::fct_reorder(chapter, chapter_index, .desc = TRUE))

}


#' Produce a dataframe clean dataframe of all questions
#'
#' Returns the question name and it's rounded percentage (out of 100). This
#' function is used to prepare the data table shown at the bottom of the problem
#' dashboard.
#'
#' @param summarised_scores the result of `get_mean_scores_filterable`
#' @param lookup_table The result of `create_question_lookup_from_json`
#'
#' @return A dataframe with the question and percent correct.
#' @export
prepare_filterable_problems <- function(summarised_scores, lookup_table) {

  chapter_summarised_scores <- join_summary_lookup(summarised_scores, lookup_table)


  problem_by_chapter <- chapter_summarised_scores %>%
    distinct(problem_url_name, .keep_all = TRUE) %>%
    arrange(percent_correct) %>%
    select(problem, percent_correct) %>%
    mutate(percent_correct = round(percent_correct * 100, 2)) %>%
    rename("Problem" = problem, "% Correct" = percent_correct)

}

#' Select the easiest (or hardest) problems
#'
#' Set the index negative to receive the hardest problems.
#'
#' @param summarised_scores the result of `get_mean_scores_filterable`
#' @param index the number of questions you wish to view
#'
#' @return The summarised scores dataframe with the with the number of rows
#'   equal to the absolute value of the index.
#' @export
get_extreme_summarised_scores <- function(summarised_scores, index) {

  summarised_scores %>%
    top_n(index, percent_correct)
}


#' Left join extracted problems and lookup table
#'
#' @param extracted_problems the result of `clean_multiple_choice`
#' @param lookup_table The result of `create_question_lookup_from_json`
#'
#' @return The left joined dataframe by id and choice_id, filtering out blank problems
#' @export
join_problems_to_lookup <- function(extracted_problems, lookup_table) {
  joined_melted_problems <- left_join(extracted_problems, lookup_table, by = c("problem_url_name" = "id",
                                                                               "item_response" = "choice_id"))
    # filter(!is.na(problem))
}

#' The left join of joined problems and summarised scores
#'
#' @param joined_problems `problems_tbl` and `lookup_table` joined by `id` and
#'   `item_response`
#' @param summarised_scores the result of `get_mean_scores_filterable`
#'
#' @return A left joined dataframe of joined problems and summarised scores
#' @export
join_users_problems <- function(joined_problems, summarised_scores) {
  left_join(joined_problems, summarised_scores, by = "problem_url_name")
}

#' Count the number of filtered users for each problem
#'
#' @param joined_user_problems The result of `join_users_problems`
#'
#' @return A dataframe with the count of unique users for each question
#' @export
filter_counts <- function(joined_user_problems) {
  joined_user_problems %>%
    group_by(problem_url_name) %>%
    summarise(filtered_users = n_distinct(user_id))
}

#' Retrieve the question and choice information from the extreme problems
#'
#' @param lookup_table The result of `create_question_lookup_from_json`
#' @param extreme_problems The result of `get_extreme_summarised_score`
#' @param filtered_counts The result of `filter_counts`
#'
#' @return A dataframe with lookup information attached
#' @export
filter_extreme_problem_choices <- function(lookup_table, extreme_problems, filtered_counts) {
  lookup_table %>%
    select(id, problem, choice) %>%
    filter(id %in% extreme_problems$problem_url_name) %>%
    inner_join(filtered_counts, by = c("id" = "problem_url_name"))
}

#' Perform the last wrangling before plotting extreme problems
#'
#' Calculates the percent of students selected each option and determines if that option is correct.
#'
#' @param joined_user_problems The result of `join_users_problems`
#' @param extreme_problems The result of `get_extreme_summarised_score`
#' @param question_choices The result of `filter_extreme_problem_choices`
#'
#' @return A dataframe with `problem,` `choice` and percent `correct`
#' @export
aggregate_extracted_problems <- function(joined_user_problems, extreme_problems, question_choices) {
  joined_user_problems %>%
    filter(problem_url_name %in% extreme_problems$problem_url_name) %>%  # Only in the bottom/top
    mutate(correct_bool = ifelse(correct == "true", TRUE, FALSE)) %>%
    group_by(problem_url_name, choice, users) %>%
    summarise(responses = n(),
              correct = any(correct_bool)) %>%
    right_join(question_choices, by = c("problem_url_name" = "id", "choice" = "choice")) %>%
    replace_na(list(responses = 0, correct = "FALSE")) %>% # Assume 0 values are incorrect
    mutate(freq_responses = responses / filtered_users,
           trunc_question = stringr::str_trunc(problem, 50),
           trunc_choice = stringr::str_trunc(choice, 50),
           correct = ordered(correct, levels = c("TRUE", "FALSE"))) %>%
    mutate(correct = forcats::fct_recode(correct, "Correct" = "TRUE", "Incorrect" = "FALSE"))
}

aggregate_melted_problems <- function(joined_user_problems, extreme_problems) {

  filtered_counts <- filter_counts(joined_user_problems)

  question_choices <- filter_extreme_problem_choices(lookup_table, extreme_problems, filtered_counts)

  agg_melted_problems <- aggregate_extracted_problems(joined_user_problems, extreme_problems, question_choices)
}

aggregate_single_problem <- function(joined_user_problems, problem_url) {

  filtered_counts <- joined_user_problems %>%
    filter(!is.na(problem)) %>%
    group_by(problem) %>%
    summarise(filtered_users = n_distinct(user_id))

  agg_melted_problems <- joined_user_problems %>%
    filter(problem_url_name == problem_url) %>%
    mutate(correct_bool = ifelse(correct == "true", TRUE, FALSE)) %>%
    group_by(problem, choice, users) %>%
    summarise(responses = n(),
              correct = any(correct_bool)) %>%
    inner_join(filtered_counts) %>%
    mutate(freq_responses = responses / filtered_users,
           trunc_question = str_trunc(problem, 50),
           trunc_choice = str_trunc(choice, 50))
}

plot_aggregated_problems <- function(agg_melted_problems) {

  id_to_questions <- as_labeller(setNames(as.character(agg_melted_problems$trunc_question),
                                          agg_melted_problems$problem_url_name))

  fill_scheme <- c("Correct" = "#66c2a5", "Incorrect" = "#b2e2e2")

  ggplot(agg_melted_problems, aes(x = choice, y = freq_responses,
                                  fill = correct)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label=trunc_choice, x = choice, y=0, hjust=0),
              color='black', check_overlap = TRUE, size = 4) +
    facet_wrap(~problem_url_name,
               scales = "free",
               labeller = id_to_questions,
               ncol = 1,
               strip.position = "left",
               as.table = FALSE) +
    ggthemes::theme_few(base_family = "sans-serif") +
    coord_flip() +
    theme(axis.text.y=element_blank(),
          strip.text.y = element_text(angle = 180),
          axis.title.y.right = element_text(color = "red"),
          strip.switch.pad.grid = unit(15, "cm"),
          legend.justification = "top") +
    scale_y_continuous(labels=scales::percent,
                       limits = c(0, 1),
                       position = "right") + # Add percentage scaling
    labs(x = "Choice",
         y = "Percent of Respondents",
         fill = "") +
    scale_fill_manual(values = fill_scheme)
}

# Overview plot (Chapter by Course)

plot_problem_chapter_summaries <- function(chapter_summary_tbl) {

  ggplot(chapter_summary_tbl, aes(x = chapter, y = percent_correct)) +
    geom_bar(stat= "identity", fill = "#66c2a5") +
    coord_flip() +
    ggthemes::theme_few(base_family = "sans-serif") +
    scale_y_continuous(labels=scales::percent, limits = c(0, 1)) +
    labs(x = "Module",
         y = "Average Score of Module Problems")
}

# Overview plot (Problem by Chapter)

plot_problems_per_chapter <- function(problem_by_chapter, chapter_name) {

  ggplot(problem_by_chapter, aes(x = trunc_question, y = percent_correct)) +
    geom_bar(stat= "identity", fill = "#66c2a5") +
    coord_flip() +
    ggthemes::theme_few(base_family = "sans-serif") +
    scale_y_continuous(labels=scales::percent, limits = c(0, 1)) +
    labs(x = "Chapter",
         y = "Percent Correct",
         title = paste0("How Did Students Do in \"", chapter_name, "\"?"))
}
