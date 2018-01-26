# Defining constants:
SEGMENT_SIZE <- 20  # (20 seconds) Size of segment for each video
MIN_DURATION <- 1  # (1 seconds) Minimum watch time in order to count a segment as being watched
MAX_DURATION <- 3600  # (1 hours) Maximum watch time in order to count a segment as being watched (more of an integrity check)
PLAYING_STATUS <- 1  # Video is playing
PAUSED_STATUS <- 0  # Video is paused
SECONDS_IN_MINUTE <- 60  # Number of seconds in a minute

#' Reads raw uncleaned .csv into a dataframe
#' @description Reads the raw generalized_video_heat.csv obtained through rbq.py 
#'   into a dataframe.
#' @param input_course Name of course directory (ex. psyc1, spd1, etc)
#' @param testing For developer use only. Boolean used to indicate to use 
#'   testing data.
#' @return \code{data}: Dataframe containing raw student track log information
#' @examples
#' obtain_raw_video_data(input_course = 'psyc1')
obtain_raw_video_data <- function(input_course, testing = FALSE) {
  input_csv_path <-
    paste0("../inst/data/", input_course, "/generalized_video_heat.csv")
  if (testing == TRUE)
  {
    input_csv_path <- "../inst/data/generalized_video_heat.csv"
  }
  data <- read_csv(input_csv_path)
  return(data)
}

#' Reads video_axis.csv file
#' @description Reads the video_axis csv obtained through rbq.py into a 
#'   dataframe. For documentation on how to use rbq.py, please see 
#'   www.temporaryreferencelink.com
#' @param input_course Name of course directory (ex. psyc1, spd1, etc)
#' @param testing For developer use only. Boolean used to indicate to use 
#'   testing data.
#' @return \code{video_axis}: Dataframe containing video course structure 
#'   information
#' @examples
#' obtain_video_axis_data(input_course = 'psyc1')
obtain_video_axis_data <- function(input_course, testing = FALSE) {
  input_csv_path <- paste0("../inst/data/", 
                           input_course, 
                           "/generalized_video_axis.csv")
  if (testing == TRUE) {
    input_csv_path <- "../inst/data/generalized_video_axis.csv"
  }
  video_axis <- read_csv(input_csv_path)
  return(video_axis)
}

#' Outputs cleaned data as csv
#' @description Writes cleaned data as a csv into the course correct directory
#' @param input_course Name of course directory (ex. psyc1, spd1, etc)
#' @param cleaned_data Dataframe containing cleaned data. This cleaned data is 
#'   typically obtained through
#' @param testing For developer use only. Boolean used to indicate to use 
#'   testing data.
#' \code{make_tidy_segments()}
#' @return No return value
#' @examples
#' write_wrangled_video_data(input_course = 'psyc1', cleaned_data=start_end_df)
write_wrangled_video_data <- function(input_course, 
                                      cleaned_data, 
                                      testing = FALSE) {
  # Making IO paths:
  output_csv_path <- paste0("../inst/data/", 
                            input_course, 
                            "/wrangled_video_heat.csv")
  
  if (testing == TRUE)
  {
    output_csv_path <- "../inst/data/wrangled_video_heat.csv"
  }
  
  # Save data frame to csv. This data frame is used for the video heat
  # map visualization.
  write_csv(x = cleaned_data, path = output_csv_path)
}


