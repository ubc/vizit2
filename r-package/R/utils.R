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



cut_activity_levels <- function(df, input_activity_name = "sum_dt", output_activity_name = "activity_level") {
  quo_input <- dplyr::enquo(input_activity_name)
  quo_output <- dplyr::enquo(output_activity_name)

  lazy_cuts <- rlang::exprs(
    .data[[x]] < 1800 ~ "under_30_min",
    .data[[x]] < 18000 ~ "30_min_to_5_hr",
    .data[[x]] >= 18000 ~ "over_5_hr"
  )

  x <- rlang::UQE(quo_input)

  df <- df %>%
    dplyr::filter(!is.na(quo_input))


  # lazy_na <- rlang::expr(!is.na(sum_dt))
  df %>%
    dplyr::mutate(activity_level = dplyr::case_when(!!! lazy_cuts)) %>%
    dplyr::select(-one_of(!!quo_input))

}

minimal_case <- function(column_name = a) {
  enquo_name <- rlang::enquo(column_name)

  example_dataframe <- dplyr::tibble(a = c(NA, 1))

  print(filter(example_dataframe, !is.na(a)))

  example_dataframe %>%
    filter(!is.na(a))

  print(filter(example, !is.na(!!enquo_name)))

}

minimal_case <- function(column_name = "a") {
  example <- tibble(a = c(NA, 1))

  print(filter(example, !is.na(a)))

  print(filter(example, !is.na(!!rlang::sym(column_name))))

}

minimal_case("a")
