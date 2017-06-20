#' Populate a course from within R.
#' @description
#' @examples
#' populate_course()
#' @export
#' @details
#' This function runs the bash script \code{populate_course.sh}, which is located in exec/.
populate_course <- function() {

        run_bash_script("populate_course.sh")

}

#' Run a bash script.
#' @description
#' @param script_name A string the gives the full filename of a bash script in the current directory.
#' @return None.
#' @examples
#' run_bash_script("populate_course.sh")
#' @details
#'
run_bash_script <- function(script_name) {

        command <- paste0("bash ", script_name)

        system(command)

}