#' Converts columns into proper variable types and adds additional columns with 
#'   video information
#' @description  Additional columns added:
#'
#' - \code{max_stop_times}: proxy for video length
#'
#' - \code{course_order}: occurrence of video within course structure
#'
#' - \code{index_chapter}: occurrence of chapter within course structure
#'
#' - \code{chapter_name}: name of chapter
#'
#' @param data Raw input dataframe to be transformed. \code{data} is obtained 
#'   through \code{obtain_raw_video_data()}
#' @param video_axis A dataframe containing course structure information. 
#'   Contains columns course_order, index_chapter, chapter_name
#'
#' @return  \code{prepared_data}: The prepared data with converted variable 
#'   types and extra columns
#' @examples
#' prepare_video_data(data)
prepare_video_data <- function(video_data, video_axis)
{
  # Doing conversions:
  prepared_data <-
    video_data %>% dplyr::filter(is.na(user_id) == FALSE) %>%
    mutate(time = lubridate::ymd_hms(time)) %>% 
    arrange(time) %>% arrange(user_id) %>%
    mutate(new_speed = as.double(new_speed)) %>% 
    mutate(old_speed = as.double(old_speed)) %>%
    mutate(new_time = as.double(new_time)) %>% 
    mutate(old_time = as.double(old_time)) %>%
    mutate(speed_change_position = as.double(speed_change_position))
  
  # Obtain the max time recorded for each stop_video event by assuming
  # the mode stop time is the maximum video length.  This is better than
  # the video_length table available on big query which has some
  # inaccurate values (Ex :3 day long video lengths)
  max_stop_times <- prepared_data %>% 
    dplyr::filter(event_type == "stop_video") %>%
    dplyr::filter(position > 0) %>% 
    group_by(video_id) %>% 
    summarize(max_stop_position = get_mode(round(position)))
  
  extra_max_stop_times <- prepared_data %>% 
    filter(!video_id %in% unique(max_stop_times$video_id)) %>% 
    group_by(video_id) %>% 
    summarise(max_stop_position = max(round(position), na.rm = T))
  
  max_stop_times <- max_stop_times %>% 
    rbind(extra_max_stop_times) %>% 
    filter(max_stop_position > 0) %>% 
    arrange(video_id)
  
  # Place max video length column into dataframe This will be used as an
  # integrity check
  prepared_data <- prepared_data %>% 
    left_join(max_stop_times, by = "video_id")
  
  # This is used to put videos in proper course order.
  video_course_order <- video_axis %>% 
    semi_join(prepared_data, by = "video_id") %>%
    mutate(course_order = rank(index_video, ties.method = "min")) %>% 
    select(video_id, course_order, index_chapter, chapter_name)
  
  # Place course order column into dataframe This is how videos are ordered in 
  # the final plot
  prepared_data <- left_join(prepared_data, video_course_order, by = "video_id")
  
  return(prepared_data)
}

#' Obtains start and end times for video events
#' @description Parses dataframe and adds columns \code{start} and \code{end} 
#'   showing the start and end time that a user watched a video
#' @param data Dataframe containing tracklog data of students. This is obtained 
#'   typically through \code{prepare_video_data()}
#' @return \code{start_end_df}: Original dataframe with \code{start} and 
#'   \code{end} columns
#' @examples
#' get_start_end_df(data = data)
get_start_end_df <- function(data) {
  start_end_df <- data %>% 
    dplyr::filter(event_type != "load_video") %>%
    group_by(user_id) %>% 
    mutate(event_group = cumsum(event_type == "play_video")) %>% 
    ungroup() %>% 
    dplyr::filter(event_group > 0) %>%
    mutate(stop_event = (
      event_type != "speed_change_video" & event_type != "seek_video"
    )) %>% 
    group_by(user_id, event_group) %>% 
    mutate(stop_events = cumsum(stop_event)) %>%
    dplyr::filter(stop_events <= 2) %>% 
    mutate(
      event_type_next = lead(event_type),
      position_next = lead(position),
      old_time_next = lead(old_time),
      speed_change_position_next = lead(speed_change_position),
      time_ahead = lead(time),
      latest_speed = zoo::na.locf(new_speed, na.rm = FALSE)
    ) %>% 
    ungroup() %>%
    mutate(event_type_next = ifelse(is.na(event_type_next), 
                                    "DONE",
                                    event_type_next)) %>% 
    mutate(start = case_when(
      .$event_type == "play_video" ~ .$position,
      .$event_type == "seek_video" ~ .$new_time,
      .$event_type == "speed_change_video" ~ .$speed_change_position,
      TRUE ~ as.double(NA)
    )) %>% mutate(end = case_when(
      .$event_type_next == "pause_video" ~ .$position_next,
      .$event_type_next == "seek_video" ~ .$old_time_next,
      .$event_type_next == "speed_change_video" ~ .$speed_change_position_next,
      .$event_type_next == "page_close" ~ get_end_time(.$start, 
                                                       .$time, 
                                                       .$time_ahead, 
                                                       .$latest_speed),
      .$event_type_next == "seq_next" ~ get_end_time(.$start, 
                                                     .$time, 
                                                     .$time_ahead, 
                                                     .$latest_speed),
      .$event_type_next == "seq_prev" ~ get_end_time(.$start, 
                                                     .$time,
                                                     .$time_ahead, 
                                                     .$latest_speed),
      stringr::str_detect(.$event_type_next,
                          "problem") ~ get_end_time(.$start,
                                                    .$time, 
                                                    .$time_ahead, 
                                                    .$latest_speed),
      .$event_type_next == "stop_video" ~ .$position_next,
      TRUE ~ as.double(NA)
    )) %>%
    select(start, end, latest_speed, everything()) %>% 
    dplyr::filter(is.na(end) == FALSE) %>% 
    ungroup() %>% 
    mutate(max_stop_position = zoo::na.locf(max_stop_position)) %>%
    mutate(valid = check_integrity(start, end, max_stop_position)) %>%
    dplyr::filter(valid == TRUE) %>% 
    select(
      video_id,
      video_name,
      mode,
      gender,
      activity_level,
      max_stop_position,
      course_order,
      index_chapter,
      chapter = chapter_name,
      user_id,
      start,
      end
    )
  
  return(start_end_df)
}

