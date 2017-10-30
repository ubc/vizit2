#' Aggregates dataframe by video and segment
#' @description Aggregates input dataframe by video (video_id) and segment (min_into_video).
#' Additionally, adds columns:
#'
#' - \code{unique_views}/\code{`Students`} (number of learners who started the video),
#'
#' - \code{watch_rate}/\code{`Views per Student`} (number of students who have watched the segment divided by unique_views),
#'
#' - \code{avg_watch_rate} (average of watch_rate per video)
#' 
#' - \code{high_low} ('High Watch Rate', 'Low Watch Rate, or 'Normal')
#' 
#' - \code{up_until} (1 if the average learner had watched up until the particular min_into_video, 0 if they had not)
#'
#' @param filt_segs Dataframe containing students that have been filtered by selected demographics. Typically
#' obtained via \code{filter_demographics()}
#' @param top_selection Value of the number of top segments to highlight.
#'
#' @return \code{aggregate_segment_df}: Aggregated dataframe with additional columns
#' @export
#'
#' @examples
#' get_aggregated_df(filt_segs, 25)
get_aggregated_df <- function(filt_segs, top_selection) {
  aggregate_segment_df <- filt_segs %>% 
    dplyr::filter(is.na(user_id) == FALSE) %>% 
    group_by(video_id, min_into_video) %>% summarize(count = sum(count), 
                                                     course_order = unique(course_order), 
                                                     vid_length = unique(max_stop_position), 
                                                     video_name = unique(video_name)) %>% 
    mutate(min_into_video = as.double(min_into_video)) %>% 
    ungroup()
  
  # Getting dataframe with number of unique user views of videos Note:
  # This still counts scenarios if a person watches a video for 0.125
  # seconds No thresholding has been conducted.
  unique_views <- filt_segs %>% 
    group_by(video_id) %>% 
    summarize(unique_views = n_distinct(user_id)) %>% 
    arrange(unique_views) %>% ungroup()
  
  # Place number of unique view column into dataframe:
  aggregate_segment_df <- aggregate_segment_df %>% 
    left_join(unique_views, by = "video_id") %>% 
    mutate(watch_rate = count/unique_views) %>% 
    mutate(`Views per Student` = round(watch_rate, 2)) %>% 
    mutate(Students = unique_views) %>% 
    mutate(watch_rate = round(watch_rate, 2))
  
  # Only select segments within videos that have been watched at least
  # once This is the data frame that is used to make plots:
  aggregate_segment_df <- aggregate_segment_df[aggregate_segment_df$count > 0, ] %>% 
    ungroup()
  
  # Create dataframe with average watch rate of videos:
  avg_watch_rate_df <- aggregate_segment_df %>% group_by(video_id) %>% 
    summarize(avg_watch_rate = round(mean(watch_rate), 2)) %>% ungroup()
  
  # Obtain average watch rate:
  aggregate_segment_df <- aggregate_segment_df %>% left_join(avg_watch_rate_df, 
                                                             by = "video_id") %>% dplyr::filter(is.na(video_name) == FALSE)
  
  # Correcting course order:
  aggregate_segment_df <- aggregate_segment_df %>% mutate(course_order = get_rank(course_order))
  
  # Making linear model to predict watch_rate
  model <- lm(watch_rate ~ course_order + min_into_video, aggregate_segment_df)
  
  # Finding most postiive and negative residuals:
  model_df <- data.frame(predict(model, interval = "confidence")) %>% 
    mutate(actual = aggregate_segment_df$watch_rate) %>% mutate(residual = actual - 
                                                                  fit) %>% mutate(negative_rank = get_rank(residual)) %>% mutate(positive_rank = get_rank(-residual)) %>% 
    mutate(top_negative = as.integer(negative_rank <= top_selection)) %>% 
    mutate(top_positive = as.integer(positive_rank <= top_selection)) %>% 
    mutate(high_low = case_when(.$top_positive == 1 ~ "High Watch Rate", 
                                .$top_negative == 1 ~ "Low Watch Rate", TRUE ~ "Normal"))
  
  # Adding positive and negative residual ranks to dataframe:
  aggregate_segment_df <- aggregate_segment_df %>% mutate(high_low = model_df$high_low)
  
  up_until_df <- filt_segs %>% group_by(video_id, user_id) %>% summarize(max_min = max(min_into_video)) %>% 
    ungroup() %>% group_by(video_id) %>% summarize(up_until = mean(max_min))
  
  aggregate_segment_df <- aggregate_segment_df %>% left_join(up_until_df, 
                                                             by = "video_id") %>% mutate(up_until = case_when(.$min_into_video <= 
                                                                                                                .$up_until ~ 1, TRUE ~ 0)) %>% mutate(video_id = forcats::fct_reorder(video_id, 
                                                                                                                                                                                      course_order))
  # Filter out segments with watchrates of less than 1%
  aggregate_segment_df <- aggregate_segment_df %>% 
    filter(watch_rate > 0.01)
  
  return(aggregate_segment_df)
}

