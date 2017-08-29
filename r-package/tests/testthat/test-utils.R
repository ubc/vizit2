context("Testing Utility Functions")

test_that("Read course CSV can open a CSV", {
  test_dataframe <- tibble(column1 = c("row1", "row2"),
                           column2 = c("row1", "row2"))
  expect_equal(read_course_csv("data", "read_course_csv.csv", c(".")), test_dataframe)
  expect_equal(read_course_csv("data", "read_course_csv", c(".")), test_dataframe)
})

test_that("Cut activity levels creates the proper cuts", {
  test_dataframe <- tibble(sum_dt = c(0, 1, 1800, 1801, 18000, 18001, NA))

  result_dataframe <- tibble(activity_level = c("under_30_min", "under_30_min",
                                                "30_min_to_5_hr", "30_min_to_5_hr",
                                                "over_5_hr", "over_5_hr"))

  print(cut_activity_levels(test_dataframe))
  expect_equal(nrow(cut_activity_levels(test_dataframe)), nrow(result_dataframe))
})
