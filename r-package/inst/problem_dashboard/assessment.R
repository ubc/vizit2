extract_assessment_json <- function(assessment_json)
{
  assessment_content <- assessment_json %>% gather_array() %>% spread_values(url_name = jstring("url_name"), title = jstring("title")) %>%
    enter_object("labels") %>% gather_array() %>% spread_values(label = jstring("label"), name = jstring("name"))
}

extract_assessment_csv <- function(assessment_tbl)
{
  extracted_assessment <- assessment_tbl %>% mutate(assessment_id = str_extract(module_id, "[0-9a-f]{32}")) %>%
    mutate(points_possible = strapply(event, "\\\"points_possible\\\": (\\d+)", as.numeric), points = strapply(event,
      "\\\"points\\\": (\\d+)", as.numeric), names = strapply(event, "\\\"points_possible\\\": \\d+, \\\"name\\\": \\\"(\\S+)\\\"")) %>%
    unnest() %>% select(-event, -module_id)
}

join_extracted_assessment_data <- function(extracted_assessment, assessment_content)
{
  joint_assessment <- left_join(extracted_assessment, assessment_content, by = c(assessment_id = "url_name", names = "name"))
}

summarise_joined_assessment_data <- function(joint_assessment)
{
  summary_assessment <- joint_assessment %>% group_by(title, label) %>% summarise(avg_score = mean(points), avg_percent = mean(points)/max(points)) %>%
    mutate(trunc_label = str_trunc(label, 20))
}

plot_assessment <- function(summary_assessment)
{
  ggplot(summary_assessment, aes(x = label, y = avg_percent)) +
    geom_bar(stat = "identity", fill = "#66c2a5") +
    geom_text(aes(label = trunc_label, x = label, y = 0, hjust = 0),
              color = "black", check_overlap = TRUE, size = 4) +
    facet_wrap(~title, scales = "free") + theme_few(base_family = "sanserif") +
    theme(axis.text.y = element_blank()) +
    coord_flip() +
    scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    labs(x = "Criterion", y = "Score")
}
