#' Filter course item dataframe by the selected course module. 
#' @param input_df The link dataframe or page dataframe.
#' @param module One of the modules in the course
#' @return A dataframe filtered by the selected course module.
#' @examples
#' filter_chapter(tower_item, "all")
filter_chapter_linkpage <- function(input_df, module = "All") {
  
  if(is.null(module)){
    module = "All"
  }
  
  if (module == "All") {
    return(input_df)
  }
  else {
    filtered_df <- input_df %>%
      filter(chapter_location == module) 
    return(filtered_df)
  }  
}     
                     


#'  Create a module name vector sorted by the course structure index. This 
#'   vector is used in the module filtering select box in ui.R 
#' @param item_df 
#' @return chap_name
get_module_vector <- function(item_df) {
  
  chap_name <- as.vector(
    (item_df %>%
       arrange(index) %>% 
       filter(category == "chapter") %>% 
       select(name)
    )$name
  )
  
  return(chap_name)
  
}


#' Count the pageview of each page.Here, we set a threshold for only counting 
#'   pages have been viewed by more than certain amount of students. 
#' @param filtered_log_df A page related tracklog dataframe after filtering.
#' @return page_student A page summary dataframe containing the pageview of each 
#'   pages.
#' @export
#' @examples 
#' get_pageview(filtered_log_df = log_dat)
get_pageview <- function(filtered_log_df){
  
  student_num_threshold <- 10
  
  page_student <- filtered_log_df %>% 
     group_by(date, page, path, user_id) %>% 
     summarise(student = n()) %>% 
     group_by(page,path) %>% 
     summarise(num_student = n()) %>% 
     filter(num_student > student_num_threshold) %>% 
     arrange(desc(num_student))
  
  return(page_student)
}


#' Get the name description of each page.
#' @param page_name_df A dataframe we get after joining page dataframe and page 
#'   name dataframe.
#' @return each_page
#' @export
#' @examples 
#' get_page_name(page_name_df = page_name_mapping)
get_page_name <- function(page_name_df){
  
  student_num_threshold <- 10
  
  each_page <- page_name_df %>% 
    select(name,num_student,page,chapter_location,category,index) %>%  
    filter(name!="NA") %>% 
    group_by(page,num_student) %>% 
    slice(1) %>% 
    ungroup() %>%
    filter(num_student > student_num_threshold ) %>% 
    arrange(index)
  
  return(each_page)
  
}


#' Remove duplicated name for each page.
#' @param each_page_df 
#' @return all_pages
#' @examples get_unique_page_name(each_page_df = each_page)
get_unique_page_name <- function(each_page_df){
  
  # Get unique page name rows
  each_page_df <- each_page_df[!duplicated(each_page_df[1]),]
  
  if(nrow(each_page_df)!=0){
    
    # Create a hyperlink column
    each_page_df["url_link"] <- paste0(
      "<a href='",
      each_page_df$page,
      "'>",
      each_page_df$name,
      "</a>"
    ) 
    
    # Select five columns to for the table later
    all_pages <- each_page_df %>% 
      select(name,url_link,index,category,num_student,chapter_location)
    
    # Make the page index consitent
    all_pages$index <- seq(nrow(all_pages))
    all_pages$index <- (max(all_pages$index)+1) - all_pages$index
    
    colnames(all_pages) <- c('Page_Description',
                             'Page_url',
                             'Page_Index',
                             'Page_Category',
                             'Pageview',
                             'Module')
    
    
  }else{
    all_pages <- data.frame(warning = "No pages found")   
  } 
  return(all_pages)   
  
}



#' Create a page summary table to show page (name, clickable hyperlink) and its 
#'    page view sorted by pageview in descending order
#' @param page_summary 
#' @return page_df
#' @export
#' @examples 
#' creat_page_table(page_summary = reactive_page())
creat_page_table <- function(page_summary){
  
  if ((nrow(page_summary)!= 1) & (nrow(page_summary)!= 0)) {
    
    page_df <- page_summary %>% 
      select(Page_url,Pageview) %>% 
      arrange(desc(Pageview))
    
    colnames(page_df) <- c("Page URL","Pageviews")
    
  } else {
    
    page_df <- page_summary
  
  }
  
  return(page_df)
  
}


#' Compute how many times each external link have been clicked.
#' @param link_df A link dataframe. 
#' @return link_num A link dataframe with number of click information.
#' @export
#' @examples get_click_per_link(link_df = link_dat)
get_click_per_link <- function(link_df){
  
  min_click_threshold <- 5 
  
  # If link data is not NONE after two two type of filtering 
  if (nrow(link_df)!=0) {
    
    
    # Compute the number of click on each page
    link_num <- link_df %>%
      filter(!is.na(link)) %>%
      group_by(link) %>% 
      summarise(number_of_click = n()) %>% 
      filter(number_of_click >= min_click_threshold) 
    
    
    # Clean link to the tidy form
    link_num$link <- substr(link_num$link,17,nchar(link_num$link)-4)
    
    link_num <- link_num %>% 
      filter(link != "http://open.edx.org/") 
    
  } else {
    
    link_num <- data.frame("Warning" = "No link found")
    
  }
  
  # Output link table
  return(link_num)
  
}



#' Create a page summary table to show page(name,clickable hyperlink) and its 
#'   page view sorted by pageview in descending order
#' @param page_summary 
#' @return page_df
#' @export
#' @examples 
#' creat_page_table(page_summary = reactive_page())
creat_link_table <- function(link_summary){
  
  # If link summary table is not 1-row warning and empty table   
  if ((nrow(link_summary)!= 1) & (nrow(link_summary)!= 0)){
    
    link_df <- link_summary %>% 
      arrange(desc(number_of_click)) 
    
    link_df$link <-  paste0(
      "<a href='",
      link_df$link,
      "'>",
      substr(link_df$link,1,60),
      "</a>"
    )
    
    colnames(link_df) <- c('Link','Number of Clicks') 
    
  } else {
    # If link summary table is 1-row warning or empty table
    link_df <- data.frame( Warning = "No link found")
  }
  
  return(link_df)
  
}
