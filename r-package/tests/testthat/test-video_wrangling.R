context("Testing video wrangling.")

test_that("Wrangling script properly counts rewatches via seek_video", {
  wrangle_video("testing", test = TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")

  
  # Check to see that watched time under a minute twice
  test_df <- wrangled_data %>%
    filter(user_id == "AndrewLim",
           video_name == 'Programming: Video I',
           min_into_video <= 1)
  test_count <- test_df %>% pull(count)

  expect_equal(test_count, c(2, 2, 2, 2))

})

test_that("Wrangling script properly cuts off with seek_video", {
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")

  # Check to see that watched time over a minute once
  test_df <- wrangled_data %>%
    filter(user_id == "AndrewLim",
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
    filter(user_id == "MattEmery",
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
    filter(user_id == "AndrewLim",
           video_name == 'Programming: Video III')

  test_end_time <- max(test_df$min_into_video)

  expect_equal(test_end_time, 1)
})

test_that("calculate_segments_viewed properly counts segments", {
  start <- 1
  end <- 5
  segment_size <- 2
  acceptance_criteria <- 0.5
  
  expect_equal(calculate_segments_viewed(start, end, segment_size, acceptance_criteria), 0:3)
})

test_that("calculate_segments_viewed works when the start is 0", {
  start <- 0
  end <- 5
  segment_size <- 2
  acceptance_criteria <- 0.5
  
  expect_equal(calculate_segments_viewed(start, end, segment_size, acceptance_criteria), 0:3)
})

test_that("calculate_segments_viewed works when the first segment is not counted", {
  start <- 1.75
  end <- 5
  segment_size <- 2
  acceptance_criteria <- 0.5
  
  expect_equal(calculate_segments_viewed(start, end, segment_size, acceptance_criteria), 1:3)
})
