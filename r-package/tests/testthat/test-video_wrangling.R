context("Testing video wrangling.")

test_that("Wrangling script properly counts rewatches via seek_video", {
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")

  # Check to see that watched time under a minute twice
  test_df <- wrangled_data %>%
    filter(user_id == "AndrewLim",
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

test_that("gather_one_column gathers only one column", {
  test_gather_df <- tribble(
    ~video_id, ~user_id, ~`0`, ~`1`,
    1        , 1       , 1   , 0   ,
    1        , 1       , 0   , 1  
  )
  
  test_gathered_df <- tribble(
    ~video_id, ~user_id, ~segment, ~count,
    1        , 1       , 0L       , 1
  )
  expect_equal(gather_one_column(test_gather_df, `0`), test_gathered_df)
})

test_that("iterative gather works like gather", {
  test_gather_df <- tribble(
    ~video_id, ~user_id, ~`0`, ~`1`,
    1        , 1       , 1   , 0   ,
    1        , 1       , 0   , 1  
  )
  start_segment_column <- 3
  
  test_gathered_df <- test_gather_df %>% 
    gather(tidy_segment_df, key = segment, value = count,
           convert = TRUE,
           (start_segment_column):ncol(test_gathered_df)) %>% 
    filter(count > 0)
  
  expect_equal(iterative_gather(test_gather_df), test_gathered_df)
})