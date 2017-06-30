#' Writes csv with course short names and their corresponding checksums to the data directory
#'
#' @return No value is returned
#'
#' @examples get_hashed_courses()
#' @importFrom magrittr "%>%"
#' @export
get_hashed_courses <- function(input_json, output_csv) {
  
  if (missing(input_json)) {
    input_json <- "../.config.json"
  }
  
  if (missing(output_csv)) {
    output_csv <- "data/.hashed_courses.csv"
    
  }
  
  courses <- jsonlite::fromJSON(input_json)$courses[[1]]
  
  hashed_courses_df <- courses %>% 
    dplyr::mutate(checksum = sapply(short_name, digest::digest)) %>% 
    dplyr::select(short_name, checksum)
  
  readr::write_csv(hashed_courses_df, output_csv)
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
  
  write_csv(hashed_dashboards_df, "data/.hashed_dashoards.csv")
}

