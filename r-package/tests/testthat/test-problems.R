context("Testing Problems Plot")

json_string <- '[{"id": "09559307b70f4ffc8ff15888b7f1e47f", "chapter_name": "Part 1: What Is Psychology?", "chapter_index": 1, "problem": "According to your textbook, Psychology is best defined as:", "choices": [{"choice": "the study of the mind", "correct": "false", "choice_id": "choice_0"}, {"choice": "the study of the mind and behavior", "correct": "true", "choice_id": "choice_1"}, {"choice": "the study of behavior", "correct": "false", "choice_id": "choice_2"}, {"choice": "the study of the biology of the mind", "correct": "false", "choice_id": "choice_3"}, {"choice": "the study of why people do what they do", "correct": "false", "choice_id": "choice_4"}]}]'

test_that("Problem JSON can be opened", {

  extracted_json <- create_question_lookup_from_json(json_string)

  expect_equal(dim(extracted_json), c(5, 7))

})

test_that("Filter Valid Questions removes problematic rows", {

  test_problem_tbl <- data_frame(avg_problem_pct_score = c(100, 95, 95), problem_url_name=c("a", "b", "c"))
  test_lookup_table <- data_frame(id = c("a", "b"))

  filtered_problem_tbl <- filter_valid_questions(test_problem_tbl, test_lookup_table)

  expect_equal(filtered_problem_tbl, data_frame(avg_problem_pct_score = c(95), problem_url_name = c("b")))

})

test_that("Get mean scores calculates users correctly", {

  test_problem_tbl <- data_frame(avg_problem_pct_score = c(100, 95, 95, 95),
                                 problem_url_name=c("a", "b", "c", "b"),
                                 user_id = c(1, 1, 1, 2))
  test_lookup_table <- data_frame(id = c("a", "b"))

  test_mean_scores <- get_mean_scores(test_problem_tbl, test_lookup_table)

  reference_tbl <- data_frame(problem_url_name = c("b"),
                              percent_correct = c(0.95),
                              users = as.integer(c(2)))

  expect_equal(test_mean_scores, reference_tbl)

})


test_that("Tally correct rows only counts correct rows", {

  test_joined_tbl <- data_frame(problem_url_name=c("a", "b", "c", "a", "a"),
                                 correct = c("true", "false", "true", "false", "true"))

  tallied_problem_tbl <- tally_correct_answers(test_joined_tbl)

  expect_equivalent(tallied_problem_tbl, data_frame(problem_url_name = c("a", "c"),
                                                    n_correct = as.integer(c(2, 1))))

})


test_that("Calculate Percent Correct returns the expected percentages", {

  test_joined_tbl <- data_frame(problem_url_name=c("a", "b", "c", "a", "a", "a"),
                                correct = c("true", "false", "true", "false", "true", "false"))

  test_tallied_problem_tbl <- tally_correct_answers(test_joined_tbl)

  test_percent_correct_tbl <- calculate_percent_correct_tbl(test_joined_tbl, test_tallied_problem_tbl)

  reference_tbl <- data_frame(problem_url_name = c("a", "c"),
                              n = as.integer(c(4, 1)),
                              n_correct = as.integer(c(2, 1)),
                              percent_correct = c(0.5, 1))


  expect_equal(test_percent_correct_tbl, reference_tbl, tolerance = 1e-2)

})


test_that("Get Mean Scores Filterable returns the expected percentages", {

  test_joined_tbl <- data_frame(problem_url_name=c("a", "b", "c", "a", "a", "a"),
                                item_response=c("1", "1", "1", "2", "1", "2"),
                                correct = c("true", "false", "true", "false", "true", "false"))
  test_lookup_table <- data_frame(id = c("a", "a", "b", "b", "c", "c"),
                                  choice_id = c("1", "2", "1", "2", "1", "2"))

  test_mean_scores_filterable <- get_mean_scores_filterable(test_joined_tbl, test_lookup_table)

  reference_tbl <- data_frame(problem_url_name = c("a", "c"),
                              n = as.integer(c(4, 1)),
                              n_correct = as.integer(c(2, 1)),
                              percent_correct = c(0.5, 1))


  expect_equal(test_mean_scores_filterable, reference_tbl, tolerance = 1e-2)

})

test_that("Summarise Scores by Chapter summarises chapters", {

  test_joined_tbl <- data_frame(problem_url_name=c("a", "b", "c", "a", "a", "a"),
                                item_response=c("1", "1", "1", "2", "1", "2"),
                                correct = c("true", "false", "true", "false", "true", "false"))

  test_lookup_table <- data_frame(id = c("a", "a", "b", "b", "c", "c"),
                                  choice_id = c("1", "2", "1", "2", "1", "2"),
                                  chapter = c("A", "A", "B", "B", "A", "A"),
                                  chapter_index = c(1, 1, 2, 2, 1, 1))

  test_mean_scores <- get_mean_scores_filterable(test_joined_tbl, test_lookup_table)

  test_chapter_summary_tbl <- summarise_scores_by_chapter(test_mean_scores, test_lookup_table)

  reference_tbl <- data_frame(chapter = as.factor("A"), chapter_index = 1, percent_correct = 0.75)

  expect_equal(test_chapter_summary_tbl, reference_tbl, tolerance = 1e-2)

})

