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
  if (requested_dashboard == "general"){
    callModule(generalModule, "generalID")
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
  else {
    callModule(problemModule, "problemID")
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
    shinyUI(fluidPage(generalModuleUI("generalID")))
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
  } else {
    shinyUI(fluidPage(problemModuleUI("problemID")))
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
get_unhashed_course <- function(hashed_course){
  selected_course <- course_checksum_df %>% 
    filter(checksum == hashed_course)
  return(selected_course$dashboard)
}
