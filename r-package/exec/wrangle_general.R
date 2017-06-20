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

# Calling main function
wrangle_general(input_course)