calculate_segments_viewed <- function(start, 
                                      end, 
                                      segment_size, 
                                      acceptence_criteria) {
  end_segment <- end %/% segment_size
  start_segment <- start %/% segment_size
  
  if ((end %% segment_size) < acceptence_criteria) {
    end_segment <- end_segment - 1
  }
  
  if ((start %% segment_size) > (segment_size - acceptence_criteria)) {
    start_segment <- start_segment + 1
  }
  
  start_segment:end_segment
}

vector_calculate_segments_viewed <- Vectorize(calculate_segments_viewed, 
                                              vectorize.args = c("start", 
                                                                 "end"))


#' Returns original dataframe with segment columns
#' @description Returns original dataframe with segement columns. Segment 
#'   columns are 0 if the segment is not located within the start and end values
#'   and 1 otherwise.
#' @param data Dataframe containing start and end columns. This dataframe is 
#'   typically obtained through \code{get_start_end_df()}
#'
#' @return \code{data}: Original input dataframe with new segment columns
#'
#' @examples
#' get_watched_segments(data = start_end_df)
get_watched_segments <- function(data) {
  data <- data %>% 
    mutate(segment = vector_calculate_segments_viewed(start, 
                                                      end, 
                                                      SEGMENT_SIZE, 
                                                      MIN_DURATION)) %>% 
    tidyr::unnest(segment) %>% 
    mutate(
      min_into_video = ((segment * SEGMENT_SIZE) + (SEGMENT_SIZE / 2))
      / SECONDS_IN_MINUTE
    )
  
  return(data)
}


#' Returns tidy (more useable) version of input dataframe
#' @description Returns a tidy, more usable, version of the input dataframe. 
#'   Segment information is converted into a single column using \code{gather()}
#' @param data Dataframe containing segment information. This dataframe is 
#'   typically obtained through \code{get_watched_segments()}
#'
#' @return \code{data}: Tidy version of input dataframe.
#'
#' @examples
#' make_tidy_segments(data = start_end_df)
make_tidy_segments <- function(data) {
  
  # Filter out unwatched segments and select relevant columns:
  tidy_segment_df <- data %>%
    dplyr::filter(is.na(user_id) == FALSE) %>% 
    select(-start,-end) %>% 
    group_by(
      video_id,
      user_id,
      segment,
      min_into_video,
      video_name,
      mode,
      gender,
      activity_level,
      max_stop_position,
      course_order,
      index_chapter,
      chapter
    ) %>% 
    summarize(count = n()) %>% 
    ungroup() %>% 
    group_by(video_id) %>% 
    mutate(last_segment = max(segment, na.rm = T)) %>% 
    ungroup()
  
  tidy_segment_df %>% 
    group_by(video_id) %>% 
    summarize(course_order = unique(course_order)) %>% 
    print()
  
  return(tidy_segment_df)
}

