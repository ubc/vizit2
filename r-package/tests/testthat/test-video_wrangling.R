context("Testing video wrangling.")

test_that("Wrangling script properly counts rewatches via seek_video", {
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")

  View(wrangled_data)

  # Check to see that watched time under a minute twice
  test_df <- wrangled_data %>%
    filter(username == "AndrewLim",
           video_name == 'Programming: Video I',
           min_into_video <= 1)
  test_count <- test_df$count
  expect_equal(test_count, rep(2, nrow(test_df)))

})

test_that("Wrangling script properly cuts off with seek_video", {
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")

  # Check to see that watched time over a minute once
  test_df <- wrangled_data %>%
    filter(username == "AndrewLim",
           video_name == 'Programming: Video I',
           min_into_video > 1)
  test_count <- test_df$count
  expect_equal(test_count, rep(1, nrow(test_df)))

})

test_that("Wrangling script properly filters out small watch durations", {
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")

  # Check to see that watched time over a minute once
  test_df <- wrangled_data %>%
    filter(username == "MattEmery",
           video_name == 'Programming: Video IV',
           min_into_video == 0)

  test_count <- test_df$count

  expect_equal(test_count, 1)
})

test_that("Wrangling script properly parses seq_next, page_close, etc.", {
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")

  # Check to see that watched time over a minute once
  test_df <- wrangled_data %>%
    filter(username == "AndrewLim",
           video_name == 'Programming: Video III')

  test_end_time <- max(test_df$min_into_video)

  expect_equal(test_end_time, 1)
})


