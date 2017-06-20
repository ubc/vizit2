context("Test functions in overview server files are robust when special case happens")
devtools::load_all()

engage_df <- read_csv("data/engage_df.csv")
item_df <- read.csv("data/item_df.csv")


test_that("Proper warning message pops up if dataframee is empty after joining engage table and item table", {

  join_df <- join_engagement_item(engage_df,item_df)

  expect_equal(join_df$nactive[1] , "Sorry,no data matched this filtering condition")
})

