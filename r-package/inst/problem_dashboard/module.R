create_question_lookup_from_json <- function(name_lookup) {

  lookup_table <- name_lookup %>%
    gather_array() %>%
    spread_values(id = jstring("id"),
                  question = jstring("question"),
                  chapter = jstring("chapter_name"),
                  chapter_index = jnumber('chapter_index')) %>%
    enter_object("choices") %>%
    gather_array() %>%
    spread_values(choice = jstring("choice"),
                  choice_id = jstring("choice_id"),
                  correct = jstring("correct")) %>%
    mutate(choice_id = str_replace_all(choice_id, '"', ""))
}


get_mean_scores <- function(problems_tbl, lookup_table) {

  summarised_scores <- problems_tbl %>%
    filter(avg_problem_pct_score < 100) %>%     # Remove perfect scores (Surveys and unmarked)
    filter(problem_url_name %in% lookup_table$id) %>%
    group_by(problem_url_name) %>%
    summarise(percent_correct = mean(avg_problem_pct_score) / 100,
              users = n_distinct(user_id))

}

get_mean_scores_filterable <- function(problems_tbl, lookup_table) {

  joined_scores <- problems_tbl %>%
    filter(avg_problem_pct_score < 100) %>% # Remove perfect scores (Surveys and unmarked)
    filter(problem_url_name %in% lookup_table$id) %>%
    mutate(item_response = str_replace_all(item_response, '"', ""))%>%
    inner_join(lookup_table, by = c("problem_url_name" = "id", "item_response" = "choice_id"))

  number_correct <- joined_scores %>%
    filter(correct == "true") %>%
    group_by(problem_url_name) %>%
    tally() %>%
    rename(n_correct = n)

  percent_correct_tbl <- joined_scores %>%
    group_by(problem_url_name) %>%
    tally() %>%
    inner_join(number_correct) %>%
    mutate(percent_correct = n_correct / n)

  percent_correct_tbl
}

summarise_scores_by_chapter <- function(summarised_scores, lookup_table) {

  chapter_summarised_scores <- inner_join(summarised_scores,
                                         lookup_table,
                                         by = c("problem_url_name" = "id"))


  chapter_summary_tbl <- chapter_summarised_scores %>%
    distinct(problem_url_name, .keep_all = TRUE) %>%
    group_by(chapter, chapter_index) %>%
    summarise(percent_correct = mean(percent_correct)) %>%
    ungroup() %>%
    mutate(chapter = as_factor(chapter)) %>%
    mutate(chapter = fct_reorder(chapter, chapter_index, .desc = TRUE))

}


problem_scores_by_chapter <- function(summarised_scores, lookup_table) {

  chapter_summarised_scores <- inner_join(summarised_scores,
                                          lookup_table,
                                          by = c("problem_url_name" = "id"))


  problem_by_chapter <- chapter_summarised_scores %>%
    distinct(problem_url_name, .keep_all = TRUE) %>%
    mutate(trunc_question = str_trunc(question, 40),
           trunc_choice = str_trunc(choice, 40)) %>%
    arrange(percent_correct) %>%
    mutate(trunc_question = fct_infreq(trunc_question)) %>%
    select(question, percent_correct) %>%
    mutate(percent_correct = round(percent_correct * 100, 2)) %>%
    rename("Question" = question, "% Correct" = percent_correct)

}

get_extreme_summarised_scores <- function(summarised_scores, index) {

    summarised_scores %>%
    top_n(index, percent_correct)
}



melt_extreme_problems <- function(problem_tbl, lookup_table) {
  melted_problems <- problems_tbl %>%
    mutate(item_response = str_split(
      str_replace(
        str_replace(item_response, '\\[\"', ""), '\\"\\]', ""),
      pattern = '\", \"'
    )) %>% # Converts string of list to list
    unnest() %>%
    mutate(item_response = str_replace_all(item_response, '"', "")) %>% # Removes quotes around some answers
    filter(avg_problem_pct_score < 100) # Filter out questions everyone gets right (unmarked and survey questions)

  joined_melted_problems <- left_join(melted_problems, lookup_table, by = c("problem_url_name" = "id",
                                                                     "item_response" = "choice_id")) %>%
    filter(!is.na(question)) #TODO: Follow up on why these are null
}


join_users_problems <- function(joined_problems, summarised_scores) {
   joined_user_problems <- left_join(joined_problems, summarised_scores) # Need to get number of users per question
}



aggregate_melted_problems <- function(joined_user_problems, extreme_problems) {

  filtered_counts <- joined_user_problems %>%
    group_by(problem_url_name) %>%
    summarise(filtered_users = n_distinct(user_id))

  question_choices <- lookup_table %>%
    select(id, question, choice) %>%
    filter(id %in% extreme_problems$problem_url_name) %>%
    inner_join(filtered_counts, by = c("id" = "problem_url_name"))

  agg_melted_problems <- joined_user_problems %>%
    filter(problem_url_name %in% extreme_problems$problem_url_name) %>%  # Only in the bottom/top
    mutate(correct_bool = ifelse(correct == "true", TRUE, FALSE)) %>%
    group_by(problem_url_name, choice, users) %>%
    summarise(responses = n(),
               correct = any(correct_bool)) %>%
    right_join(question_choices, by = c("problem_url_name" = "id", "choice" = "choice")) %>%
    replace_na(list(responses = 0, correct = "FALSE")) %>% # Assume 0 values are incorrect
    mutate(freq_responses = responses / filtered_users,
           trunc_question = str_trunc(question, 50),
           trunc_choice = str_trunc(choice, 50),
           correct = ordered(correct, levels = c("TRUE", "FALSE"))) %>%
    mutate(correct = fct_recode(correct, "Correct" = "TRUE", "Incorrect" = "FALSE"))

}

aggregate_single_problem <- function(joined_user_problems, problem_url) {

  filtered_counts <- joined_user_problems %>%
    filter(!is.na(question)) %>% #TODO: Remove this when numeric questions completed
    group_by(question) %>%
    summarise(filtered_users = n_distinct(user_id))

  agg_melted_problems <- joined_user_problems %>%
    filter(problem_url_name == problem_url) %>%
    mutate(correct_bool = ifelse(correct == "true", TRUE, FALSE)) %>%
    group_by(question, choice, users) %>%
    summarise(responses = n(),
              correct = any(correct_bool)) %>%
    inner_join(filtered_counts) %>%
    mutate(freq_responses = responses / filtered_users,
           trunc_question = str_trunc(question, 50),
           trunc_choice = str_trunc(choice, 50))
}

truncate_question <- function(question) {
  str_trunc(question, 50)
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
    theme_few(base_family = "sans-serif") +
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
    theme_few(base_family = "sans-serif") +
    scale_y_continuous(labels=scales::percent, limits = c(0, 1)) +
    labs(x = "Module",
         y = "Average Score of Module Questions")
}

# Overview plot (Problem by Chapter)

plot_problems_per_chapter <- function(problem_by_chapter, chapter_name) {

  ggplot(problem_by_chapter, aes(x = trunc_question, y = percent_correct)) +
    geom_bar(stat= "identity", fill = "#66c2a5") +
    coord_flip() +
    theme_few(base_family = "sans-serif") +
    scale_y_continuous(labels=scales::percent, limits = c(0, 1)) +
    labs(x = "Chapter",
         y = "Percent Correct",
         title = paste0("How Did Students Do in \"", chapter_name, "\"?"))
}
