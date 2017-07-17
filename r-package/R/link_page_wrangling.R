
#################################
# Link data wrangling functions #
#################################


#' Import course_axis.csv files based on specified course folder name
#' @param input_course 
#' @return course_axis
#' @examples
#' read_course_axis(input_couse = "psyc1")
#' @export
read_course_axis <- function(input_course){
  input_csv_path <- paste0("../data/", input_course, "/course_axis.csv")
  course_axis <- read_csv(input_csv_path)
  return(course_axis)
}



#' Import external_link_dirt.csv files based on specified course folder name
#' @param input_course 
#' @return link_dirt
#' @examples
#' read_link_dirt(input_couse = "psyc1")
#' @export
read_link_dirt <- function(input_course){
  input_csv_path <- paste0("../data/", input_course, "/external_link_dirt.csv")
  link_dirt <- read_csv(input_csv_path)
  return(link_dirt)
}

#' Set three levels for students total spending time on course based on tracklog link data
#' @param link_data dataframe containing the information of student click any links in the edx course
#' @return link_data
#' @examples set_activity_level(link_data = read_link_dirt)
#' @export
set_activity_level <- function(link_data){
  
  # Rename columns 
  colnames(link_data)[3] <- "path"
  colnames(link_data)[5] <- "mode"
  
  # Classify activity level into three groups
  link_data <- link_data %>% 
    mutate(activity_level = case_when(
                        (.$activity_level < 1800) ~ "under_30_min",
                        (.$activity_level >= 1800) & (.$activity_level < 18000) ~ "30_min_to_5_hr",
                        (.$activity_level >= 18000) ~ "over_5_hr"))
  return(link_data)
}



#' Get which module each external link locate based on link tracklog data and course axis data
#' @param link_data dataframe containing the information of student click any links in the edx course
#' @param course_axis dataframe containing all elements in the edx course
#' @return link_data
#' @examples get_module_of_link(link_data = set_activity_level, course_axis = read_course_axis)
#' @export
get_module_of_link <- function(link_data,course_axis){
  
  # Get the module name where each link locates
  module_hash_string <- rep(0,length(link_data))
  
  for (i in (seq(length(link_data$path)))){
      module_hash <- strsplit(link_data$path[i],"/")[[1]][7]
      module_hash_string [i] <- paste0("/",module_hash)
      }
  
  module_hash_string <- data.frame(module_hash_string)
  colnames(module_hash_string)[1] <- "path"
  
  # Join it with course axis table
  module_location <- left_join(module_hash_string,course_axis,by = "path") %>% select(name)
  
  # Add module name column to link dataframe
  link_data["chapter_location"] <- module_location
  return(link_data)
  
}


#' Export the tidy link dataframe
#' @param input_course 
#' @param cleaned_data tidy link dataframe 
#' @examples write_link_clean(input_course = "psyc1",cleaned_data = get_module_of_link)
#' @export
write_link_clean <- function(input_course,cleaned_data){
  output_csv_path <- paste0("../data/", input_course, "/external_link.csv")
  write_csv(x=cleaned_data, path= output_csv_path)
}


#################################
# Page data wrangling functions #
#################################

#' Import page_dirt.csv files from specified course folder name
#' @param input_course 
#' @return page_dirt
#' @examples
#' read_page_dirt(input_couse = "psyc1")
#' @export
read_page_dirt <- function(input_course){
  input_csv_path <- paste0("../data/", input_course, "/page_dirt.csv")
  page_dirt <- read_csv(input_csv_path)
  return(page_dirt)
}



