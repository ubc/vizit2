#' Populate a course from within R.
#' @examples
#' populate_course()
#' @details
#' This function runs the bash script \code{populate_course.sh}, which is located in exec/.
#' @export
populate_course <- function() {
  
  run_bash_script("populate_course.sh")
  
}

#' Run a bash script.
#' @param script_name A string the gives the full filename of a bash script in the current directory.
#' @return None.
#' @examples
#' run_bash_script("populate_course.sh")
#' @export
run_bash_script <- function(script_name) {
  
  command <- paste0("bash ", script_name)
  
  system(command)
  
}
