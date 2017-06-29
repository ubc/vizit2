filter_demographics <- function(input_df, gender = "all", activity_level = "all", mode = "all") {
  filtered_df <- input_df
  if (gender == "female") {
    filtered_df <- filtered_df %>% filter(gender == "f")
  }
  if (gender == "male") {
    filtered_df <- filtered_df %>% filter(gender == "m")
  }
  if (gender == "other") {
    filtered_df <- filtered_df %>% filter(gender == "o")
  }
  if (activity_level == "under_30_min") {
    filtered_df <- filtered_df %>% filter(activity_level == "under_30_min")
  }
  if (activity_level == "30_min_to_5_hr") {
    filtered_df <- filtered_df %>% filter(activity_level == "30_min_to_5_hr")
  }
  if (activity_level == "over_5_hr") {
    filtered_df <- filtered_df %>% filter(activity_level == "over_5_hr")
  }
  if (mode == "audit") {
    filtered_df <- filtered_df %>% filter(mode == "audit")
  }
  if (mode == "verified") {
    filtered_df <- filtered_df %>% filter(mode == "verified")
  }
  
  return(filtered_df)
}

filter_chapter <- function(input_df, chapter_filter = "All") {
  if (is.null(chapter_filter)){
    chapter_filter = "All"
  }
  if (chapter_filter == "All") {
    input_df
  }
  else {
    filtered_df <- input_df %>%
      filter(chapter == chapter_filter) # I removed the fct_drop in the universal fucntion
    filtered_df
  }
}