#' Prepare tidy page tracklog data for making page summary table 
#' @param page_data 
#' @return log_data
#' @examples
#' prepare_tidy_page(page_data = read_page_dirt)
#' @export
prepare_tidy_page <- function(page_data){
  
  # Rename page_data column 
  colnames(page_data)[colnames(page_data) == 'A_time'] <- 'time'
  colnames(page_data)[colnames(page_data) == 'B_mode'] <- 'mode'

  # Manipulate duplicated messy URLs 
  # Why do this: Some page URL still have characters after the 8th "/" in page URL, which is messy and might cause problem in the mapping name phase
  # Solution: If a page URL have characters after the 8th "/", we remove these characters 
  page_data$page <- sub(sprintf("^((?:[^/]*/){%s}).*", 8), "\\1", page_data$page)

  # Remove the last '/ 'in page URL where there is an'/ 'at the end, in order to match page name in the future
  page_data$page <- substr(page_data$page,1,max(unique(nchar(page_data$page)))-1)

  # Create column "path" for page data
  path_string <- rep(0,length(page_data$page))
  
  for (i in (seq(length(page_data$page)))){
    hash1 <- strsplit(page_data$page[i],"/")[[1]][7]
    hash2 <- strsplit(page_data$page[i],"/")[[1]][8]
    path_string[i] <- paste0("/",hash1,"/",hash2)
    }

  page_data["path"] <- path_string
  
  # Remove NA pages and classify activity level into 3 groups
  log_dat <- page_data %>% 
    filter(!is.na(user_id)) %>% 
    filter(path!="/NA/NA") %>% 
    mutate(date = as.Date(lubridate::ymd_hms(time))) %>%
    mutate(activity_level = case_when(
                        (.$activity_level < 1800) ~ "under_30_min",
                        (.$activity_level >= 1800) & (.$activity_level < 18000) ~ "30_min_to_5_hr",
                        (.$activity_level >= 18000) ~ "over_5_hr")) %>% 
    arrange(time) 

  # Filter out tracklog data where students has course navigation activity: each_session_time < 10s
  # each_session_time is defined as for per student per day per page, the time interval between each event's time stamp
  course_navigation_threshold <- 10 
  sig_student_time <- log_dat %>% 
     group_by(date, page, user_id) %>% 
     mutate(next_stamp = lead(time)) %>% 
     mutate(each_session_time = abs(as.double(difftime(time,next_stamp,units = "secs")))) %>%
     filter(each_session_time > course_navigation_threshold) 
  
  # Select necessary column for making the dashboard    
  log_dat <- sig_student_time %>% 
    select(-time, -next_stamp,-each_session_time)
  
  return(log_dat)
}


#' Get non-video and non-problem element name then create a chapter/module column for all these course elements
#' @param course_axis dataframe containing all course elements information
#' @return page_name
#' @examples prepare_page_name(course_axis =  read_course_axis)
#' @export
prepare_page_name <- function(course_axis){
  
  # Wrangle course axis table to remove video and problem elements 
  # Note : In order to only count all non-video and non-problem pages in the link & page dashboard, 
  # I conduct filter here for only getting the path of non-video and non-problem elements in order to mapping tracklog data
  page_name <- course_axis %>% 
    select(index,category,name,path) %>% 
    filter(grepl("Video",name)==FALSE) %>%
    filter(grepl("Quiz",name)==FALSE) %>%
    filter(grepl("Question",name)==FALSE) %>%
    mutate(path = substr(path,1,66))
  
  # Get a module name vector
  chap_name <- as.vector((page_name %>%arrange(index) %>% filter(category == "chapter") %>% select(name))$name)

  # Get module index 
  chap_index <- as.vector((page_name %>% arrange(index) %>%filter(category == "chapter") %>% select(index))$index)

  # create a chapter_location column for non-video and non-problem element
  page_name["chapter_location"] <- "no info"
  
  for (i in seq(length(chap_index))){
    page_name <- page_name %>% 
      arrange(index) %>% 
      mutate(chapter_location = replace(chapter_location, index >= chap_index[i] , chap_name[i]))
  }
  return(page_name)
 } 




#' Export the tidy page dataframe
#' @param input_course 
#' @param cleaned_data A tidy page dataframe. 
#' @examples write_page_clean(input_course = "psyc1",cleaned_data = prepare_tidy_page)
#' @export
write_page_clean <- function(input_course,cleaned_data){
  output_csv_path <- paste0("../data/", input_course, "/page.csv")
  write_csv(x=cleaned_data, path= output_csv_path)
  
}


#' Export the tidy course axis dataframe containing all non-video and non-problem elements with module/chapter information
#' @param input_course 
#' @param cleaned_data A tidy page_name dataframe 
#' @examples write_page_name(input_course = "psyc1",cleaned_data = prepare_page_name)
write_page_name <- function(input_course,cleaned_data){
  output_csv_path <- paste0("../data/", input_course, "/page_name.csv")
  write_csv(x=cleaned_data, path= output_csv_path)
}


######################
# wrangle_page_link  #
######################


#' Read in three csv files getting from rbq.py : course_axis.csv, external_link_dirt.csv and page_dirt.csv; perform wrangling; export three csv files for building link_page_dashabord: external_link.csv, page.csv and page_name.csv 
#' @param input_course 
#' @examples
#' wrangle_link_page(input_cours = "psyc1")
#' @export
wrangle_link_page <- function(input_course){
  
  # read in link data 
  course_axis <- read_course_axis(input_course)
  link_dat <- read_link_dirt(input_course)
  
  # clean link data
  link_dat <- set_activity_level(link_dat)
  link_dat <- get_module_of_link(link_dat,course_axis)
  
  # export tidy link data
  write_link_clean(input_course,link_dat)
  
  # read in page data
  page_dat <- read_page_dirt(input_course)
  
  # clean page data
  page_dat <- prepare_tidy_page(page_dat)
  page_name <- prepare_page_name(course_axis)
  
  # export tidy page data 
  write_page_clean(input_course,page_dat)
  write_page_name(input_course,page_name)
  
}