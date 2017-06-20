context("Test functions in linkpage server files are robust when special happens")

# test get_click_per_link
devtools::load_all()

link_df <- read_csv("data/link_df.csv") 


test_that("Proper error message pops up when no pages satisfied filtering condition",{

  link_summary <- get_click_per_link(link_df)

  expect_equal(as.character(creat_link_table(link_summary)$Warning), "No link found")
})