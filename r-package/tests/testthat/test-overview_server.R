context("Test functions in overview server files are robust when special case happens")

test_that("Proper warning message pops up if dataframe is empty after joining engage table and item table", {

  engage_df <- read_csv("data/engage_df.csv")
  item_df <- read.csv("data/item_df.csv")
  
  expect_warning(join_engagement_item(engage_df, item_df))
  expect_equal(suppressWarnings(join_engagement_item(engage_df, item_df)$nactive[1]) , "Sorry, no data matched this filtering condition")
})

