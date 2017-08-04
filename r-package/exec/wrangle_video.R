#! /usr/bin/env Rscript 
# wrangle_video.R
# Andrew Lim, May 2017
#
# This script reads in a course's video csv and performs necessary wrangling
# Example: Rscript wrangle_video.R marketing

# Load functions and libraries:
devtools::load_all()

# Read in command line arguments.
args <- commandArgs(TRUE)
input_course <- args[1]

profvis({
  input_course <- "Biobank1x_1T2017"
  input_course <- "HtC1x_2T2017"
  # Calling main function
  wrangle_video(input_course)
})
