convert_loe <- function(LoE){
  case_when(LoE == "hs" ~ "High School",
            LoE == "b" ~ "Bachelor's Degree",
            LoE == "m" ~ "Master's Degree",
            LoE == "jhs" ~ "Middle School",
            LoE == "a" ~ "Associate Degree",
            LoE == "other" ~ "Other",
            LoE == "p" ~ "Doctorate",
            LoE == "el" ~ "Elementary School",
            LoE == "none" ~ "No Formal Education",
            LoE == "p_se" ~ "Doctorate",
            LoE == "p_oth" ~ "Doctorate",
            TRUE ~ NA_character_)
}

get_loe_df <- function(data){
  # define level of education by rank:
  loe_lvls <- data.frame(LoE=c("High School", 
                               "Bachelor's Degree", 
                               "Master's Degree", 
                               "Middle School", 
                               "Associate Degree", 
                               "Other", 
                               "Doctorate",
                               "Elementary School", 
                               "No Formal Education"),
                         rank=c(5,3,2,6,4,9,1,7,8))
  
  # make dataframe:
  loe_df <- data %>% 
    filter(is.na(LoE)==FALSE) %>% 
    group_by(LoE) %>% 
    summarize(count = n()) %>% 
    mutate(LoE = convert_loe(LoE)) %>% 
    left_join(loe_lvls, by='LoE') %>% 
    mutate(LoE = forcats::fct_reorder(LoE, desc(rank)))
  
  return(loe_df)
}

get_loe_plot <- function(loe_df){
  g <- ggplot(loe_df, aes(LoE, count)) + 
    geom_bar(stat='identity', fill='#e78ac3') + 
    xlab("Level of Education") + 
    ylab("Number of People") + 
    coord_flip() + 
    ggthemes::theme_few(base_family = "GillSans")
  
  return(g)
}

get_age_df <- function(data){
  age_df <- data %>% 
    mutate(age = as.integer(format(Sys.Date(), "%Y")) - YoB) %>% 
    dplyr::filter(age >=5, age <= 100)
  
  return(age_df)
}

get_age_plot <- function(age_df){
  g <- ggplot(age_df, aes(age)) + 
    geom_histogram(fill='#e78ac3', bins=10) + 
    ylab("Number of Students") + 
    xlab("Age") +
    ggthemes::theme_few(base_family="GillSans")
  
  return(g)
}

get_top_country_df <- function(data, top_selection){
  country_df <- data %>% 
    group_by(country = countryLabel) %>% 
    summarize(num_of_people = n()) %>% 
    mutate(country = forcats::fct_reorder(country, num_of_people)) %>% 
    arrange(desc(num_of_people))
  
  top_country_df <- head(country_df, top_selection)
  
  return(top_country_df)
}

get_country_plot <- function(country_df, top_selection){
  g <- ggplot(country_df, aes(country, num_of_people)) + 
    geom_bar(stat = "identity", fill='#e78ac3') + 
    xlab("Country") + 
    ylab("Number of People") + 
    coord_flip() + 
    ggtitle(paste0("(Top ", as.character(top_selection), " Countries)")) +
    ggthemes::theme_few(base_family="GillSans")
  
  return(g)
}

get_top_language_df <- function(data, top_selection){
  language_df <- data %>% 
    group_by(language) %>% 
    summarize(num_of_people = n()) %>% 
    mutate(language = forcats::fct_reorder(language, num_of_people)) %>% 
    filter(is.na(language) == FALSE)
  
  top_language_df <- head(language_df, top_selection)
  
  return(top_language_df)
}

get_language_plot <- function(language_df, top_selection){
  g <- ggplot(language_df, aes(language, num_of_people)) +
    geom_bar(stat='identity', fill='#e78ac3') + 
    xlab("Language") + 
    ylab("Number of People") + 
    coord_flip() + 
    ggtitle(paste0("(Top ", as.character(top_selection), " Languages)")) + 
    ggthemes::theme_few(base_family="GillSans")
  
  return(g)
}
  