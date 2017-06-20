
#' Reads in tower_engage_dirt.csv file
#' @param input_course Name of course directory (ex. psyc1, spd1, marketing, etc)
#' @return \code{tower_engage}: Dataframe containing student engagement information with videos and problems
#' @examples 
#' read_dirt_engagement_data(input_course = 'psyc1')
read_dirt_engagement_data <- function(input_course){
  input_csv_path <- paste0("../data/", input_course, "/tower_engage_dirt.csv")
  engage_dirt <- read_csv(input_csv_path)
  return(engage_dirt)
}



#' Clean engagement data into tidy format
#' @param dirt_engagement_data tower_engage_dirt dataframe object
#' @return dirt_engagement_data
#' @export
#' @examples 
#' clean_engagement_data(dirt_engagement_data = obtain_dirt_engagement_data)

clean_engagement_data <- function(dirt_engagement_data){
  
  # Remove "i4x://" in column A_module_id
  dirt_engagement_data$module_id <- gsub("i4x://", "", dirt_engagement_data$module_id)

  # Rename column in engagement table
  colnames(dirt_engagement_data)[colnames(dirt_engagement_data) == 'B_mode'] <- 'mode'
  
  
  return(dirt_engagement_data)
}


#' Output cleaned student engagement data as csv
#' @description Writes cleaned data as a csv into the course correct directory
#' @param input_course Name of course directory (ex. psyc1, spd1, marketing, etc)
#' @param cleaned_data Dataframe containing cleaned data. 
#' @examples 
#' write_tidy_engagement_data(input_course = 'psyc1', cleaned_data= clean_engagement_data)
write_tidy_engagement_data <- function(input_course, cleaned_data){
  
  # Make IO path
  output_csv_path <- paste0("../data/", input_course, "/tower_engage.csv")
  
  # Save data frame to csv
  write_csv(x=cleaned_data, path=output_csv_path)
}



#' Output cleaned engagement data into corresponding course directory
#' @description This function will automatically read a file named "tower_engage_dirt.csv"
#' from the specified course directory and output a csv named "tower_engage.csv" in the same directory
#' @param input_course String of course directory name 
#' @export
#' @examples
#' wrangle_video(input_course = "psyc1")
wrangle_overview_engagement <- function(input_course){
  
  # Read in data
  dirt_engage <- read_dirt_engagement_data(input_course)

  # Clean data
  tidy_engage <- clean_engagement_data(dirt_engage)

  # Export data
  write_tidy_engagement_data(input_course = input_course, cleaned_data= tidy_engage)


}


