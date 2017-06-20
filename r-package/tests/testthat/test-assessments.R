context("Testing Asessment Plot")

json_string <- '[{"url_name": "06ccb4a9c0204159bb176fac6fe95bf0", "title": "Assessment", "labels": [{"label": "Label1", "name": "Ideas"}, {"label": "Label2", "name": "name2"}]}]'

extractable_tbl <- read_csv("./data/assessment_stub.csv")

test_that("Assessment JSON can be opened", {

  extracted_json <- extract_assessment_json(json_string)

  expect_equal(dim(extracted_json), c(2, 4))
})


test_that("Event data can be extracted from a raw dataframe", {
  extractable_tbl <- read_csv("./data/assessment_stub.csv")

  extracted_tbl <- extract_assessment_csv(extractable_tbl)

  expect_equal(extracted_tbl %>% filter(!is.na(activity_level)), extracted_tbl)
})

test_that("Extracted data can be joined", {
  extracted_tbl <- extract_assessment_csv(extractable_tbl)
  extracted_json <- extract_assessment_json(json_string)

  joined_tbl <- join_extracted_assessment_data(extracted_tbl, extracted_json)

  expect_equal(dim(joined_tbl)[[1]], 2)
  expect_true("title" %in% colnames(joined_tbl))
})

test_that("Joined data can be summarised", {
  extracted_tbl <- extract_assessment_csv(extractable_tbl)
  extracted_json <- extract_assessment_json(json_string)
  joined_tbl <- join_extracted_assessment_data(extracted_tbl, extracted_json)

  summarised_tbl <- summarise_joined_assessment_data(joined_tbl, trunc_length = 4)

  expect_equal(summarised_tbl$avg_percent[[1]], 0.5)
  expect_equal(summarised_tbl$trunc_label[[1]], "L...")

})



