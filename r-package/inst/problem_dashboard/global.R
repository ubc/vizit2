devtools::load_all()

assessment_tbl <- read_csv("./open_assessment_psyc1.csv") %>%
  mutate(activity_level = case_when((.$sum_dt < 1800) ~ "under_30_min",
                                    (.$sum_dt >= 1800) & (.$sum_dt < 18000) ~ "30_min_to_5_hr",
                                    (.$sum_dt >= 18000) ~ "over_5_hr",
                                    is.na(.$sum_dt) ~ "NA"))

assessment_json <- tidyjson::read_json("./assessments_psyc1.json")

raw_problems_tbl <- read_csv("demographic_multiple_choice_psyc1.csv") %>%
  clean_multiple_choice()

lookup_table <- tidyjson::read_json("../../results/psyc1/multiple_choice_questions.json") %>%
  create_question_lookup_from_json()

problems_tbl <- join_problems_to_lookup(raw_problems_tbl, lookup_table)

summarised_scores <- problems_tbl %>%
  get_mean_scores(lookup_table)

joined_users_problems <- problems_tbl %>%
  join_users_problems(summarised_scores)

chap_name <- unique(joined_users_problems$chapter)

extracted_content <- extract_assessment_json(assessment_json)

extracted_assessment_tbl <- assessment_tbl %>%
  extract_assessment_csv()
