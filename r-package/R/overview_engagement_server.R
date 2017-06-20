#' Filter student engagement dataframe by the selected demographics 
#' 
#' @param engage_df The student engagement dataframe.
#' @param activity_level It refers to the total time each student spent on the course.There are 4 levels: "under_30_min", "30_min_to_5_hr", "over_5_hr", or (default) "all". 
#' @param gender One of "male", "female", "other", or (default) "all".
#' @param registration_status One of "audit", "verified", or (default) "all".
#' @param module One of the modules of the course
#' @return A dataframe filtered by the selected demographics.
#' @examples
#' filter_demographics(engage_df = tower_engage, gender = "all", mode = "all", activity_level = "all")


filter_demographics <- function(engage_df, gender = "All", mode = "All",activity_level = "All") {
        filtered_df <- engage_df
        if (gender == "female") {
                filtered_df <- filtered_df %>% filter(gender == "f")
        }
        if (gender == "male") {
                filtered_df <- filtered_df %>% filter(gender == "m")
        }
        if (gender == "other") {
                filtered_df <- filtered_df %>% filter(gender == "o")
        }

        if (mode == "audit") {
                filtered_df <- filtered_df %>% filter(mode == "audit")
        }
        if (mode == "verified") {
                filtered_df <- filtered_df %>% filter(mode == "verified")
        }        
        if (activity_level == "under_30_min") {
                filtered_df <- filtered_df %>% filter(activity_level == "under_30_min")
        }
        if (activity_level == "30_min_to_5_hr"){
                filtered_df <- filtered_df %>% filter(activity_level != "30_min_to_5_hr")
        }
        if (activity_level == "over_5_hr"){
                filtered_df <- filtered_df %>% filter(activity_level != "over_5_hr")
        }     
        return(filtered_df)
}



#' Filter course items dataframe by the selected course module 
#' 
#' @param item_df The course items dataframe.
#' @param module One of the modules of the course
#' @return A dataframe filtered by the selected course module
#' @examples
#' filter_chapter_oveview(tower_item, "all")

filter_chapter_overview <- function(input_df, module ="All") {
                     
                  if (module == "All") {
                    return(input_df)
                  }else{
                    filtered_df <- input_df %>% dplyr::filter(chapter_name == module)
                    return(filtered_df)
                  }
}
     
                     


#' Create a module name vector sorted by the course structure index
#' This vector is used in the module filtering select box in ui.R 
#' @param item_df 
#' @return chap_name
#' @examples 
#' get_module_vector(item_df = tower_item)
get_module_vector <- function(item_df) {
  
  chap_name <- as.vector((item_df %>%
      arrange(index) %>% 
      filter(category == "chapter") %>% select(name))$name)

return(chap_name)

}

#' Create a new column "chapter_name" for course item dataframe in order to implementing module filtering
#' @param item_df 
#' @return item_df
#' @examples 
#' create_module_name(item_df = tower_item)
create_module_name <- function(item_df){
  
  
  # Get a module name vector
  chap_name <- as.vector((item_df %>%
      arrange(index) %>% 
      filter(category == "chapter") %>% select(name))$name)
  

  # Get a module index vecotr
  chap_index <- as.vector((item_df %>%
   dplyr::arrange(index) %>%   
   dplyr::filter(category == "chapter") %>% select(index))$index)

  # Create a chapter_name column for filtering course module setup
  item_df["chapter_name"] <- "no info"
  
  for (i in seq(length(chap_index))){
    item_df <- item_df %>% 
      arrange(index) %>% 
      mutate(chapter_name = replace(chapter_name, index >= chap_index[i] , chap_name[i]))
  }
  
  return(item_df)
}


#' Compute how many students engaged with each course item after filtering student demographic
#' @param detail_df 
#' @return summary_df
#' @export 
#' @examples get_nactive(detail_df = tower_engage)
get_nactive <- function(detail_df){
  
   summary_df <- detail_df %>% 
     group_by(module_id,A_user_id) %>% 
     summarise(per_user = n()) %>% 
     group_by(module_id) %>% 
     summarize(nactive = sum(per_user))
   
   return(summary_df)
  
}


