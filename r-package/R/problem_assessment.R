#' Convert a JSON object into a tidyJSON dataframe
#'
#' @param assessment_json An JSON file generated through `xml_extraction <course> --assessments`
#'
#'
#' @return A flattened dataframe with the columns `url_name`, `title`, `label`, `name`
#' @export
extract_assessment_json <- function(assessment_json) {

  extracted_content <- assessment_json %>%
    tidyjson::gather_array() %>%
    tidyjson::spread_values(url_name = tidyjson::jstring("url_name"),
                  title = tidyjson::jstring("title")) %>%
    tidyjson::enter_object("labels") %>%
    tidyjson::gather_array() %>%
    tidyjson::spread_values(label = tidyjson::jstring("label"),
                            name = tidyjson::jstring("name")) %>%
    dplyr::select(-document.id, -array.index)

  counted_content <- extracted_content %>%
    dplyr::group_by(url_name) %>%
    dplyr::count() %>%
    dplyr::filter(n > 1) %>%
    dplyr::ungroup()

  dplyr::semi_join(extracted_content, counted_content)
}

#' Convert a CSV respresenting an open_assessment.sql query into a usable format
#'
#' Extracts the nececessary information from event JSON and discards it. Points
#' possible should always be the same for each assessment.
#'
#' @param assessment_tbl
#'
#' @return An extracted table
#' @export
#' @examples
#' extract_assessment_csv(raw_assessment)
extract_assessment_csv <- function(assessment_tbl) {
  name_extraction <-
    "\\\"points_possible\\\": \\d+, \\\"name\\\": \\\"(\\S+)\\\""

  extracted_assessment <- assessment_tbl %>%
    dplyr::mutate(assessment_id = stringr::str_extract(module_id, "[0-9a-f]{32}")) %>%
    dplyr::mutate(
      points_possible = gsubfn::strapply(event, "\\\"points_possible\\\": (\\d+)",
                                 as.numeric),
      points = gsubfn::strapply(event, "\\\"points\\\": (\\d+)", as.numeric),
      name = gsubfn::strapply(event, name_extraction)
    ) %>%
    tidyr::unnest() %>%
    dplyr::filter(!is.na(sum_dt)) %>%
    dplyr::select(-event, -module_id, -time, -sum_dt, -time)
}

#' Join the results of extract_assessment_csv and extract_assessment_json
#'
#' This function joins the BigQuery and XML data. This is needed to populate the
#' BigQuery data with the title and label fields. If the ID of the assessment
#' does not occur in the XML, it is removed before preceding.
#'
#' @param extracted_csv the result of extract_assessment_csv
#' @param extracted_json the result of extract_assessment_csv
#'
#' @return A joined dataframe of the two incoming dataframes
#' @export
join_extracted_assessment_data <- function(extracted_csv, extracted_json) {
    joint_assessment <- left_join(extracted_csv,
                                  extracted_json,
                                  by = c(assessment_id = "url_name",
                                         name = "name")) %>%
      filter(!is.na(label))
  }



#' Summarise assessment data for plotting
#'
#' This function checks that the number of points possible does not vary within
#' title-label groups.
#'
#' @param joint_assessment The result of join_extracted_assessment_data
#' @param trunc_length The length of that the label should be truncated to. Do
#'   set to less than 4
#'
#' @return A summarised dataframe of the average scores in each area.
#' @export
summarise_joined_assessment_data <- function(joint_assessment, trunc_length = 20) {
    points_possible_all_same <- joint_assessment %>%
      group_by(title, label) %>%
      filter(min(points_possible) != max(points_possible))

    if (nrow(points_possible_all_same) != 0)  {
      warning("points_possible different within title/label group")
    }

    summary_assessment <- joint_assessment %>%
      group_by(title, label) %>%
      summarise(
        avg_score = mean(points),
        avg_percent = mean(points) / max(points_possible)
      ) %>%
      mutate(trunc_label = stringr::str_trunc(label, trunc_length))
  }

#' Plot the summary assessment data
#'
#' @param summary_assessment the resulting dataframe from `summary_assessment`
#'
#' @return A faceted bar plot
#' @export
plot_assessment <- function(summary_assessment) {
  ggplot(summary_assessment, aes(x = label, y = avg_percent)) +
    geom_bar(stat = "identity", fill = "#66c2a5") +
    geom_text(
      aes(
        label = trunc_label,
        x = label,
        y = 0,
        hjust = 0
      ),
      color = "black",
      check_overlap = TRUE,
      size = 4
    ) +
    facet_wrap( ~ title, scales = "free") +
    ggthemes::theme_few(base_family = "sanserif") +
    theme(axis.text.y = element_blank()) +
    coord_flip() +
    scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    labs(x = "Criterion", y = "Score")
}
