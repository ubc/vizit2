#' Filter course items dataframe by the selected course module 
#' @param item_df The course items dataframe.
#' @param module One of the modules of the course.
#' @return A dataframe filtered by the selected course module.
#' @examples
#' filter_chapter_overview(tower_item, "all")
#' @export
filter_chapter_overview <- function(input_df, module ="All") {
  
  if(is.null(module)) {
    module = "All"
  }
  
  if (module == "All") {
    return(input_df)
  } else {
    filtered_df <- input_df %>% 
      dplyr::filter(chapter_name == module)
    return(filtered_df)
  }
}


#' Create a module name vector sorted by the course structure index. This vector
#'   is used in the module filtering select box in ui.R 
#' @param item_df The course axis dataframe
#' @return chap_name A vector containg all unique module names.
#' @examples 
#' get_module_vector(item_df = tower_item)
#' @export
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


#' Create a new column "chapter_name" for course item dataframe in order to 
#'  implement module filtering
#' @param item_df A course axis dataframe only containing item name
#' @return item_df A coure axis dataframe adding chapter_name column
#' @examples 
#' create_module_name(item_df = tower_item)
create_module_name <- function(item_df){
  
  # Get a module name vector
  chap_name <- as.vector(
    (item_df %>%
       arrange(index) %>% 
       filter(category == "chapter") %>% 
       select(name)
    )$name
  )
  
  
  # Get a module index vecotr
  chap_index <- as.vector(
    (item_df %>%
       dplyr::arrange(index) %>%
       dplyr::filter(category == "chapter") %>% 
       select(index)
    )$index
  )
  
  # Create a chapter_name column for filtering course module setup
  item_df["chapter_name"] <- "no info"
  
  for (i in seq(length(chap_index))) {
    item_df <- item_df %>% 
      arrange(index) %>% 
      mutate(chapter_name = replace(chapter_name, 
                                    index >= chap_index[i], 
                                    chap_name[i]))
  }
  
  return(item_df)
}


#' Compute how many students engaged with each course item after filtering 
#'   student demographic
#' @param detail_df Filtered student engagement dataframe
#' @return summary_df Summarized-view of engagement dataframe. 
#' @examples
#' get_nactive(detail_df = tower_engage)
#' @export
get_nactive <- function(detail_df){
  
   summary_df <- detail_df %>% 
     group_by(module_id, A_user_id) %>% 
     summarise(per_user = n()) %>% 
     group_by(module_id) %>% 
     summarize(nactive = sum(per_user))
   
   return(summary_df)
  
}


#' Join filtered summary engagement dataframe with filtered item dataframe to 
#'   match "item " ,"item name"  and "nactive" convert all module item nacitve 
#'   number to a constant to draw separator line later
#' @param filtered_engagement Filtered engagement dataframe. 
#' @param filtered_item Filtered course axis dataframe
#' @return tower_df Dataframe containing item name, item category and how many 
#'   student engaged with it
#' @examples
#' join_engagement_item(
#'   filtered_engagement = filtered_tower_engage,
#'   filtered_item = filtered_tower_item
#' )
#' @export
join_engagement_item <- function(filtered_engagement, filtered_item) {
  
  # Join two tables to get the item name
  tower_df <- left_join(filtered_item, 
                        filtered_engagement, 
                        by = "module_id") %>% 
    mutate(nactive=replace(nactive, is.na(nactive) == TRUE, 0)) %>% 
    dplyr::filter(category == "chapter" 
                  | category == "video" 
                  | category == "problem") %>% 
    arrange(index)
  
  # Change "chapter" to " module split line" for making plot later more clearly
  tower_df <- tower_df %>% 
    mutate(category = replace(category, 
                              category == "chapter", 
                              "module separator"))
  
  
  # If the table is not empty after filtering
  if (all(is.na(tower_df$name)) == FALSE) {
    
    # Create new index columns based on the filtered table
    tower_df["plot_index_asc"] <- seq(nrow(tower_df))
    tower_df["plot_index_desc"] <- (
      max(tower_df$plot_index_asc)+1
    ) - tower_df$plot_index_asc
    
    # Compute the nactive maximum as the length of module separator 
    max_nacitve <- as.numeric(tower_df %>% 
                                filter(category != "module separator") %>% 
                                mutate(max_nacitve = max(nactive)) %>% 
                                select(max_nacitve) %>% 
                                head(1))
    
    # Set all chapter nactive value to the nactive maximum to draw equal long 
    # module split line later 
    tower_df <- tower_df %>% 
      mutate(nactive=replace(nactive, 
                             category == "module separator", 
                             max_nacitve)) 
    
    # Add hovering text: for chapter item, only show item name; for other 
    # items, show detail information 
    tower_df$my_text <- ifelse(tower_df$category == "module separator",
                               tower_df$name,
                               paste0(
                                 tower_df$name, 
                                 "<br>", 
                                 tower_df$nactive, 
                                 " students engaged with this element."
                               )
    )
    
  } else {
    
    # If the filtered table is empty, set each column to zero 
    tower_df <- tower_df %>% 
      mutate(nactive = "Sorry, no data matched this filtering condition",
             plot_index_desc = 0,
             my_text = 0,
             category = 0)
    
  }
  # output the tower table  
  return(tower_df)
  
}


#' Count how many filtered students engaged with the filtered course module
#' @param tower_df Student engagement dataframe.
#' @return student_num A number refers to the maximum number of student engaged 
#'   with one item witin the selected course module.
#' @examples get_module_nactive(reactive_tower_df())
get_module_nactive <- function(tower_df){
  
  if (is.na(max(tower_df$nactive)) == TRUE) {
    student_num <- paste0(0, " student")
  } else {
    student_num <- paste0(max(tower_df$nactive) ," students") 
  }
  return(student_num)
}

  
#' Make eiffel tower plot: all video/problem course items vs. number of engaged 
#'   students
#' @examples
#' make_engagement_eiffel_tower(tower_data = reactive_tower_df())
#' @export
make_engagement_eiffel_tower <- function(tower_data) {
  # Set up axis and size parameter
  a <- list(autotick = TRUE, 
            ticks = "outside", 
            title = "Number of unique learners who engaged with this element", 
            side = "top")
  m <- list(l=50, r=50, b=0, t=50)
  if (all(is.na(tower_data$nactive)==TRUE)) {
    plotly::plot_ly(
      tower_data, 
      x = ~ nactive,
      y = ~plot_index_desc, 
      type = 'bar', 
      orientation = 'h'
    ) %>% 
      plotly::config(displayModeBar = FALSE) 
  } else {
    plotly::plot_ly(tower_data, 
                    x = ~nactive,
                    y = ~plot_index_desc, 
                    type = 'bar', 
                    orientation = 'h',
                    text = ~my_text, 
                    hoverinfo = "text",
                    color = ~category,
                    colors = c("black","#66c2a5","#8da0cb")) %>%
      plotly::layout(margin=m,
                     xaxis = a,
                     yaxis = list(
                       title = "Course elements (problems and videos)",
                       showticklabels = FALSE
                     ),
                     showlegend = TRUE, 
                     legend = list(x = 0.9, y = 0.9)) %>% 
      plotly::config(displayModeBar = FALSE)
  }
}
