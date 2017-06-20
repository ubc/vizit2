#! /usr/bin/env Rscript
# forum_wrangling.R
# David Laing, May 2017
#
# This script reads in a course's forum csv, its prod_analytics JSON file, and its XML attributes file,
# and performs the necessary wrangling for the data to be visualized in the CTLT dashboard.

# Load libraries.
library(jsonlite)
library(tidytext)
library(tidyverse)
library(XML)

source("../R/forum_wrangling.R")

# Read in command line arguments.
args <- commandArgs(TRUE)
input_course <- args[1]

input_course <- "psyc1"

root <- "../data/"

posts_input_path <- paste0(root, input_course, "/forum_posts.csv")
views_input_path <- paste0(root, input_course, "/forum_views.csv")
searches_input_path <- paste0(root, input_course, "/forum_searches.csv")
json_input_path <- paste0(root, input_course, "/prod_analytics.json")
xml_input_path <- paste0(root, input_course, "/xbundle.xml")
posts_output_path <- paste0(root, input_course, "/wrangled_forum_posts.csv")
words_output_path <- paste0(root, input_course, "/wrangled_forum_words.csv")
views_output_path <- paste0(root, input_course, "/wrangled_forum_views.csv")
searches_output_path <- paste0(root, input_course, "/wrangled_forum_searches.csv")
elements_output_path <- paste0(root, input_course, "/wrangled_forum_elements.csv")

# Call the main function.
wrangle_forum(posts_input_path = posts_input_path,
              views_input_path = views_input_path,
              searches_input_path = searches_input_path,
              json_input_path = json_input_path,
              xml_input_path = xml_input_path,
              posts_output_path = posts_output_path,
              words_output_path = words_output_path,
              views_output_path = views_output_path,
              searches_output_path = searches_output_path,
              elements_output_path = elements_output_path)