#' Join filtered summary engagement dataframe with filtered item dataframe to match "item " ,"item name"  and "nactive" 
#' convert all module item nacitve number to a constant to draw seperator line later
#' @param filtered_engagement 
#' @param filtered_item 
#' @return tower_df
#' @export
#'
#' @examples join_engagement_item(filtered_engagement = filtered_tower_engage,filtered_item = filtered_tower_item)

join_engagement_item <- function(filtered_engagement,filtered_item){
  
   # Join two tables to get the item name 
  tower_df <- left_join(filtered_item,filtered_engagement,by = "module_id") %>% 
  mutate(nactive=replace(nactive, is.na(nactive)==TRUE,0)) %>% 
  dplyr::filter(category == "chapter" |category == "video"| category == "problem") %>% 
  arrange(index)
   

  # Change "chapter" to " module split line" for making plot later more clearly
  tower_df <- tower_df %>% 
    mutate(category=replace(category, category=="chapter", "module seperator"))
    

  # If the table is not empty after filtering
  if (all(is.na(tower_df$name)) == FALSE){
  
  
  # Create new index columns based on the filtered table
  tower_df["plot_index_asc"] <- seq(nrow(tower_df))
  tower_df["plot_index_desc"] <- (max(tower_df$plot_index_asc)+1) - tower_df$plot_index_asc
  
  # Compute the nactive maximum as the length of module seperator 
  max_nacitve <- as.numeric(tower_df %>% 
    filter(category != "module seperator") %>% 
    mutate(max_nacitve = max(nactive)) %>% 
    select(max_nacitve) %>% 
    head(1))

  # Set all chapter nactive value to the nactive maximum to draw equal long module split line later 
  tower_df <- tower_df %>% 
    mutate(nactive=replace(nactive, category=="module seperator", max_nacitve)) 

  # Add hovering text: for chapter item, only show item name ; for other items, show detail information 
  tower_df$my_text <- ifelse(tower_df$category == "module seperator",
                      tower_df$name,
                      paste(tower_df$name,"Number of student engaged with:",tower_df$nactive , sep="<br>"))
  }else{
    
  # If the filtered table is empty, set each column to zero 
      
    tower_df <- tower_df %>% 
    mutate(nactive = "Sorry,no data matched this filtering condition",
             plot_index_desc = 0,
              my_text = 0,
              category = 0)
        
  }
  # output the tower table  
  return(tower_df)
  
  
  
}




#' Count how many filtered students engaged with the filtered course module
#' @param tower_df 
#' @return student_num
#' @examples get_module_nactive(reactive_tower_df())
get_module_nactive <- function(tower_df){

if (is.na(max(tower_df$nactive)) == TRUE){
    
    student_num <- paste0(0, " student")
    
}else{
    student_num <- paste0(max(tower_df$nactive) ," students") 
  }

return(student_num)

}

  
#' Make effiel tower plot :  all video/problem course items vs. number of engaging student 
#' @param tower_data 
#' @export
#' @examples make_engagement_eiffel_tower(tower_data = reactive_tower_df())
make_engagement_eiffel_tower <- function(tower_data){
  
# set up axis and size parameter
a <- list(autotick = TRUE, ticks = "outside", title = "Number of student",side = "top" )
m <- list(l=50, r=50, b=0, t=50)
    
  if(all(is.na(tower_data$nactive)==TRUE)){
    
    plotly::plot_ly(tower_data, x = ~ nactive,y = ~plot_index_desc,type = 'bar',orientation = 'h') %>% 
              plotly::config(displayModeBar = F) 
  
  }else{
    plotly::plot_ly(tower_data, x = ~nactive,y = ~plot_index_desc,type = 'bar',orientation = 'h',
               text = ~my_text, hoverinfo="text",color = ~category,
               colors = c("black","#66c2a5","#8da0cb")) %>%  
               plotly::layout(margin=m,xaxis = a,
                      yaxis = list(title = "Course element by module",showticklabels = FALSE),
                      showlegend = TRUE, legend = list(x = 0.9, y = 0.9)) %>% 
               plotly::config(displayModeBar = F)
    
    
  }
  
}  
    



