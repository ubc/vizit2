#' Returns the correct shiny module to use based on `requested_dashboard`
#'
#' @param requested_dashboard String value of which dashboard to display
#'
#' @return Returns a shiny module to be used as a server
#'
#' @examples
#' run_dashboard_server("video")
run_dashboard_server <- function(requested_dashboard){
  print(requested_dashboard)
  if (requested_dashboard == "demographics"){
    callModule(demographicsModule, "demographicsID")
  }
  else if (requested_dashboard == "video"){
    callModule(videoModule, "videoID")
  }
  else if (requested_dashboard == "overview"){
    callModule(overviewModule, "overviewID")
  }
  else if (requested_dashboard == "linkpage"){
    callModule(linkpageModule, "linkpageID")
  }
  else if (requested_dashboard == "forum"){
    callModule(forumModule, "forumID")
  }
  else if (requested_dashboard == "problem"){
    callModule( problemModule, "problemID")
  }
  else {
    print("Requested dashboard not found.")
    callModule(generalModule, "demographicsID")
  }
}

#' Returns shiny module UI based on `requested_dashboard`
#'
#' @param requested_dashboard String value of which dashboard to display
#'
#' @return Returns a shiny module UI
#'
#' @examples
#' run_dashboard_ui("forum")
run_dashboard_ui <- function(requested_dashboard){
  if (requested_dashboard == "general"){
    shinyUI(fluidPage(demographicsModuleUI("demographicsID")))
  }
  else if(requested_dashboard == "video") {
    shinyUI(fluidPage(videoModuleUI("videoID")))
  }
  else if(requested_dashboard == "overview") {
    shinyUI(fluidPage(overviewModuleUI("overviewID")))
  }
  else if(requested_dashboard == "linkpage") {
    shinyUI(fluidPage(linkpageModuleUI("linkpageID")))
  }
  else if(requested_dashboard == "forum") {
    shinyUI(fluidPage(forumModuleUI("forumID")))
  } 
  else if(requested_dashboard == "problem") {
    shinyUI(fluidPage(problemModuleUI("problemID")))
  } 
  else {
    shinyUI(fluidPage(generalModuleUI("demographicsID")))
  }
}

#' Returns plain text of md5 hashed requested dashboard
#'
#' @param hashed_dashboard String of md5 hash of the requested dashboard
#'
#' @return Plain text of requested dashboard
#' @export
#'
#' @examples
#' get_unhashed_dashboard("aa5b8e1625b36fca0bdc6a70bcb8033b")
get_unhashed_dashboard <- function(hashed_dashboard){
  selected_dashboard <- dashboard_checksum_df %>% 
    filter(checksum == hashed_dashboard)
  return(selected_dashboard$dashboard)
}

#' Returns plain text of md5 hashed course
#'
#' @param hashed_course String of md5 hash of the requested course short name
#'
#' @return Plain text of requested course
#' @export
#'
#' @examples
#' get_unhashed_dashboard("6c2915bad76b3214647edde0c0d0bdbe")
get_unhashed_course <- function(hashed_course, course_checksum_df){
  
  if (missing(course_checksum_df)) {
    course_checksum_df <- read_csv("../inst/data/.hashed_courses.csv")
  }
  
  
  
  selected_course <- course_checksum_df %>% 
    filter(checksum == hashed_course)
  return(selected_course$short_name)
}


requested_course_global <- reactive({
  query <- parseQueryString(session$clientData$url_search)
  
  if ("course" %in% names(query)) {
    get_unhashed_course(query$course)
  } else {
    "no_course_selected"
  }
})
