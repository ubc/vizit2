# Load functions and libraries:
devtools::load_all()

# Read data:
tidy_segment_df <- read_csv("../../data/psyc1/wrangled_video_heat.csv", col_types = cols(min_into_video = col_double()))

# Used for module filtering:
chap_name <- unique(tidy_segment_df$chapter_name)