#' Obtains locations of chapter lines to be placed on visualizations
#' @param filt_segs Dataframe containing students that have been filtered by selected demographics. Typically
#' obtained via \code{filter_demographics()}
#'
#' @return \code{ch_markers}: List of values of where to place chapter lines on visualizations
#'
#' @examples
#' get_ch_markers(filt_segs)
get_ch_markers <- function(filt_segs) {
  video_ch_markers <- filt_segs %>% group_by(video_id) %>% summarize(index_chapter = unique(index_chapter), 
                                                                     course_order = unique(course_order)) %>% ungroup() %>% arrange(desc(course_order)) %>% 
    mutate(course_order = rank(course_order)) %>% mutate(last_vid_in_ch = index_chapter != 
                                                           lead(index_chapter)) %>% mutate(ch_marker = ifelse(last_vid_in_ch, 
                                                                                                              course_order, NA)) %>% select(video_id, ch_marker)
  
  ch_markers <- unique(video_ch_markers$ch_marker[!is.na(video_ch_markers$ch_marker)]) - 
    0.5
  return(ch_markers)
}

#' Obtains dataframe with length of videos
#' @param filt_segs Dataframe containing students that have been filtered by selected demographics. Typically
#' obtained via \code{filter_demographics()}
#'
#' @return \code{vid_lengths}: Dataframe with the video lengths associated with each video ID.
#'
#' @examples
#' get_video_lengths(filt_segs)
get_video_lengths <- function(filt_segs) {
  vid_lengths <- filt_segs %>% group_by(video_id) %>% summarise(`Video length (minutes)` = round(unique(max_stop_position/SECONDS_IN_MINUTE), 
                                                                                       2))
  
  return(vid_lengths)
}

#' Obtains video summary table to be used on shiny app
#' @param aggregate_df Dataframe containing students that have been filtered by selected demographics. Typically
#' obtained via \code{filter_demographics()}
#' @param vid_lengths Dataframe containing video ID's with their associated video lengths. Typically
#' obtained via \code{get_video_lengths()}
#'
#' @return \code{summary_table}: Dataframe relevant summary statistics for each video.
#'
#' @examples
#' get_summary_table(filt_segs, vid_lengths)
get_summary_table <- function(aggregate_df, vid_lengths, avg_time_spent) {
  summary_tbl <- aggregate_df %>% ungroup() %>% group_by(video_id) %>% 
    summarize(`Avg Views per Student` = mean(watch_rate), Students = unique(unique_views), 
              course_order = max(course_order), video_name = unique(video_name)) %>% 
    mutate(`Avg Views per Student` = round(`Avg Views per Student`, 
                                           2)) %>% left_join(vid_lengths, by = "video_id") %>% left_join(avg_time_spent, 
                                                                                                         by = "video_id") %>% mutate(avg_time_spent = avg_time_spent/SECONDS_IN_MINUTE) %>% 
    mutate(time_spent_per_vid_length = round(avg_time_spent/`Video length (minutes)`, 
                                             2)) %>% mutate(video_id = forcats::fct_reorder(video_id, course_order)) %>% 
    select(-video_id) %>% select(video_name, everything()) %>% arrange(desc(course_order)) %>% 
    rename(`Video Name` = video_name) %>% #rename(`Avg Time Spent per Video Length` = time_spent_per_vid_length) %>% 
    select(-course_order, -avg_time_spent, -time_spent_per_vid_length)
  
  return(summary_tbl)
}

