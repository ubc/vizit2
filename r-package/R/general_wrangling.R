#' Wrangles raw general demographics data
#'
#' @description Reads the input course's raw 'generalized_demographics.csv' and 
#'   outputs a cleaned version as wrangled_demographics.csv within the same 
#'   directory
#' 
#' @param input_course String value of input course short name
#'
#' @return No value is returned
#'
#' @examples
#' wrangle_general('psyc1')
wrangle_general <- function(input_course) {
  # Reading data:
  data <- obtain_raw_general_data(input_course)
  language_info <- obtain_language_info()
  country_info <- obtain_country_info()
  
  data <- prepare_general_data(data, language_info, country_info)
  
  write_general_data(input_course, data)
}

#' Obtains raw general demographic data
#'
#' @param input_course String value of input course short name
#'
#' @return Returns a data frame with the raw general demographic data
#'
#' @examples
#' obtain_raw_general_data('psyc1')
obtain_raw_general_data <- function(input_course) {
  input_csv_path <- paste0("../inst/data/", 
                           input_course, 
                           "/generalized_demographics.csv")
  data <- read_csv(input_csv_path)
  return(data)
}

#' Obtains a data frame with language information
#'
#' @description Reads in a .csv containing languages and their ISO code. 
#' @return Returns a data frame with languages and their corresponding ISO codes
#'
#' @examples obtain_language_info()
obtain_language_info <- function() {
  input_csv_path <- "../inst/helper_data/language_info.csv"
  language_info <- read_csv(input_csv_path)
  return(language_info)
}

#' Obtains a data frame with countries and ISO codes of their associated 
#'   languages
#'
#' @return Data frame with countries and their associated ISO language codes
#'
#' @examples obtain_country_info()
obtain_country_info <- function() {
 input_csv_path <- "../inst/helper_data/countryInfo.csv"
 country_info <- read_csv(input_csv_path)
 return(country_info)
}

#' Cleans raw demographic data
#'
#' @param data Data frame containing student demographic information
#' @param language_info Data frame containing languages and their associated ISO 
#'   codes
#' @param country_info Data frame with countries and their associated languages 
#'   as ISO codes
#'
#' @return Cleaned data frame containing demographic information
#'
#' @examples prepare_general_data(
#'   obtain_raw_general_data('psyc1'), 
#'   language_info(), 
#'   country_info()
#' )
prepare_general_data <- function(data, language_info, country_info)
{
  # Add proper activity level:
  data <- data %>% 
    mutate(activity_level = case_when(
      (.$sum_dt < 1800) ~ "under_30_min", 
      (.$sum_dt >= 1800) & (.$sum_dt < 18000) ~ "30_min_to_5_hr", 
      (.$sum_dt >= 18000) ~ "over_5_hr", is.na(.$sum_dt) ~ "NA")
    )
  
  # Data frame with language code and language name
  language_info <- language_info %>% 
    mutate(primary_lang = alpha2) %>% 
    mutate(language = English) %>% 
    select(primary_lang, language)
  
  # Dataframe with country name and language code
  country_info <- country_info %>% 
    select(ISO, Country, Languages) %>% 
    tidyr::separate(
      Languages, 
      into = c("primary_lang", "secondary_lang", "thirdary_lang"), 
      sep = ","
    ) %>% 
    mutate(primary_lang = sub("-.*", "", primary_lang), 
           secondary_lang = sub("-.*", "", secondary_lang), 
           thirdary_lang = sub("-.*", "", thirdary_lang))
  
  data <- data %>% 
    mutate(ISO = cc_by_ip) %>% 
    left_join(country_info, by = "ISO") %>% 
    select(-language) %>% 
    left_join(language_info, by = "primary_lang")
  
  return(data)
}

#' Writes cleaned demographic data frame as a .csv to the specified course
#'
#' @param input_course String value of course short name
#' @param data The data frame containing cleaned demographic data
#'
#' @return No value is returned
#'
#' @examples write_general_data('psyc1', cleaned_demographic_data)
write_general_data <- function(input_course, data)
{
  output_csv_path <- paste0("../inst/data/", 
                            input_course, 
                            "/wrangled_demographics.csv")
  write_csv(data, output_csv_path)
}
