# Clear work space
rm(list=ls())

# Load libraries
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
library(rsconnect)
library(devtools)

devtools::load_all()

#########################################
######  Eiffiel Tower Plot Setup   ######
#########################################

# Import clean tables
tower_item <- read_csv("../../data/psyc1/tower_item_test.csv")
tower_engage <- read_csv("../../data/psyc1/tower_engage_test.csv")

# Get module name vector, in order to set the module filtering
chap_name <- get_module_vector(item_df = tower_item)

# Create module name column for course items dataframe
tower_item_new <- create_module_name(item_df = tower_item)





    











