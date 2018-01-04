#' Import untidy student engagement csv file as an R dataframe object
#' @param input_course Name of course directory (eg. psyc1, spd1, etc)
#' @return tower_engage: Dataframe containing student engagement information 
#'   with videos and problems
#' @examples 
#' read_dirt_engagement_data(input_course = 'psyc1')
#' @export
read_dirt_engagement_data <- function(input_course){
  input_csv_path <- paste0("../inst/data/", 
                           input_course, 
                           "/tower_engage_dirt.csv")
  engage_dirt <- read_csv(input_csv_path)
  return(engage_dirt)
}


#' Remove initial messy strings in module_id column and rename mode column 
#' @param dirt_engagement_data tower_engage_dirt dataframe object
#' @return dirt_engagement_data : tidy dataframe adter wrangling
#' @examples 
#' clean_engagement_data(dirt_engagement_data = obtain_dirt_engagement_data)
#' @export
clean_engagement_data <- function(dirt_engagement_data){
  
  # Remove "i4x://" in column A_module_id
  dirt_engagement_data$module_id <- gsub("i4x://", 
                                         "", 
                                         dirt_engagement_data$module_id)

  # Rename column in engagement table
  colnames(dirt_engagement_data)[
    colnames(dirt_engagement_data) == 'B_mode'
  ] <- 'mode'
  
  # Transform activity levels.
  dirt_engagement_data <- dirt_engagement_data %>%
    mutate(activity_level = case_when(
      
      (.$activity_level < 1800) ~ "under_30_min",
      (.$activity_level >= 1800) & (.$activity_level < 18000) ~ "30_min_to_5_hr",
      (.$activity_level >= 18000) ~ "over_5_hr",
      is.na(.$activity_level) ~ "NA"
      
    ))
  
  return(dirt_engagement_data)
}


#' Write cleaned data as a csv into the specified course directory
#' @param input_course Name of course directory (ex. psyc1, spd1, etc)
#' @param cleaned_data Dataframe containing cleaned data. 
#' @examples 
#' write_tidy_engagement_data(
#'   input_course = 'psyc1', 
#'   cleaned_data = clean_engagement_data
#' )
#' @export
write_tidy_engagement_data <- function(input_course, cleaned_data) {
  
  # Make IO path
  output_csv_path <- paste0("../inst/data/", input_course, "/tower_engage.csv")
  
  # Save data frame to csv
  write_csv(x=cleaned_data, path=output_csv_path)
}


#' This function automatically reads a file named "tower_engage_dirt.csv"
#'   from the specified course directory and output a clean files named 
#'   "tower_engage.csv" in the same directory
#' @param input_course String of course directory name 
#' @examples
#' wrangle_video(input_course = "psyc1")
#' @export
wrangle_overview_engagement <- function(input_course){
  
  # Read in data
  dirt_engage <- read_dirt_engagement_data(input_course)

  # Clean data
  tidy_engage <- clean_engagement_data(dirt_engage)

  # Export data
  write_tidy_engagement_data(input_course = input_course, 
                             cleaned_data= tidy_engage)

}
