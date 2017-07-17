#! /usr/bin/env Rscript 
# wrangle_link_page.R
# Subi Zhang, May 2017
#
# This script reads in three files: course_axis.csv, page_dirt.csv and external_link_dirt.csv
# performs wrangling and exports three files : page.csv, page_name.csv and external_link.csv
# Example: Rscript wrangle_link_page.R marketing

# Load functions and libraries:
devtools::load_all()
source("../R/link_page_wrangling.R")

# Read in command line arguments.
args <- commandArgs(TRUE)
input_course <- args[1]

# Calling main function
edxviz::wrangle_link_page(input_course)
