context("Testing video server script")

test_that("Watch rate calculation test",{
  # Reading data:
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")
  
  aggregated_segment_df <- get_aggregated_df(wrangled_data, 10)
  
  # Check to see that watched time under a minute twice
  test_df <- aggregated_segment_df %>%
    filter(video_name == 'Programming: Video I',
           min_into_video > 1)
  
  test_watch_rate <- test_df$watch_rate
  expect_equal(test_watch_rate, rep(1, nrow(test_df)))
  
  # Check to see that watched time under a minute twice
  test_df <- aggregated_segment_df %>%
    filter(video_name == 'Programming: Video III',
           min_into_video > 1)
  
  test_watch_rate <- test_df$watch_rate
  expect_equal(test_watch_rate, rep(0.33, nrow(test_df)))
  
  # Check to see that watched time under a minute twice
  test_df <- aggregated_segment_df %>%
    filter(video_name == 'Programming: Video I',
           min_into_video <= 1)
  
  test_watch_rate <- test_df$watch_rate
  expect_equal(test_watch_rate, rep(1.33, nrow(test_df)))
})

test_that("Count calculation test",{
  # Reading data:
  wrangle_video("testing", test=TRUE)
  wrangled_data <- read_csv("data/wrangled_video_heat.csv")
  
  # Obtaining dataframe with correct calculation
  test_data <- wrangled_data %>% 
    group_by(video_id, min_into_video) %>% 
    summarize(test_count = sum(count))
  
  # Using function to be tested
  aggregated_segment_df <- get_aggregated_df(wrangled_data, 10)
  
  # Joining
  aggregated_segment_df <- aggregated_segment_df %>% 
    left_join(test_data, by=c("video_id", "min_into_video"))
  
  # Testing
  expect_equal(aggregated_segment_df$count, aggregated_segment_df$test_count)
})