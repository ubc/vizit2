devtools::load_all()

args <- commandArgs(TRUE)
input_course <- args[1]

assessment_tbl <-
  readr::read_csv(paste(
    "..",
    "inst",
    "data",
    input_course,
    "open_assessment.csv",
    collapse = "/"
  )) %>%
  dplyr::mutate(
    activity_level = dplyr::case_when(
      (.$sum_dt < 1800) ~ "under_30_min",
      (.$sum_dt >= 1800) &
        (.$sum_dt < 18000) ~ "30_min_to_5_hr",
      (.$sum_dt >= 18000) ~ "over_5_hr",
      is.na(.$sum_dt) ~ "NA"
    )
  )

assessment_json <-
  tidyjson::read_json(paste(
    "..",
    "inst",
    "results",
    input_course,
    "assessments.json",
    collapse = "/"
  ))

extracted_content <- extract_assessment_json(assessment_json)


readr::write_csv(
  extracted_content,
  paste(
    "..",
    "inst",
    "data",
    input_course,
    "wrangled_assessment_json_info.csv",
    collapse = "/"
  )
)


extracted_assessment_tbl <- assessment_tbl %>%
  extract_assessment_csv()


readr::write_csv(
  extracted_assessment_tbl,
  paste(
    "..",
    "inst",
    "data",
    input_course,
    "wrangled_assessment_csv_info.csv",
    collapse = "/"
  )
)
