# Clear work space:
rm(list=ls())


library(tidyverse)
library(forcats)
library(plotly)
library(shiny)
library(DT)
library(rsconnect)
library(gridExtra)
library(lubridate)
library(stringr)
library(shinyBS)
library(viridis)


devtools::load_all()


###################################
######    External link table #####
###################################

course_axis <- read_csv("../../data/psyc1/course_axis_test.csv")
link_dat <- read_csv("../../data/psyc1/external_link_test.csv")


#############################################
#####   Page Overview Setup           ####### 
#############################################

log_dat <- read_csv("../../data/psyc1/page_test.csv")
page_name <- read_csv("../../data/psyc1/page_name_test.csv")


# set all threshold
student_num_threshold <- 10
min_click_threshold <- 5 


# get a module name vector
chap_name <- get_module_vector(item_df = page_name)
  
  
  






