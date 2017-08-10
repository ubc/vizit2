#' Read CSV course data
#'
#' Will add the ".csv" if not included in `csv_name`
#'
#' @param course_name string short name of the course
#' @param csv_name string of the name of the csv
#' @param data_dir character vector of the relative path
#'
#' @return dataframe of read_csv results
read_course_csv <- function(course_name, csv_name, data_dir = c("..", "data")) {
  if (!endsWith(csv_name, ".csv")) {
    csv_name <- paste0(csv_name, ".csv")
  }

  data_dir_string <- paste0(data_dir, collapse = "/")

  file_path <-
    paste(data_dir_string, course_name, csv_name, sep = "/")

  readr::read_csv(file_path)
}
