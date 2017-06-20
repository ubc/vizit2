# Load functions and libraries:
devtools::load_all()

source("video_module/videoModule.R")
source("video_module/videoModuleUI.R")
source("overview_module/overviewModule.R")
source("overview_module/overviewModuleUI.R")
source("linkpage_module/linkpageModule.R")
source("linkpage_module/linkpageModuleUI.R")
source("general_module/generalModule.R")
source("general_module/generalModuleUI.R")
source("forum_module/forumModule.R")
source("forum_module/forumModuleUI.R")

#############################
##  Video Dashboard Setup  ##
#############################
# Read data:
tidy_segment_df <- read_csv("../../data/psyc1/wrangled_video_heat.csv", col_types = cols(min_into_video = col_double()))

# Used for module filtering:
chap_name <- unique(tidy_segment_df$chapter)
chap_name <- chap_name[!is.na(chap_name)]

###############################
##  General Dashboard Setup  ##
###############################
demo <- read_csv("../../data/psyc1/wrangled_demographics.csv")

###########################################
##  Overview Engagement Dashboard Setup  ##
###########################################
# 
# # # Import clean tables
# tower_item <- read_csv("../../data/sample_data/tower_item.csv")
# tower_engage <- read_csv("../../data/sample_data/tower_engage.csv")
# #Get module name vector, in order to set the module filtering
# chap_name_overview <- get_module_vector(item_df = tower_item)
# #Create module name column for course items dataframe
# tower_item_new <- create_module_name(item_df = tower_item)


###############################################
######    Link and Page Dashboard Setup   #####
###############################################

# course_axis <- read_csv("../../data/sample_data/course_axis.csv")
# link_dat <- read_csv("../../data/sample_data/external_link.csv")
# log_dat <- read_csv("../../data/sample_data/page.csv")
# page_name <- read_csv("../../data/sample_data/page_name.csv")
# 
# # set all threshold
# student_num_threshold <- 10
# min_click_threshold <- 5 
#  
# # get a module name vector
# chap_name_linkpage <- get_module_vector(item_df = page_name)
 

# Read in the forum data:
root <- "../../data/"
course <- "psyc1"
wrangled_forum_posts <- read_csv(paste0(root, course, "/wrangled_forum_posts.csv"))
wrangled_forum_words <- read_csv(paste0(root, course, "/wrangled_forum_words.csv"))
wrangled_forum_views <- read_csv(paste0(root, course, "/wrangled_forum_views.csv"))
wrangled_forum_elements <- read_csv(paste0(root, course, "/wrangled_forum_elements.csv"))
wrangled_forum_searches <- read_csv(paste0(root, course, "/wrangled_forum_searches.csv"))





