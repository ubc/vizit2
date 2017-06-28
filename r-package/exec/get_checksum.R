devtools::load_all()

#' Writes csv with course short names and their corresponding checksums to the data directory
#'
#' @return No value is returned
#'
#' @examples get_hashed_courses()
get_hashed_courses <- function(){
  courses <- jsonlite::fromJSON("../../.config.json")$courses[[1]]
  
  hashed_courses_df <- courses %>% 
    mutate(checksum = sapply(short_name, digest::digest)) %>% 
    select(short_name, checksum)
  
  write_csv(hashed_courses_df, "../data/.hashed_courses.csv")
}


#' Writes csv with dashboard name and their corresponding checksums to the data directory
#'
#' @return No value is returned
#'
#' @examples get_hashed_dashboard()
get_hashed_dashboard <- function(){
  dashboard <- c("general", "video", "overview", "linkpage", "forum", "problems")
  
  hashed_dashboards_df <- data.frame(dashboard) %>% 
    mutate(checksum = sapply(dashboard, digest::digest))
  
  write_csv(hashed_dashboards_df, "../data/.hashed_dashoards.csv")
}

