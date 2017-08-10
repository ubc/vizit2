context("Testing Utility Functions")

test_that("Read course CSV can open a CSV", {
  test_dataframe <- tibble(column1 = c("row1", "row2"),
                           column2 = c("row1", "row2"))
  expect_equal(read_course_csv("data", "read_course_csv.csv", c(".")), test_dataframe)
  expect_equal(read_course_csv("data", "read_course_csv", c(".")), test_dataframe)
})
