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


plot_single_problem <- function(agg_melted_problems) {
  ggplot(agg_melted_problems, aes(x = choice, y = freq_responses,
                                  alpha = correct)) +
    geom_bar(stat = "identity", fill = "blue") +
    geom_text(aes(label=trunc_choice, x = choice, y=0, hjust=0),
              color='black', check_overlap = TRUE, size = 4) +
    theme_few(base_family = "sans-serif") +
    theme(axis.text.y=element_blank()) +
    coord_flip() +
    scale_y_continuous(labels=scales::percent, limits = c(0, 1)) + # Add percentage scaling
    labs(x = "Choice",
         y = "Percent of Respondents",
         title = "question",
         alpha = "Correctness") +
    scale_alpha_discrete(range = c(0.4, 0.8))
}
