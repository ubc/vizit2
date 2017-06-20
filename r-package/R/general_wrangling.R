wrangle_general <- function(input_course){
  # Reading data:
  data <- obtain_raw_general_data(input_course)
  language_info <- obtain_language_info()
  country_info <- obtain_country_info()
  
  data <- prepare_general_data(data, language_info, country_info)
  
  write_general_data(input_course, data)
}

obtain_raw_general_data <- function(input_course){
  input_csv_path <- paste0("../data/", input_course, "/generalized_demographics.csv")
  data <- read_csv(input_csv_path)
  return(data)
}

obtain_language_info <- function(){
  input_csv_path <- "../data/helper_data/language_info.csv"
  language_info <- read_csv(input_csv_path)
  return(language_info)
}

obtain_country_info <- function(){
  input_tsv_path <- "../data/helper_data/countryInfo.tsv"
  country_info <- read_tsv(input_tsv_path)
  return(country_info)
}

prepare_general_data <- function(data, language_info, country_info){
  # Add proper activity level:
  data <- data %>% 
    mutate(activity_level = case_when((.$sum_dt < 1800) ~ "under_30_min",
                                      (.$sum_dt >= 1800) & (.$sum_dt < 18000) ~ "30_min_to_5_hr",
                                      (.$sum_dt >= 18000) ~ "over_5_hr",
                                      is.na(.$sum_dt) ~ "NA"))
  
  # Data frame with language code and language name
  language_info <- language_info %>% 
    mutate(primary_lang = alpha2) %>% 
    mutate(language = English) %>% 
    select(primary_lang, language)
  
  # Dataframe with country name and language code
  country_info <- country_info %>%
    select(ISO, Country, Languages) %>%
    separate(Languages, into=c("primary_lang", "secondary_lang", "thirdary_lang"), sep=',') %>%
    mutate(primary_lang = sub("-.*","",primary_lang),
           secondary_lang= sub("-.*","",secondary_lang),
           thirdary_lang= sub("-.*","",thirdary_lang)) 
  
  data <- data %>%
    mutate(ISO = cc_by_ip) %>%
    left_join(country_info, by='ISO') %>%
    select(-language) %>% 
    left_join(language_info, by='primary_lang') 
  
  return(data)
}

write_general_data <- function(input_course, data){
  output_csv_path <- paste0("../data/", input_course, "/wrangled_demographics.csv")
  write_csv(data, output_csv_path) 
}