#' Checks to make sure start and end data passes sanity checks
#' @description Returns a boolean of whether or not start and end data makes 
#'   sense. This checks for NA values, end times that are passed the maximum 
#'   length of the video, and extremely long and short watch durations.
#'   The threshold for watch durations can be adjusted in the global constants: 
#'   \code{MIN_DURATION} and \code{MAX_DURATION}
#' @param start Time into video that the user has started watching the video
#' @param end Time into the video that the user has stopped watching the video
#' @param max_stop_position Length of the video being watched
#'
#' @return \code{integrity}: Boolean of whether or not the data passes integrity 
#'   checks
#'
#' @examples
#' check_integrity(start, end, max_stop_position)
check_integrity <- function(start, end, max_stop_position) {
  watch_duration <- end - start
  
  na_check <- is.na(end) | is.na(start)
  passed_ending_check <- end > max_stop_position
  start_larger_than_end_check <- end < start
  start_is_not_neg_check <- start < 0
  watch_duration_check <- (watch_duration < MIN_DURATION) | (watch_duration > MAX_DURATION)
  
  all_checks <-
    !(
      na_check | passed_ending_check | start_larger_than_end_check |
        start_is_not_neg_check | watch_duration_check 
    )
  
  return(all_checks)
}

#' Calculates video end time for non-video events using time stamps
#' @param start Time into video that the user has started watching the video
#' @param time Time stamp of when the user started watching the video
#' @param time_ahead Time stamp of next event following the play event
#' @param latest_speed The speed at which the user was watching the video
#'
#' @return \code{end}: Time into video that the user has stopped watching
#'
#' @examples
#' get_end_time(start, time, time_ahead, latest_speed)
get_end_time <- function(start, time, time_ahead, latest_speed) {
  # Assume speed of one:
  latest_speed[is.na(latest_speed)] <- 1
  
  duration <- as.double(difftime(time_ahead, time, units = "secs"))
  end <- as.double(start) + latest_speed * duration
  end
}

#' Obtain most common value from list
#' @param x List containing integer values
#'
#' @return \code{mode}: The most common value within the list
#'
#' @examples
#' get_mode(x=c(0,1,2,2,2,3))
get_mode <- function(x) {
  xtab <- table(x)
  max_val_index <- length(which(xtab == max(xtab)))
  as.double(names(xtab)[which(xtab == max(xtab))[[max_val_index]]])
}

#' Generates cleaned video data as a csv within a specified course directory
#' @description This function will automatically read files named 
#'   'generalized_video_heat.csv' and 'generalized_video_axis.csv' from the 
#'   specified course directory and output a csv named wrangled_video_heat.csv' 
#'   in the same directory
#' @param input_course String of short name of course directory
#'
#' @return No value returned
#' @export
#'
#' @examples
#' wrangle_video(input_course = 'psyc1')
wrangle_video <- function(input_course, testing = FALSE) {
  # Reading data
  data <- obtain_raw_video_data(input_course, testing)
  video_axis <- obtain_video_axis_data(input_course, testing)
  
  # Convert to appropriate type and arrangement:
  data <- prepare_video_data(data, video_axis)
  
  # Obtains start and end watch times per relevant video events
  start_end_df <- get_start_end_df(data)
  
  # Add segment columns to dataframe to see whether or not the segment is
  # within the start and end times
  start_end_df <- get_watched_segments(start_end_df)
  
  # Make tidy data:
  tidy_segment_df <- make_tidy_segments(start_end_df)
  
  # Write data:
  write_wrangled_video_data(input_course = input_course, 
                            cleaned_data = tidy_segment_df,
                            testing)
}