#' Obtains heatmap plot comparing videos against each other
#' @param filtered_segments Dataframe of segments and corresponding watch counts filtered by demographics
#' @param module String of module (chapter) name to display
#' @param filtered_ch_markers List of values containing locations of where to put chapter markers
#'
#' @return \code{g}: ggplot heatmap object
#'
#' @examples
#' get_video_comparison_plot(filtered_segments, module, filtered_ch_markers)
get_video_comparison_plot <- function(filtered_segments, module, filtered_ch_markers) {
  g <- ggplot(filtered_segments, aes_string(fill = "`Students`", x = "min_into_video", 
                                            y = "video_id", text = "paste0(video_name, \"<br>\",
                                            watch_rate, \" times viewed per student\", \"<br>\",
                                            count, \" times this segment was watched (raw)\", \"<br>\",
                                            unique_views, \" students started this video\")")) + 
    geom_tile() + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), 
                        axis.ticks.y = element_blank()) + ggthemes::theme_few(base_family = "GillSans") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + 
    xlab("Length of Video (minutes)") + ylab("Video") + viridis::scale_fill_viridis()
  
  if (module == "All") {
    g <- g + geom_hline(yintercept = filtered_ch_markers)
  }
  
  return(g)
}

#' Obtains heatmap plot comparing segments against each other
#' @param filtered_segments Dataframe of segments and corresponding watch counts filtered by demographics
#' @param module String of module (chapter) name to display
#' @param filtered_ch_markers List of values containing locations of where to put chapter markers
#'
#' @return \code{g}: ggplot heatmap object
#'
#' @examples
#' get_segment_comparison_plot(filtered_segments, module, filtered_ch_markers)
get_segment_comparison_plot <- function(filtered_segments, module, filtered_ch_markers) {
  g <- ggplot(filtered_segments, aes_string(fill = "watch_rate", x = "min_into_video", 
                                            y = "video_id", text = "paste0(video_name, \"<br>\",
                                            watch_rate, \" views per student\", \"<br>\",
                                            count, \" times this segment was watched (raw)\", \"<br>\",
                                            unique_views, \" students started this video\")")) + 
    geom_tile() + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), 
                        axis.ticks.y = element_blank()) + ggthemes::theme_few(base_family = "GillSans") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + 
    xlab("Length of video (minutes)") + ylab("Video") + viridis::scale_fill_viridis(name = "Views per learner<br>who started the<br>video ('watch rate')")
  
  if (module == "All") {
    g <- g + geom_hline(yintercept = filtered_ch_markers)
  }
  
  return(g)
}

#' Obtains heatmap with segments of highest watch rate highlighted
#' @param filtered_segments Dataframe of segments and corresponding watch counts filtered by demographics
#' @param module String of module (chapter) name to display
#' @param filtered_ch_markers List of values containing locations of where to put chapter markers
#'
#' @return \code{g}: ggplot heatmap object
#'
#' @examples
#' get_top_hotspots_plot(filtered_segments, module, filtered_ch_markers)
get_top_hotspots_plot <- function(filtered_segments, module, filtered_ch_markers) {
  g <- ggplot(filtered_segments, aes_string(fill = "top_watch_rate", 
                                            x = "min_into_video", y = "video_id", text = "paste0(video_name, \"<br>\",
                                            watch_rate, \" views per student\", \"<br>\",
                                            count, \" times this segment was watched\", \"<br>\",
                                            unique_views, \" students started this video\")")) + 
    geom_tile() + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), 
                        axis.ticks.y = element_blank()) + ggthemes::theme_few(base_family = "GillSans") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + 
    xlab("Length of Video (minutes)") + ylab("Video") + viridis::scale_fill_viridis(guide = FALSE)
  
  if (module == "All") {
    g <- g + geom_hline(yintercept = filtered_ch_markers)
  }
  
  return(g)
}

