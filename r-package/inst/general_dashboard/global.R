library(countrycode)

devtools::load_all()

course <- "creative_writing"
input_csv <- "wrangled_demographics.csv"
input_path <- paste0("../../data/", course, "/", input_csv)

demo <- read_csv(input_path)
country_info <- read_tsv("../../data/helper_data/countryInfo.tsv")
language_info <- read_csv("../../data/helper_data/language_info.csv")

loe_lvls <- data.frame(LoE=c("High School", 
                             "Bachelor's Degree", 
                             "Master's Degree", 
                             "Middle School", 
                             "Associate Degree", 
                             "Other", 
                             "Doctorate",
                             "Elementary School", 
                             "No Formal Education"),
                       rank=c(5,3,2,6,4,9,1,7,8))