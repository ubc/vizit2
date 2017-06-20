#! /usr/bin/env Rscript
# wrangle_overview_engagement.R
# Subi Zhang, May 2017
#
# This script reads in a course's tower_engage_dirt csv, performs necessary wrangling, and exports tower_engage
# Example: Rscript wrangle_overview_engagement.R marketing

devtools::load_all()


# Load functions and libraries:
source("../R/overview_engagement_wrangling.R")

# Read in command line arguments.
args <- commandArgs(TRUE)
input_course <- args[1]

# Calling main function
edxviz::wrangle_overview_engagement(input_course)