#' Obtains heatmap plot highlighting which segments have abnormally high or low watch rates
#' @param filtered_segments Dataframe of segments and corresponding watch counts filtered by demographics
#' @param module String of module (chapter) name to display
#' @param filtered_ch_markers List of values containing locations of where to put chapter markers
#'
#' @return \code{g}: ggplot heatmap object
#'
#' @examples
#' get_high_low_plot(filtered_segments, module, filtered_ch_markers)
get_high_low_plot <- function(filtered_segments, module, filtered_ch_markers) {
  g <- ggplot(filtered_segments) + geom_tile(aes(fill = high_low, x = min_into_video, 
                                                 y = video_id, text = paste0(video_name, "<br>", watch_rate, " views per student", 
                                                                             "<br>", count, " times this segment was watched", "<br>", unique_views, 
                                                                             " students started this video"))) + theme(axis.title.y = element_blank(), 
                                                                                                                       axis.text.y = element_blank(), axis.ticks.y = element_blank()) + 
    ggthemes::theme_few(base_family = "GillSans") + theme(axis.text.y = element_blank(), 
                                                          axis.ticks.y = element_blank()) + xlab("Length of Video (minutes)") + 
    ylab("Video") + scale_fill_manual(values = c("#F8E85D", "#488C93", 
                                                 "#3D0752"), name = "Legend")
  
  if (module == "All") {
    g <- g + geom_hline(yintercept = filtered_ch_markers)
  }
  
  return(g)
}

#' Obtains heatmap plot highlighting which segment has been watched up until on average
#' @param filtered_segments Dataframe of segments and corresponding watch counts filtered by demographics
#' @param module String of module (chapter) name to display
#' @param filtered_ch_markers List of values containing locations of where to put chapter markers
#'
#' @return \code{g}: ggplot heatmap object
#'
#' @examples
#' get_up_until_plot(filtered_segments, module, filtered_ch_markers)
get_up_until_plot <- function(filtered_segments, module, filtered_ch_markers) {
  g <- ggplot(filtered_segments, aes_string(fill = "up_until", x = "min_into_video", 
                                            y = "video_id", text = "paste0(video_name, \"<br>\",
                                            watch_rate, \" views per student\", \"<br>\",
                                            count, \" times this segment was watched\", \"<br>\",
                                            unique_views, \" students started this video\")")) + 
    geom_tile() + theme(axis.title.y = element_blank(), axis.text.y = element_blank(), 
                        axis.ticks.y = element_blank()) + ggthemes::theme_few(base_family = "GillSans") + 
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank()) + 
    xlab("Length of Video (minutes)") + ylab("Video") + scale_fill_gradient(low = "gray86", 
                                                                            high = "skyblue", guide = FALSE)
  
  if (module == "All") {
    g <- g + geom_hline(yintercept = filtered_ch_markers)
  }
  
  return(g)
}

#' Returns the ranking of a vector x
#' @param x A vector of numeric values
#'
#' @return \code{g}: The ranking of the values within x
#'
#' @examples
#' get_rank(c(10, 20, 20, 22, 5))
get_rank <- function(x) {
  x_unique <- unique(x)
  ranks <- rank(x_unique)
  ranked <- ranks[match(x, x_unique)]
  return(ranked)
}

#' Returns a dataframe with the average time learners spent on each video
#' @param filtered_segments Dataframe of segments and corresponding watch counts filtered by demographics
#'
#' @return \code{g}: A dataframe with the average time learners spent on each video
#'
#' @examples
#' get_avg_time_spent(filtered_segments)
get_avg_time_spent <- function(filtered_segments) {
  
  avg_time_spent <- filtered_segments %>% group_by(user_id, video_id) %>% 
    summarize(time_spent = sum(count) * SEGMENT_SIZE) %>% ungroup() %>% 
    group_by(video_id) %>% summarize(avg_time_spent = mean(time_spent))
  
  return(avg_time_spent)
}

#' Appends 'All' to the list of chapter names to be used in the filtering panel
#'
#' @param chap_name A list of chapter names belonging to the course
#'
#' @return The list of chapter names appended with 'All'
#'
#' @examples get_module_options(c('Chapter 1', 'Chapter 2', 'Chapter 3'))
get_module_options <- function(chap_name) {
  module_options <- append("All", chap_name)
  return(module_options)
}
