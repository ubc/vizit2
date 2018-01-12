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
    sep = "/"
  ))

assessment_json <-
  tidyjson::read_json(paste(
    "..",
    "inst",
    "data",
    input_course,
    "assessments.json",
    sep = "/"
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
    sep = "/"
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
    sep = "/"
  )
)
