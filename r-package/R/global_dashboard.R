run_dashboard_server <- function(requested_dashboard){
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
}

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
  }
}