test_that("Prepare Filterable Questions is the proper dimension", {

  test_joined_tbl <- data_frame(problem_url_name=c("a", "b", "c", "a", "a", "a"),
                                item_response=c("1", "1", "1", "2", "1", "2"),
                                correct = c("true", "false", "true", "false", "true", "false"))

  test_lookup_table <- data_frame(id = c("a", "a", "b", "b", "c", "c"),
                                  choice_id = c("1", "2", "1", "2", "1", "2"),
                                  chapter = c("A", "A", "B", "B", "A", "A"),
                                  chapter_index = c(1, 1, 2, 2, 1, 1),
                                  question = c("A1", "A1", "B1", "B1", "C1", "C1"))

  test_mean_scores <- get_mean_scores_filterable(test_joined_tbl, test_lookup_table)

  test_prepared_problems <- prepare_filterable_problems(test_mean_scores, test_lookup_table)

  reference_tbl <- data_frame(Question = c("A1", "C1"),
                              "% Correct" = as.numeric(c(50, 100)))

  expect_equal(test_prepared_problems, reference_tbl, tolerance = 1e-2)

})

test_that("Get Extreme Summarised Scores is the proper dimension", {

  test_joined_tbl <- data_frame(problem_url_name=c("a", "b", "c", "a", "a", "a"),
                                item_response=c("1", "1", "1", "2", "1", "2"),
                                correct = c("true", "false", "true", "false", "true", "false"))

  test_lookup_table <- data_frame(id = c("a", "a", "b", "b", "c", "c"),
                                  choice_id = c("1", "2", "1", "2", "1", "2"),
                                  chapter = c("A", "A", "B", "B", "A", "A"),
                                  chapter_index = c(1, 1, 2, 2, 1, 1),
                                  question = c("A1", "A1", "B1", "B1", "C1", "C1"))

  test_mean_scores <- get_mean_scores_filterable(test_joined_tbl, test_lookup_table)

  test_top_problems <- get_extreme_summarised_scores(test_mean_scores, 1)
  test_bottom_problems <- get_extreme_summarised_scores(test_mean_scores, -1)

  reference_top_tbl <- data_frame(problem_url_name = "c",
                              n = as.integer(1),
                              n_correct = as.integer(1),
                              percent_correct = as.numeric(1))

  reference_bottom_tbl <- data_frame(problem_url_name = "a",
                                  n = as.integer(4),
                                  n_correct = as.integer(2),
                                  percent_correct = as.numeric(0.5))

  expect_equal(test_top_problems, reference_top_tbl)
  expect_equal(test_bottom_problems, reference_bottom_tbl)

})


test_that("Read multiple choice CSV properly extracts choices.",{
  test_raw_csv <- data_frame(sum_dt = c(100, 1900, 19000, NA),
                               item_response = c('["choice_1", "choice_4"]',
                                                 "choice_3",
                                                 "72",
                                                 '["choice_0", "choice_2", "choice_3"]'))

  reference_tbl <- data_frame(activity_level = c("under_30_min", "under_30_min", "30_min_to_5_hr", "NA", "NA","NA"),
                              item_response = c("choice_1", "choice_4", "choice_3", "choice_0", "choice_2", "choice_3"))

  test_extracted_tbl <- clean_multiple_choice(test_raw_csv)

  expect_equivalent(test_extracted_tbl, reference_tbl)

})

test_that("Joined problems table contains chapters",{
  test_problem_tbl <- data_frame(problem_url_name=c("a", "b", "c", "a", "a", "a"),
                                item_response=c("1", "1", "1", "2", "1", "2"),
                                correct = c("true", "false", "true", "false", "true", "false"))

  test_lookup_table <- data_frame(id = c("a", "a", "b", "b", "c", "c"),
                                  choice_id = c("1", "2", "1", "2", "1", "2"),
                                  chapter = c("A", "A", "B", "B", "A", "A"),
                                  chapter_index = c(1, 1, 2, 2, 1, 1),
                                  question = c("A1", "A1", "B1", "B1", "C1", "C1"))

  test_joined_tbl <- join_problems_to_lookup(test_problem_tbl, test_lookup_table)


  expect_true("chapter" %in% names(test_joined_tbl))
  expect_true(all(!is.na(test_joined_tbl)))

})

