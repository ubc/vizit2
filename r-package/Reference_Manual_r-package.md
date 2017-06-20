

<!-- toc -->

June 20, 2017

# DESCRIPTION

```
Package: edxviz
Title: Visualize EdX Student Data
Version: 0.0.0.9000
Authors@R: c(person("Matthew", "Emery", email = "matthew.emery44@gmail.com", role = c("aut", "cre")), person("David", "Laing", email = "davidkendalllaing@gmail.com", role = c("aut")), person("Andrew", "Lim", email = "andrewlim90@gmail.com", role = c("aut")), person("Subi", "Zhang", email = "subi.zhangg@gmail.com", role = c("aut")))
Description: What the package does (one paragraph).
License: MIT + file LICENSE
Encoding: UTF-8
LazyData: true
Imports:
	DT,
	ggthemes,
	gsubfn,
	lubridate,
	plotly,
	reshape2,
	tidyjson,
	viridis,
	wordcloud,
	XML,
	zoo
Depends:
	shiny,
	shinyBS,
	tidyverse
Suggests:
  devtools,
  testthat,
    packagedocs
RoxygenNote: 6.0.1
VignetteBuilder: packagedocs
```


# `apply_forum_filters`: Apply the selected filter settings to the forum data.

## Description


 Apply the selected filter settings to the forum data.


## Usage

```r
apply_forum_filters(input_df, activity_level = "All", gender = "All",
  registration_status = "All", category = "All")
```


## Arguments

Argument      |Description
------------- |----------------
```input_df```     |     The input dataframe.
```activity_level```     |     One of `under_30_min` , `30_min_to_5_hr` , `over_5_hr` , or (default) `All` .
```gender```     |     One of `male` , `female` , `other` , or (default) `All` .
```registration_status```     |     One of `audit` , `verified` , or (default) `All` .
```category```     |     One of the forum categories.

## Value


 `filtered_df` A dataframe filtered by the selected settings.


## Examples

```r 
 apply_forum_filters(forum_posts, "All", "All", "All")
``` 

# `calculate_forum_searches`: Calculates the number of unique users who searched for each search query, given the selected filters.

## Usage

```r
calculate_forum_searches(forum_searches = wrangled_forum_searches,
  activity_level, gender, registration_status, category)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_searches```     |     The wrangled forum searches dataframe.
```activity_level```     |     The activity level of the students.
```gender```     |     The gender of the students.
```registration_status```     |     The registration status of the students.
```category```     |     The forum category.

## Details


 


## Value


 `forum_searches` The filtered forum searches dataframe.


## Examples

```r 
 calculate_forum_searches(wrangled_forum_searches, "under_30_min", "female", "verified", "Part 3")
 ``` 

# `calculate_percent_correct_tbl`: Calculate the percent of correct answers

## Description


 Each row represents a problem.


## Usage

```r
calculate_percent_correct_tbl(joined_scores, number_correct)
```


## Arguments

Argument      |Description
------------- |----------------
```joined_scores```     |     `problems_tbl` and `lookup_table` joined by `id` and `item_response`
```number_correct```     |     the result of `tally_correct_answer`

## Value


 A dataframe where each row is a row and the columns show the
 percentage and absolute number of students that got the problem correct.


# `check_integrity`: Checks to make sure start and end data passes sanity checks

## Description


 Returns a boolean of whether or not start and end data makes sense. This checks for NA values,
 end times that are passed the maximum length of the video, and extremely long and short watch durations.
 The threshold for watch durations can be adjusted in the global constants: `MIN_DURATION` and `MAX_DURATION` 


## Usage

```r
check_integrity(start, end, max_stop_position)
```


## Arguments

Argument      |Description
------------- |----------------
```start```     |     Time into video that the user has started watching the video
```end```     |     Time into the video that the user has stopped watching the video
```max_stop_position```     |     Length of the video being watched

## Value


 `integrity` : Boolean of whether or not the data passes integrity checks


## Examples

```r 
 check_integrity(start, end, max_stop_position)
 ``` 

# `clean_engagement_data`: Clean engagement data into tidy format

## Description


 Clean engagement data into tidy format


## Usage

```r
clean_engagement_data(dirt_engagement_data)
```


## Arguments

Argument      |Description
------------- |----------------
```dirt_engagement_data```     |     tower_engage_dirt dataframe object

## Value


 dirt_engagement_data


## Examples

```r 
 clean_engagement_data(dirt_engagement_data = obtain_dirt_engagement_data)
 ``` 

# `clean_multiple_choice`: Clean a demographic multiple choice CSV

## Description


 This function cleans a CSV retrieved from the `demographic_multiple_choice`
 SQL script. It transforms the `sum_dt` column into activity_level. It also
 removes any non-multiple choice problems.


## Usage

```r
clean_multiple_choice(raw_csv)
```


## Arguments

Argument      |Description
------------- |----------------
```raw_csv:```     |     A dataframe from the read_csv

## Value


 A dataframe with the same dimensions as the CSV


# `count_authors`: Count the number of authors for each subcategory in an input forum.

## Usage

```r
count_authors(input_forum, wrangled_forum_elements = wrangled_forum_elements)
```


## Arguments

Argument      |Description
------------- |----------------
```input_forum```     |     The input dataframe containing a row for each post in the forum.
```wrangled_forum_elements```     |     A dataframe containing information about each of the forum subcategories.

## Value


 `author_counts` A dataframe containing the unique author counts for each subcategory in the forum.


## Examples

```r 
 count_authors(wrangled_forum_posts)
 ``` 

# `count_posts`: Count the number of posts for each subcategory in an input forum.

## Usage

```r
count_posts(input_forum, wrangled_forum_elements = wrangled_forum_elements)
```


## Arguments

Argument      |Description
------------- |----------------
```input_forum```     |     The input dataframe containing a row for each post in the forum.
```wrangled_forum_elements```     |     A dataframe containing information about each of the forum subcategories.

## Value


 `post_counts` A dataframe containing the post counts for each subcategory in the forum.


## Examples

```r 
 count_posts(wrangled_forum_posts)
 ``` 

# `count_views`: Count the number of view events for each subcategory in an input forum.

## Usage

```r
count_views(input_forum, wrangled_forum_elements = wrangled_forum_elements)
```


## Arguments

Argument      |Description
------------- |----------------
```input_forum```     |     The input dataframe containing a row for each read event in the forum.
```wrangled_forum_elements```     |     A dataframe containing information about each of the forum subcategories.

## Value


 `view_counts` A dataframe containing the read counts for each subcategory in the forum.


## Examples

```r 
 count_views(wrangled_forum_views)
 ``` 

# `creat_link_table`: create the link summary table : external hyperlink and number of click

## Description


 create the link summary table : external hyperlink and number of click


## Usage

```r
creat_link_table(link_summary)
```


## Value


 link_df


## Examples

```r 
 creat_link_table(link_summary = reactive_link_dat())
 ``` 

# `creat_page_table`: create a page summary table to show page(name,clickable hyperlink) and its page view sorted by pageview in descending order

## Description


 create a page summary table to show page(name,clickable hyperlink) and its page view sorted by pageview in descending order


## Usage

```r
creat_page_table(page_summary)
```


## Arguments

Argument      |Description
------------- |----------------
```page_summary```     |     

## Value


 page_df


## Examples

```r 
 creat_page_table(page_summary = reactive_page())
 ``` 

# `create_module_name`: Create a new column "chapter_name" for course item dataframe in order to implementing module filtering

## Description


 Create a new column "chapter_name" for course item dataframe in order to implementing module filtering


## Usage

```r
create_module_name(item_df)
```


## Arguments

Argument      |Description
------------- |----------------
```item_df```     |     

## Value


 item_df


## Examples

```r 
 create_module_name(item_df = tower_item)
 ``` 

# `create_question_lookup_from_json`: Parse a JSON object and return it as a flat dataframe.

## Description


 This function is required to convert the JSON derived from the xbundle XML
 into a format that other dataframes can interact with.


## Usage

```r
create_question_lookup_from_json(name_lookup)
```


## Arguments

Argument      |Description
------------- |----------------
```name_lookup```     |     A JSON object contain keys for `id`, `problem`, `chapter_name`, `chapter_name`, `choices`, `correct_id` and `correct`

## Value


 A flat dataframe with the above columns


# `extract_assessment_csv`: Convert a CSV respresenting an open_assessment.sql query into a usable format

## Description


 Extracts the nececessary information from event JSON and discards it. Points
 possible should always be the same for each assessment.


## Usage

```r
extract_assessment_csv(assessment_tbl)
```


## Arguments

Argument      |Description
------------- |----------------
```assessment_tbl```     |     

## Value


 An extracted table


# `extract_assessment_json`: Convert a JSON object into a tidyJSON dataframe

## Description


 Convert a JSON object into a tidyJSON dataframe


## Usage

```r
extract_assessment_json(assessment_json)
```


## Arguments

Argument      |Description
------------- |----------------
```assessment_json```     |     An JSON file generated through `xml_extraction <course> --assessments`

## Value


 A flattened dataframe with the columns `url_name`, `title`, `label`, `name`


# `filter_chapter_linkpage`: Filter course items dataframe by the selected course module module

## Description


 Filter course items dataframe by the selected course module module


## Usage

```r
filter_chapter_linkpage(input_df, module = "All")
```


## Arguments

Argument      |Description
------------- |----------------
```module```     |     One of the modules of the course
```item_df```     |     The course items dataframe.

## Value


 A dataframe filtered by the selected course module


## Examples

```r 
 filter_chapter(tower_item, "all")
 ``` 

# `filter_chapter_overview`: Filter course items dataframe by the selected course module

## Description


 Filter course items dataframe by the selected course module


## Usage

```r
filter_chapter_overview(input_df, module = "All")
```


## Arguments

Argument      |Description
------------- |----------------
```module```     |     One of the modules of the course
```item_df```     |     The course items dataframe.

## Value


 A dataframe filtered by the selected course module


## Examples

```r 
 filter_chapter_oveview(tower_item, "all")
 ``` 

# `filter_counts`: Count the number of filtered users for each problem

## Description


 Count the number of filtered users for each problem


## Usage

```r
filter_counts(joined_user_problems)
```


## Arguments

Argument      |Description
------------- |----------------
```joined_user_problems```     |     The result of `join_users_problems`

## Value


 A dataframe with the count of unique users for each question


# `filter_demographics`: Filter student engagement dataframe by the selected demographics

## Description


 Filter student engagement dataframe by the selected demographics


## Usage

```r
filter_demographics(engage_df, gender = "All", mode = "All",
  activity_level = "All")
```


## Arguments

Argument      |Description
------------- |----------------
```engage_df```     |     The student engagement dataframe.
```gender```     |     One of "male", "female", "other", or (default) "all".
```activity_level```     |     It refers to the total time each student spent on the course.There are 4 levels: "under_30_min", "30_min_to_5_hr", "over_5_hr", or (default) "all".
```registration_status```     |     One of "audit", "verified", or (default) "all".
```module```     |     One of the modules of the course

## Value


 A dataframe filtered by the selected demographics.


## Examples

```r 
 filter_demographics(engage_df = tower_engage, gender = "all", mode = "all", activity_level = "all")
 ``` 

# `filter_extreme_problem_choices`: Retrieve the question and choice information from the extreme problems

## Description


 Retrieve the question and choice information from the extreme problems


## Usage

```r
filter_extreme_problem_choices(lookup_table, extreme_problems, filtered_counts)
```


## Arguments

Argument      |Description
------------- |----------------
```lookup_table```     |     The result of `create_question_lookup_from_json`
```extreme_problems```     |     The result of `get_extreme_summarised_score`
```filtered_counts```     |     The result of `filter_counts`

## Value


 A dataframe with lookup information attached


# `filter_forum_elements`: Filter the forum elements by the selected filter variables.

## Usage

```r
filter_forum_elements(forum_elements = wrangled_forum_elements, category)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_elements```     |     The forum elements dataframe that was passed in from the wrangling script.
```category```     |     The forum category that the user has selected.

## Details


 The forum elements dataframe only needs to be filtered by category, since it doesn't include any variables related to students.


## Value


 `filtered_forum_elements` The same dataframe, filtered by category if appropriate.


## Examples

```r 
 filter_forum_elements(wrangled_forum_elements, "Part 1")
 ``` 

# `filter_valid_questions`: Filter out invalid multiple choice problems

## Description


 Removes problems that were marked as 100 % correct (typically surveys or 
 problems where every answer is correct). Also checks from the dataframe
 derived from xbundle to ensure that the problem exists in the course.


## Usage

```r
filter_valid_questions(problems_tbl, lookup_table)
```


## Arguments

Argument      |Description
------------- |----------------
```problems_tbl```     |     The result of `read_multiple_choice_csv`
```lookup_table```     |     The result of `create_question_lookup_from_json`

## Value


 The filtered problems_tbl


# `filter_wordcloud_data`: Filter the wordcloud data by the selected filters.

## Usage

```r
filter_wordcloud_data(forum_words = wrangled_forum_words, activity_level,
  gender, registration_status, category)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_words```     |     The forum words dataframe passed in from the wrangling script.
```activity_level```     |     The activity level of the students.
```gender```     |     The gender of the students.
```registration_status```     |     The registration status of the students.
```category```     |     The forum category.

## Details


 


## Value


 `filtered_wordcloud_data` The filtered forum words dataframe.


## Examples

```r 
 filter_wordcloud_data(wrangled_forum_words, "30_min_to_5_hr", "female", "All", "General")
 ``` 

# `gather_post_types`: Gather the post types into a single column for easy plotting.

## Usage

```r
gather_post_types(forum_data, grouping_var)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_data```     |     The forum data for the main barplot.
```grouping_var```     |     grouping_var One of `discussion_category` or `display_name` , depending on whether a category has been selected.

## Details


 


## Value


 `gathered` A dataframe with the post types gathered into a single column.


## Examples

```r 
 gather_post_types(forum_data, grouping_var = "discussion_category")
 ``` 

# `get_activity_levels`: Convert sum_dt to activity_level.

## Description


 Convert sum_dt to activity_level.


## Usage

```r
get_activity_levels(forum)
```


## Arguments

Argument      |Description
------------- |----------------
```forum```     |     A forum dataframe.

## Value


 The same dataframe with a new column for activity_level.


# `get_aggregated_df`: Aggregates dataframe by video and segment

## Description


 Aggregates input dataframe by video (video_id) and segment (min_into_video).
 Additionally, adds columns:
 
 - `unique_views` / ``Students`` (number of learners who started the video),
 
 - `watch_rate` / ``Views per Student`` (number of students who have watched the segment divided by unique_views),
 
 - `avg_watch_rate` (average of watch_rate per video)


## Usage

```r
get_aggregated_df(filt_segs, top_selection, top_selection2)
```


## Arguments

Argument      |Description
------------- |----------------
```filt_segs```     |     Dataframe containing students that have been filtered by selected demographics. Typically obtained via `filter_demographics()`
```top_selection```     |     Value of the number of top segments to highlight.

## Value


 `aggregate_segment_df` : Aggregated dataframe with additional columns


## Examples

```r 
 get_aggregated_df(filt_segs, 25)
 ``` 

# `get_author_count`: Get the number of authors for which the selected filter settings apply.

## Usage

```r
get_author_count(forum_posts = wrangled_forum_posts, activity_level, gender,
  registration_status, category)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_posts```     |     The forum posts dataframe that was passed in from the wrangling script.
```activity_level```     |     The activity level of the students.
```gender```     |     The gender of the students.
```registration_status```     |     The registration status of the students.
```category```     |     The forum category.

## Details


 


## Value


 `author_count` A string showing the number of authors.


## Examples

```r 
 get_author_count(wrangled_forum_posts, "All", "male", "verified", "All")
 ``` 

# `get_ch_markers`: Obtains locations of chapter lines to be placed on visualizations

## Description


 Obtains locations of chapter lines to be placed on visualizations


## Usage

```r
get_ch_markers(filt_segs)
```


## Arguments

Argument      |Description
------------- |----------------
```filt_segs```     |     Dataframe containing students that have been filtered by selected demographics. Typically obtained via `filter_demographics()`

## Value


 `ch_markers` : List of values of where to place chapter lines on visualizations


## Examples

```r 
 get_ch_markers(filt_segs)
 ``` 

# `get_click_per_link`: Compute how many times each external link have been clicked

## Description


 Compute how many times each external link have been clicked


## Usage

```r
get_click_per_link(link_df)
```


## Arguments

Argument      |Description
------------- |----------------
```link_df```     |     

## Value


 link_num


## Examples

```r 
 get_click_per_link(link_df = link_dat)
 ``` 

# `get_discussion_vars_json`: Get the variables associated with each forum element in the JSON file. (for use in `prepare_json` ).

## Description


 Get the variables associated with each forum element in the JSON file. (for use in `prepare_json` ).


## Usage

```r
get_discussion_vars_json(i, all_elements)
```


## Arguments

Argument      |Description
------------- |----------------
```i```     |     An iterator.
```all_elements```     |     A nested list containing attributes for each course element.

## Value


 A vector containing the `commentable_id` , `display_name` , `discussion_category` , and `discussion_target` of a course element.


# `get_discussion_vars_xml`: Get the variables associated with each forum element in the XML file (for use in `prepare_xml` ).

## Description


 Get the variables associated with each forum element in the XML file (for use in `prepare_xml` ).


## Usage

```r
get_discussion_vars_xml(i, all_parameters)
```


## Arguments

Argument      |Description
------------- |----------------
```i```     |     An iterator.
```all_parameters```     |     An XML tree containing all the parameters associated with each discussion node.

## Value


 A vector containing the `display_name` , `discussion_category` , and `discussion_target` of a course element.


# `get_end_time`: Calculates video end time for non-video events using time stamps

## Description


 Calculates video end time for non-video events using time stamps


## Usage

```r
get_end_time(start, time, time_ahead, latest_speed)
```


## Arguments

Argument      |Description
------------- |----------------
```start```     |     Time into video that the user has started watching the video
```time```     |     Time stamp of when the user started watching the video
```time_ahead```     |     Time stamp of next event following the play event
```latest_speed```     |     The speed at which the user was watching the video

## Value


 `end` : Time into video that the user has stopped watching


## Examples

```r 
 get_end_time(start, time, time_ahead, latest_speed)
 ``` 

# `get_extreme_summarised_scores`: Select the easiest (or hardest) problems

## Description


 Set the index negative to receive the hardest problems.


## Usage

```r
get_extreme_summarised_scores(summarised_scores, index)
```


## Arguments

Argument      |Description
------------- |----------------
```summarised_scores```     |     the result of `get_mean_scores_filterable`
```index```     |     the number of questions you wish to view

## Value


 The summarised scores dataframe with the with the number of rows
 equal to the absolute value of the index.


# `get_forum_threads`: Get the forum threads for the authors who match the filter settings.

## Usage

```r
get_forum_threads(forum_posts = wrangled_forum_posts, activity_level, gender,
  registration_status, category, selected_subcategory)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_posts```     |     The forum posts dataframe that was passed in from the wrangling script.
```activity_level```     |     The activity level of the students.
```gender```     |     The gender of the students.
```registration_status```     |     The registration status of the students.
```category```     |     The selected forum category.
```selected_subcategory```     |     The selected forum subcategory.

## Details


 


## Value


 `forum_threads` The forum threads that were authored by students for which the filter settings apply.


## Examples

```r 
 get_forum_threads(forum_posts = wrangled_forum_posts, "over_5_hr", "female", "audit", "All", "All")
 ``` 

# `get_label_lengths`: Get the lengths of the labels on the main barplot (either the categories or the subcategories).

## Usage

```r
get_label_lengths(forum_data, category)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_data```     |     The forum data for the main barplot.
```category```     |     The selected category.

## Details


 


## Value


 `label_lengths` A list with the lengths (in characters) of each label on the main plot.


## Examples

```r 
 get_label_lengths(forum_data, "Technical Questions")
 ``` 

# `get_mean_scores_filterable`: A filterable version of get_mean_scores

## Description


 A filterable version of get_mean_scores


## Usage

```r
get_mean_scores_filterable(filtered_problems_tbl)
```


## Arguments

Argument      |Description
------------- |----------------
```filtered_problems_tbl```     |     The result of `read_multiple_choice_csv` filtered by demographics and chapter
```name_lookup```     |     A JSON object contain keys for `id`, `problem`, `chapter_name`, `chapter_name`, `choices`, `correct_id` and `correct`

## Value


 A dataframe where each row is a row and the columns show the
 percentage and absolute number of students that got the question correct.


# `get_mean_scores`: Get mean scores.

## Description


 This function is not affected by filters. If you need a function that is, use
 `get_mean_scores_filterable`. Removes scores that do not appear in the
 xbundle XML or have a 100 % percent average. This was done to remove survey 
 questions masquerading as multiple choice problems.


## Usage

```r
get_mean_scores(problems_tbl, lookup_table)
```


## Arguments

Argument      |Description
------------- |----------------
```problems_tbl```     |     The result of `clean_multiple_choice`
```lookup_table```     |     The result of `create_question_lookup_from_json`

## Value


 A dataframe with each problem, the number of users that attempted
 the problem and the percent score


# `get_mode`: Obtain most common value from list

## Description


 Obtain most common value from list


## Usage

```r
get_mode(x)
```


## Arguments

Argument      |Description
------------- |----------------
```x```     |     List containing integer values

## Value


 `mode` : The most common value within the list


## Examples

```r 
 get_mode(x=c(0,1,2,2,2,3))
 ``` 

# `get_module_nactive`: Count how many filtered students engaged with the filtered course module

## Description


 Count how many filtered students engaged with the filtered course module


## Usage

```r
get_module_nactive(tower_df)
```


## Arguments

Argument      |Description
------------- |----------------
```tower_df```     |     

## Value


 student_num


## Examples

```r 
 get_module_nactive(reactive_tower_df())
 ``` 

# `get_module_of_link`: Get which module each external link locate based on link tracklog data and course axis data

## Description


 Get which module each external link locate based on link tracklog data and course axis data


## Usage

```r
get_module_of_link(link_data, course_axis)
```


## Arguments

Argument      |Description
------------- |----------------
```link_data```     |     dataframe containing the information of student click any links in the edx course
```course_axis```     |     dataframe containing all elements in the edx course

## Value


 link_data


## Examples

```r 
 get_module_of_link(link_data = set_activity_level, course_axis = read_course_axis)
 ``` 

# `get_module_vector`: Create a module name vector sorted by the course structure index
 This vector is used in the module filtering select box in ui.R

## Description


 Create a module name vector sorted by the course structure index
 This vector is used in the module filtering select box in ui.R
 
 Create a module name vector sorted by the course structure index
 This vector is used in the module filtering select box in ui.R


## Usage

```r
get_module_vector(item_df)
get_module_vector(item_df)
```


## Arguments

Argument      |Description
------------- |----------------
```item_df```     |     
```item_df```     |     

## Value


 chap_name
 
 chap_name


## Examples

```r 
 get_module_vector(item_df = tower_item)
 ``` 

# `get_nactive`: Compute how many students engaged with each course item after filtering student demographic

## Description


 Compute how many students engaged with each course item after filtering student demographic


## Usage

```r
get_nactive(detail_df)
```


## Arguments

Argument      |Description
------------- |----------------
```detail_df```     |     

## Value


 summary_df


## Examples

```r 
 get_nactive(detail_df = tower_engage)
 ``` 

# `get_page_name`: Get the name description of each page

## Description


 Get the name description of each page


## Usage

```r
get_page_name(page_name_df)
```


## Arguments

Argument      |Description
------------- |----------------
```page_name_df```     |     

## Value


 each_page


## Examples

```r 
 get_page_name(page_name_df = page_name_mapping)
 ``` 

# `get_pageview`: Count the pageview of each page
 Here, we set a threshold for only counting pages have been viewed by more than certain amount of students

## Description


 Count the pageview of each page
 Here, we set a threshold for only counting pages have been viewed by more than certain amount of students


## Usage

```r
get_pageview(filtered_log_df)
```


## Arguments

Argument      |Description
------------- |----------------
```filtered_log_df```     |     

## Value


 page_student


## Examples

```r 
 get_pageview(filtered_log_df = log_dat)
 ``` 

# `get_post_types`: Get the post types.

## Description


 Get the post types.


## Usage

```r
get_post_types(forum)
```


## Arguments

Argument      |Description
------------- |----------------
```forum```     |     A forum dataframe.

## Value


 The same dataframe with a new column for post_type.


# `get_reactive_xvar_string`: Get the function to pass into the x value of aes_string() in the main barplot.

## Usage

```r
get_reactive_xvar_string(category)
```


## Arguments

Argument      |Description
------------- |----------------
```category```     |     The selected category.

## Details


 


## Value


 `reactive_xvar_string` A string that matches the function to call for the x value of aes_string().


## Examples

```r 
 get_reactive_xvar_string("Part 2")
 ``` 

# `get_segment_comparison_plot`: Obtains heatmap plot comparing segments against each other

## Description


 Obtains heatmap plot comparing segments against each other


## Usage

```r
get_segment_comparison_plot(filtered_segments, module, filtered_ch_markers)
```


## Arguments

Argument      |Description
------------- |----------------
```filtered_segments```     |     Dataframe of segments and corresponding watch counts filtered by demographics
```module```     |     String of module (chapter) name to display
```filtered_ch_markers```     |     List of values containing locations of where to put chapter markers

## Value


 `g` : ggplot heatmap object


## Examples

```r 
 get_segment_comparison_plot(filtered_segments, module, filtered_ch_markers)
 ``` 

# `get_start_end_df`: Obtains start and end times for video events

## Description


 Parses dataframe and adds columns `start` and `end` showing
 the start and end time that a user watched a video


## Usage

```r
get_start_end_df(data)
```


## Arguments

Argument      |Description
------------- |----------------
```data```     |     Dataframe containing tracklog data of students. This is obtained typically through `prepare_video_data()`

## Details


 This will have warning messages that can be ignored. Not sure why
 they are popping up. Something to do with get_end_time and it being
 evaluated with an entire column of data instead of just one value.
 This only occurs once per call of get_end_time. I think its an
 initialization issue.


## Value


 `start_end_df` : Original dataframe with `start` and `end` columns


## Examples

```r 
 get_start_end_df(data = data)
 ``` 

# `get_subcategory_options`: Get the options for the subcategory options, given the selected category.

## Usage

```r
get_subcategory_options(category, filtered_forum_elements)
```


## Arguments

Argument      |Description
------------- |----------------
```category```     |     The selected category.
```filtered_forum_elements```     |     The forum elements dataframe, filtered by the selected category.

## Details


 


## Value


 `subcategory_options` A list of options for the user to select from.


## Examples

```r 
 get_subcategory_options("Part 1", filtered_forum_elements)
 ``` 

# `get_summary_table`: Obtains video summary table to be used on shiny app

## Description


 Obtains video summary table to be used on shiny app


## Usage

```r
get_summary_table(aggregate_df, vid_lengths)
```


## Arguments

Argument      |Description
------------- |----------------
```aggregate_df```     |     Dataframe containing students that have been filtered by selected demographics. Typically obtained via `filter_demographics()`
```vid_lengths```     |     Dataframe containing video ID's with their associated video lengths. Typically obtained via `get_video_lengths()`

## Value


 `summary_table` : Dataframe relevant summary statistics for each video.


## Examples

```r 
 get_summary_table(filt_segs, vid_lengths)
 ``` 

# `get_target_word_counts`: Get the top words for each subcategory.

## Usage

```r
get_target_word_counts(input_forum)
```


## Arguments

Argument      |Description
------------- |----------------
```input_forum```     |     The input dataframe containing a row for each word in the forum.

## Value


 `word_counts` A dataframe containing the counts for each word in each subcategory.


## Examples

```r 
 get_target_word_counts(wrangled_forum_words)
 ``` 

# `get_top_hotspots_plot`: Obtains heatmap with segments of highest watch rate highlighted

## Description


 Obtains heatmap with segments of highest watch rate highlighted


## Usage

```r
get_top_hotspots_plot(filtered_segments, module, filtered_ch_markers)
```


## Arguments

Argument      |Description
------------- |----------------
```filtered_segments```     |     Dataframe of segments and corresponding watch counts filtered by demographics
```module```     |     String of module (chapter) name to display
```filtered_ch_markers```     |     List of values containing locations of where to put chapter markers

## Value


 `g` : ggplot heatmap object


## Examples

```r 
 get_top_hotspots_plot(filtered_segments, module, filtered_ch_markers)
 ``` 

# `get_unique_page_name`: Remove duplicated name for each page

## Description


 Remove duplicated name for each page


## Usage

```r
get_unique_page_name(each_page_df)
```


## Arguments

Argument      |Description
------------- |----------------
```each_page_df```     |     

## Value


 all_pages


## Examples

```r 
 get_unique_page_name(each_page_df = each_page)
 ``` 

# `get_video_comparison_plot`: Obtains heatmap plot comparing videos against each other

## Description


 Obtains heatmap plot comparing videos against each other


## Usage

```r
get_video_comparison_plot(filtered_segments, module, filtered_ch_markers)
```


## Arguments

Argument      |Description
------------- |----------------
```filtered_segments```     |     Dataframe of segments and corresponding watch counts filtered by demographics
```module```     |     String of module (chapter) name to display
```filtered_ch_markers```     |     List of values containing locations of where to put chapter markers

## Value


 `g` : ggplot heatmap object


## Examples

```r 
 get_video_comparison_plot(filtered_segments, module, filtered_ch_markers)
 ``` 

# `get_video_lengths`: Obtains dataframe with length of videos

## Description


 Obtains dataframe with length of videos


## Usage

```r
get_video_lengths(filt_segs)
```


## Arguments

Argument      |Description
------------- |----------------
```filt_segs```     |     Dataframe containing students that have been filtered by selected demographics. Typically obtained via `filter_demographics()`

## Value


 `vid_lengths` : Dataframe with the video lengths associated with each video ID.


## Examples

```r 
 get_video_lengths(filt_segs)
 ``` 

# `get_viewer_count`: Get the number of viewers for which the selected filter settings apply.

## Usage

```r
get_viewer_count(forum_views = wrangled_forum_views, activity_level, gender,
  registration_status, category)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_views```     |     The forum views dataframe that was passed in from the wrangling script.
```activity_level```     |     The activity level of the students.
```gender```     |     The gender of the students.
```registration_status```     |     The registration status of the students.
```category```     |     The forum category.

## Details


 


## Value


 `author_count` A string showing the number of authors.


## Examples

```r 
 get_viewer_count(wrangled_forum_views, "All", "male", "verified", "All")
 ``` 

# `get_watched_segments`: Returns original dataframe with segment columns

## Description


 Returns original dataframe with segement columns. Segment columns are 0 if the segment
 is not located within the start and end values and 1 otherwise.


## Usage

```r
get_watched_segments(data)
```


## Arguments

Argument      |Description
------------- |----------------
```data```     |     Dataframe containing start and end columns. This dataframe is typically obtained through `get_start_end_df()`

## Value


 `data` : Original input dataframe with new segment columns


## Examples

```r 
 get_watched_segments(data = start_end_df)
 ``` 

# `get_wordcloud_data`: Get the counts of each word in the selected subcategories.

## Usage

```r
get_wordcloud_data(filtered_wordcloud_data, filtered_forum_elements, category,
  selected_subcategory)
```


## Arguments

Argument      |Description
------------- |----------------
```filtered_wordcloud_data```     |     The filtered forum words dataframe.
```filtered_forum_elements```     |     The filtered forum elements dataframe.
```category```     |     The selected category.
```selected_subcategory```     |     The selected subcategory.

## Details


 


## Value


 `wordcloud_data` A dataframe with the counts of each word in the selected subcategory(ies).


## Examples

```r 
 get_wordcloud_data(filtered_wordcloud_data, filtered_forum_elements, "Part 1", "Part 1 Lecture 1 Discussion")
 ``` 

# `hash_username`: Anonyanonymize the username column as hash strings in the input_df

## Description


 Anonyanonymize the username column as hash strings in the input_df


## Usage

```r
hash_username(input_df)
```


## Arguments

Argument      |Description
------------- |----------------
```input_df```     |     A dataframe containing username column

## Value


 secure_df


## Examples

```r 
 hash_username(input_df = link_dat)
 ``` 

# `infer_post_subcategories`: Infer the subcategories of each post, even if it's a response post or a comment.

## Description


 Infer the subcategories of each post, even if it's a response post or a comment.


## Usage

```r
infer_post_subcategories(forum)
```


## Arguments

Argument      |Description
------------- |----------------
```forum```     |     A forum dataframe.

## Value


 The same dataframe with commentable_id filled in for everything.


# `join_engagement_item`: Join filtered summary engagement dataframe with filtered item dataframe to match "item " ,"item name"  and "nactive"
 convert all module item nacitve number to a constant to draw seperator line later

## Description


 Join filtered summary engagement dataframe with filtered item dataframe to match "item " ,"item name"  and "nactive"
 convert all module item nacitve number to a constant to draw seperator line later


## Usage

```r
join_engagement_item(filtered_engagement, filtered_item)
```


## Arguments

Argument      |Description
------------- |----------------
```filtered_engagement```     |     
```filtered_item```     |     

## Value


 tower_df


## Examples

```r 
 join_engagement_item(filtered_engagement = filtered_tower_engage,filtered_item = filtered_tower_item)
 ``` 

# `join_extracted_assessment_data`: Join the results of extract_assessment_csv and extract_assessment_json

## Description


 This function joins the BigQuery and XML data. This is needed to populate the
 BigQuery data with the title and label fields. If the ID of the assessment
 does not occur in the XML, it is removed before preceding.


## Usage

```r
join_extracted_assessment_data(extracted_csv, extracted_json)
```


## Arguments

Argument      |Description
------------- |----------------
```extracted_csv```     |     the result of extract_assessment_csv
```extracted_json```     |     the result of extract_assessment_csv

## Value


 A joined dataframe of the two incoming dataframes


# `join_problems_to_lookup`: Left join extracted problems and lookup table

## Description


 Left join extracted problems and lookup table


## Usage

```r
join_problems_to_lookup(extracted_problems, lookup_table)
```


## Arguments

Argument      |Description
------------- |----------------
```extracted_problems```     |     the result of `clean_multiple_choice`
```lookup_table```     |     The result of `create_question_lookup_from_json`

## Value


 The left joined dataframe by id and choice_id, filtering out blank problems


# `join_summary_lookup`: Join the summary and lookup tables

## Description


 Join the summary and lookup tables


## Usage

```r
join_summary_lookup(summarised_scores, lookup_table)
```


## Arguments

Argument      |Description
------------- |----------------
```summarised_scores```     |     the result of `get_mean_scores_filterable`
```lookup_table```     |     The result of `create_question_lookup_from_json`

## Value


 The inner join of the two dataframes


# `join_users_problems`: The left join of joined problems and summarised scores

## Description


 The left join of joined problems and summarised scores


## Usage

```r
join_users_problems(joined_problems, summarised_scores)
```


## Arguments

Argument      |Description
------------- |----------------
```joined_problems```     |     `problems_tbl` and `lookup_table` joined by `id` and `item_response`
```summarised_scores```     |     the result of `get_mean_scores_filterable`

## Value


 A left joined dataframe of joined problems and summarised scores


# `make_engagement_eiffel_tower`: Make effiel tower plot :  all video/problem course items vs. number of engaging student

## Description


 Make effiel tower plot :  all video/problem course items vs. number of engaging student


## Usage

```r
make_engagement_eiffel_tower(tower_data)
```


## Arguments

Argument      |Description
------------- |----------------
```tower_data```     |     

## Examples

```r 
 make_engagement_eiffel_tower(tower_data = reactive_tower_df())
 ``` 

# `make_forum_barplot`: Make the main barplot for displaying the forum data.

## Usage

```r
make_forum_barplot(forum_data, xvar_string, plot_variable, fill_value,
  axis_limit, category, ylabel, breakdown)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_data```     |     The forum data for the main barplot.
```xvar_string```     |     A string that matches the function to call for the x value of aes_string().
```plot_variable```     |     One of (default) `posts` , `authors` , or `views` .
```fill_value```     |     A hex value representing the color for the bar fill.
```axis_limit```     |     The maximum axis limit for the horizontal axis in the main barplot.
```category```     |     The selected category.
```ylabel```     |     The label of the y-axis in the main barplot.
```breakdown```     |     One of `TRUE` or `FALSE` ; determines whether the post types breakdown is shown.

## Details


 


## Value


 `forum_barplot` A ggplot2 object to be rendered as the main forum barplot.


## Examples

```r 
 make_forum_barplot(forum_data, xvar_string = "fct_reorder(discussion_category, course_order, .desc = TRUE)", plot_variable = "authors", fill_value = "red", axis_limit = 100, category = "All", ylabel = "Category", breakdown = FALSE)
 ``` 

# `make_forum_breakdown_barplot`: Make the main forum barplot with the post types breakdown.

## Usage

```r
make_forum_breakdown_barplot(gathered, xvar_string, grouping_var, axis_limit,
  xlabel)
```


## Arguments

Argument      |Description
------------- |----------------
```xvar_string```     |     A string that matches the function to call for the x value of aes_string().
```grouping_var```     |     grouping_var One of `discussion_category` or `display_name` , depending on whether a category has been selected.
```axis_limit```     |     The maximum axis limit for the horizontal axis in the main barplot.
```xlabel```     |     The label of the x-axis in the main barplot.
```forum_data```     |     The forum data for the main barplot.

## Details


 


## Value


 `forum_breakdown_barplot` A ggplot2 object to be rendered as the main forum barplot.


## Examples

```r 
 make_forum_breakdown_barplot(forum_data = forum_data, xvar_string = "fct_reorder(discussion_category, course_order, .desc = TRUE)", axis_limit = 100, grouping_var = "discussion_category", xlabel = "Category")
 ``` 

# `make_tidy_segments`: Returns tidy (more useable) version of input dataframe

## Description


 Returns a tidy, more usable, version of the input dataframe. Segment information is
 converted into a single column using `gather()` 


## Usage

```r
make_tidy_segments(data)
```


## Arguments

Argument      |Description
------------- |----------------
```data```     |     Dataframe containing segment information. This dataframe is typically obtained through `get_watched_segments()`

## Value


 `data` : Tidy version of input dataframe.


## Examples

```r 
 make_tidy_segments(data = start_end_df)
 ``` 

# `make_wordcloud`: One-line description.

## Usage

```r
make_wordcloud(wordcloud_data, max_words = 20, scale = c(3.5, 1))
```


## Arguments

Argument      |Description
------------- |----------------
```wordcloud_data```     |     A dataframe showing the counts of the top words in the selected subcategory.
```max_words```     |     The maximum number of words to show in the wordcloud. Default is 20.
```scale```     |     A list giving the range of sizes to for the display of words in the wordcloud. Default is c(3.5,1).

## Details


 


## Examples

```r 
 make_wordcloud(wordcloud_data, max_words = 30, scale = c(4,1.5))
 ``` 

# `obtain_raw_video_data`: Reads raw uncleaned .csv into a dataframe

## Description


 Reads the raw .csv obtained through rbq.py into a dataframe. For documentation on how to use
 rbq.py, please see www.temporaryreferencelink.com


## Usage

```r
obtain_raw_video_data(input_course, testing = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     Name of course directory (ex. psyc1, spd1, marketing, etc)

## Value


 `data` : Dataframe containing raw student track log information


## Examples

```r 
 obtain_raw_video_data(input_course = 'psyc1')
 ``` 

# `obtain_video_axis_data`: Reads video_axis.csv file

## Description


 Reads the video_axis csv obtained through rbq.py into a dataframe. For documentation on how to use
 rbq.py, please see www.temporaryreferencelink.com


## Usage

```r
obtain_video_axis_data(input_course, testing = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     Name of course directory (ex. psyc1, spd1, marketing, etc)

## Value


 `video_axis` : Dataframe containing video course structure information


## Examples

```r 
 obtain_video_axis_data(input_course = 'psyc1')
 ``` 

# `plot_assessment`: Plot the summary assessment data

## Description


 Plot the summary assessment data


## Usage

```r
plot_assessment(summary_assessment)
```


## Arguments

Argument      |Description
------------- |----------------
```summary_assessment```     |     the resulting dataframe from `summary_assessment`

## Value


 A faceted bar plot


# `populate_course`: Populate a course from within R.

## Usage

```r
populate_course()
```


## Details


 This function runs the bash script `populate_course.sh` , which is located in exec/.


## Examples

```r 
 populate_course()
 ``` 

# `prepare_filterable_problems`: Produce a dataframe clean dataframe of all questions

## Description


 Returns the question name and it's rounded percentage (out of 100). This
 function is used to prepare the data table shown at the bottom of the problem
 dashboard.


## Usage

```r
prepare_filterable_problems(summarised_scores, lookup_table)
```


## Arguments

Argument      |Description
------------- |----------------
```summarised_scores```     |     the result of `get_mean_scores_filterable`
```lookup_table```     |     The result of `create_question_lookup_from_json`

## Value


 A dataframe with the question and percent correct.


# `prepare_json`: Prepare the JSON file for joining with the XML file.

## Description


 Prepare the JSON file for joining with the XML file.


## Usage

```r
prepare_json(json)
```


## Arguments

Argument      |Description
------------- |----------------
```json```     |     A JSON file containing information about the course elements.

## Value


 A dataframe with four columns: `commentable_id` , `display_name` , `discussion_category` , and `discussion_target` .


# `prepare_page_name`: Get non-video and non-problem element name
 And create a chapter/module column for all these course elements

## Description


 Get non-video and non-problem element name
 And create a chapter/module column for all these course elements


## Usage

```r
prepare_page_name(course_axis)
```


## Arguments

Argument      |Description
------------- |----------------
```course_axis```     |     dataframe containing all course elements information

## Value


 page_name


## Examples

```r 
 prepare_page_name(course_axis =  read_course_axis)
 ``` 

# `prepare_posts`: Prepare the forum posts.

## Description


 Prepare the forum posts.


## Usage

```r
prepare_posts(forum)
```


## Arguments

Argument      |Description
------------- |----------------
```forum```     |     A dataframe with one post per row.

## Value


 The prepared forum posts data.


# `prepare_searches`: Prepare the forum searches dataframe.

## Description


 Prepare the forum searches dataframe.


## Usage

```r
prepare_searches(forum)
```


## Arguments

Argument      |Description
------------- |----------------
```forum```     |     A dataframe with one search event per row.

## Value


 The forum searches data with a new column for activity level.


## Examples

```r 
 prepare_searches(forum)
 ``` 

# `prepare_tidy_page`: Prepare tidy page tracklog data for making page summary table

## Description


 Prepare tidy page tracklog data for making page summary table


## Usage

```r
prepare_tidy_page(page_data)
```


## Arguments

Argument      |Description
------------- |----------------
```page_data```     |     

## Value


 log_data


## Examples

```r 
 prepare_tidy_page(page_data = read_page_dirt)
 ``` 

# `prepare_video_data`: Converts columns into proper variable types and adds additional columns with video information

## Description


 Additional columns added:
 
 - `max_stop_times` : proxy for video length
 
 - `course_order` : occurrence of video within course structure
 
 - `index_chapter` : occurrence of chapter within course structure
 
 - `chapter_name` : name of chapter


## Usage

```r
prepare_video_data(video_data, video_axis)
```


## Arguments

Argument      |Description
------------- |----------------
```video_axis```     |     A dataframe containing course structure information. Contains columns course_order, index_chapter, chapter_name
```data```     |     Raw input dataframe to be transformed. `data` is obtained through `obtain_raw_video_data()`

## Value


 `prepared_data` : The prepared data with converted variable types and extra columns


## Examples

```r 
 prepare_video_data(data)
 ``` 

# `prepare_views`: Prepare the forum views dataframe.

## Description


 Prepare the forum views dataframe.


## Usage

```r
prepare_views(forum)
```


## Arguments

Argument      |Description
------------- |----------------
```forum```     |     A dataframe with one read event per row.

## Value


 The prepared forum views data.


## Examples

```r 
 prepare_views(forum)
 ``` 

# `prepare_words`: Prepare the forum words.

## Description


 Prepare the forum words.


## Usage

```r
prepare_words(forum)
```


## Arguments

Argument      |Description
------------- |----------------
```forum```     |     A dataframe with one row per post.

## Value


 The dataframe with each row containing a word, prepared for joining with the forum elements.


# `prepare_xml`: Prepare the XML file for joining with the JSON file.

## Description


 Prepare the XML file for joining with the JSON file.


## Usage

```r
prepare_xml(xml)
```


## Arguments

Argument      |Description
------------- |----------------
```xml```     |     An XML file containing information about the course elements.

## Value


 A dataframe with three columns: `display_name` , `discussion_category` , and `discussion_target` .


# `read_course_axis`: Import course_axis.csv files based on specified course folder name

## Description


 Import course_axis.csv files based on specified course folder name


## Usage

```r
read_course_axis(input_course)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     

## Value


 course_axis


## Examples

```r 
 read_course_axis(input_couse = "psyc1")
 ``` 

# `read_dirt_engagement_data`: Reads in tower_engage_dirt.csv file

## Description


 Reads in tower_engage_dirt.csv file


## Usage

```r
read_dirt_engagement_data(input_course)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     Name of course directory (ex. psyc1, spd1, marketing, etc)

## Value


 `tower_engage` : Dataframe containing student engagement information with videos and problems


## Examples

```r 
 read_dirt_engagement_data(input_course = 'psyc1')
 ``` 

# `read_link_dirt`: Import external_link_dirt.csv files based on specified course folder name

## Description


 Import external_link_dirt.csv files based on specified course folder name


## Usage

```r
read_link_dirt(input_course)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     

## Value


 link_dirt


## Examples

```r 
 read_link_dirt(input_couse = "psyc1")
``` 

# `read_page_dirt`: Import page_dirt.csv files from specified course folder name

## Description


 Import page_dirt.csv files from specified course folder name


## Usage

```r
read_page_dirt(input_course)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     

## Value


 page_dirt


## Examples

```r 
 read_page_dirt(input_couse = "psyc1")
``` 

# `reset_filters`: Resets all the user-defined filters to "All".

## Usage

```r
reset_filters(session)
```


## Arguments

Argument      |Description
------------- |----------------
```session```     |     A Shiny session object. See https://shiny.rstudio.com/reference/shiny/latest/session.html

## Details


 The function is called when the user presses the "Reset" button.


## Value


 None.


## Examples

```r 
 reset_filters(session)
``` 

# `run_bash_script`: Run a bash script.

## Usage

```r
run_bash_script(script_name)
```


## Arguments

Argument      |Description
------------- |----------------
```script_name```     |     A string the gives the full filename of a bash script in the current directory.

## Details


 


## Value


 None.


## Examples

```r 
 run_bash_script("populate_course.sh")
``` 

# `set_activity_level`: Set three levels for students total spending time on course based on tracklog link data

## Description


 Set three levels for students total spending time on course based on tracklog link data


## Usage

```r
set_activity_level(link_data)
```


## Arguments

Argument      |Description
------------- |----------------
```link_data```     |     dataframe containing the information of student click any links in the edx course

## Value


 link_data


## Examples

```r 
 set_activity_level(link_data = read_link_dirt)
``` 

# `set_axis_limit`: Set the horizontal axis limit of the main barplot.

## Usage

```r
set_axis_limit(forum_data, plot_variable, label_lengths,
  min_axis_length = 0.1, percent_addition_per_char = 0.023)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_data```     |     The forum data for the main barplot.
```plot_variable```     |     One of (default) `posts` , `authors` , or `views` .
```label_lengths```     |     A list containing the lengths (in characters) of each label on the barplot.
```min_axis_length```     |     The axis length to set if all the values are set to zero (i.e. all students have been filtered out). Default is 0.1 so that the axis is minimally affected when values are small.
```percent_addition_per_char```     |     The percentage by which to expand the axis per character in the label of the longest bar. Default is 0.023, i.e. 2.3 %, because that tends to look good.} 

# `set_breakdown`: Determines whether the plot types breakdown will be shown.

## Usage

```r
set_breakdown(plot_variable, breakdown)
```


## Arguments

Argument      |Description
------------- |----------------
```plot_variable```     |     One of (default) `posts` , `authors` , or `views` .
```breakdown```     |     One of `TRUE` or (default) `FALSE` .

## Details


 This option only comes into play if the plot variable is 'posts'.


## Value


 `TRUE` or `FALSE` 


## Examples

```r 
 set_breakdown(plot_variable = "posts", breakdown = FALSE)
 ``` 

# `set_fill_value`: Set the fill value of the bars in the main barplot, given the plot variable.

## Usage

```r
set_fill_value(plot_variable)
```


## Arguments

Argument      |Description
------------- |----------------
```plot_variable```     |     One of (default) `posts` , `authors` , or `views` .

## Details


 


## Value


 `fill_value` A hex value representing the color for the bar fill.


## Examples

```r 
 set_fill_value("views")
 ``` 

# `set_forum_plot_title`: Set the title of the main barplot, according to the relevant variable and category.

## Usage

```r
set_forum_plot_title(plot_variable, category)
```


## Arguments

Argument      |Description
------------- |----------------
```plot_variable```     |     One of (default) `posts` , `authors` , or `views` .

## Details


 


## Value


 `forum_plot_title` A string for the plot title.


## Examples

```r 
 set_forum_plot_title("views", "Part 1")
 ``` 

# `set_forum_plot_ylabel`: Set the label of the y-axis in the main barplot.

## Usage

```r
set_forum_plot_ylabel(plot_variable)
```


## Arguments

Argument      |Description
------------- |----------------
```plot_variable```     |     One of (default) `posts` , `authors` , or `views` .

## Details


 


## Value


 `forum_plot_ylabe` The label of the y-axis in the main barplot.


## Examples

```r 
 set_forum_plot_ylabel("authors")
 ``` 

# `set_forum_threads_title`: Set the title of the forum threads table.

## Usage

```r
set_forum_threads_title(category, selected_subcategory)
```


## Arguments

Argument      |Description
------------- |----------------
```category```     |     The selected category.
```selected_subcategory```     |     The selected subcategory.

## Details


 


## Value


 `forum_threads_title` A string for the title of the forum threads table.


## Examples

```r 
 set_forum_threads_title("Part 3", "All")
 ``` 

# `set_wordcloud_title`: Set the title of the wordcloud.

## Usage

```r
set_wordcloud_title(category, selected_subcategory)
```


## Arguments

Argument      |Description
------------- |----------------
```category```     |     The selected category.
```selected_subcategory```     |     The selected subcategory.

## Details


 


## Value


 `wordcloud_title` A string for the wordcloud title.


## Examples

```r 
 set_wordcloud_title("Part 3", "All")
 ``` 

# `specify_forum_data_selection`: Specify which subcategory has been selected.

## Usage

```r
specify_forum_data_selection(updated_forum_data, category, selected_subcategory)
```


## Arguments

Argument      |Description
------------- |----------------
```updated_forum_data```     |     The dataframe containing the counts for each (sub)category.
```category```     |     The selected category.
```selected_subcategory```     |     The selected subcategory.

## Details


 


## Value


 `forum_w_selection` The same dataframe with a new column, `selected` .


## Examples

```r 
 specify_forum_data_selection(updated_forum_data, "Part 1", "Part 1 Video Discussion")
 ``` 

# `summarise_joined_assessment_data`: Summarise assessment data for plotting

## Description


 This function checks that the number of points possible does not vary within
 title-label groups.


## Usage

```r
summarise_joined_assessment_data(joint_assessment, trunc_length = 20)
```


## Arguments

Argument      |Description
------------- |----------------
```joint_assessment```     |     The result of join_extracted_assessment_data
```trunc_length```     |     The length of that the label should be truncated to. Do set to less than 4

## Value


 A summarised dataframe of the average scores in each area.


# `summarise_scores_by_chapter`: Summarise scores by chapter

## Description


 Calculates the average score on problems for each of the chapters based.


## Usage

```r
summarise_scores_by_chapter(summarised_scores, lookup_table)
```


## Arguments

Argument      |Description
------------- |----------------
```summarised_scores```     |     the result of `get_mean_scores_filterable`
```lookup_table```     |     The result of `create_question_lookup_from_json`

## Value


 A dataframe where each row is a chapter that contains the average
 score on that chapter


# `tally_correct_answers`: Count the number of correct answers for each question.

## Description


 Count the number of correct answers for each question.


## Usage

```r
tally_correct_answers(joined_scores)
```


## Arguments

Argument      |Description
------------- |----------------
```joined_scores```     |     `problems_tbl` and `lookup_table` joined by `id` and `item_response`

## Value


 A summarised dataframe of correct counts


# `update_forum_data`: Update the post, view, and author counts for the selected filters.

## Usage

```r
update_forum_data(forum_posts = wrangled_forum_posts,
  forum_views = wrangled_forum_views, forum_elements, activity_level, gender,
  registration_status, category)
```


## Arguments

Argument      |Description
------------- |----------------
```forum_posts```     |     The forum posts dataframe passed in from the wrangling script.
```forum_views```     |     The forum views dataframe passed in from the wrangling script.
```forum_elements```     |     The forum elements dataframe passed in from the wrangling script.
```activity_level```     |     The activity level of the students.
```gender```     |     The gender of the students.
```registration_status```     |     The registration status of the students.
```category```     |     The forum category.

## Details


 


## Value


 `filtered_forum_data` A dataframe with one row per subcategory (or category), and counts for each variable.


## Examples

```r 
 update_forum_data(wrangled_forum_posts, wrangled_forum_views, filtered_forum_elements(), "over_5_hr", "other", "audit", "All")
 ``` 

# `wrangle_forum`: Write the forum posts and forum words to csv.

## Description


 Write the forum posts and forum words to csv.


## Usage

```r
wrangle_forum(posts_input_path, views_input_path, searches_input_path,
  json_input_path, xml_input_path, posts_output_path, words_output_path,
  views_output_path, searches_output_path, elements_output_path)
```


## Arguments

Argument      |Description
------------- |----------------
```posts_input_path```     |     The path to the CSV file containing the forum posts data.
```views_input_path```     |     The path to the CSV file containing the forum reads data.
```searches_input_path```     |     The path to the CSV file containing the forum searches data.
```json_input_path```     |     The path to the JSON file containing data on all course elements.
```xml_input_path```     |     The path to the XML file containing data on the course structure.
```posts_output_path```     |     The desired path to which to write the prepared forum posts dataframe.
```words_output_path```     |     The desired path to which to write the prepared forum words dataframe.
```views_output_path```     |     The desired path to which to write the prepared forum views dataframe.
```searches_output_path```     |     The desired path to which to write the prepared forum searches dataframe.
```elements_output_path```     |     The desired path to which to write the prepared forum elements dataframe.

## Value


 None.


## Examples

```r 
 wrangle_forum(csv_path, json_path, xml_path)
 ``` 

# `wrangle_link_page`: Reads in three csv files getting from rbq.py : course_axis.csv, external_link_dirt.csv and page_dirt.csv
 Perform wrangling
 Export three csv files for building link_page_dashabord: external_link.csv, page.csv and page_name.csv

## Description


 Reads in three csv files getting from rbq.py : course_axis.csv, external_link_dirt.csv and page_dirt.csv
 Perform wrangling
 Export three csv files for building link_page_dashabord: external_link.csv, page.csv and page_name.csv


## Usage

```r
wrangle_link_page(input_course)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     

## Examples

```r 
 wrangle_link_page(input_cours = "psyc1")
 ``` 

# `wrangle_overview_engagement`: Output cleaned engagement data into corresponding course directory

## Description


 This function will automatically read a file named "tower_engage_dirt.csv"
 from the specified course directory and output a csv named "tower_engage.csv" in the same directory


## Usage

```r
wrangle_overview_engagement(input_course)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     String of course directory name

## Examples

```r 
 wrangle_video(input_course = "psyc1")
 ``` 

# `wrangle_video`: Outputs cleaned video data into corresponding course directory

## Description


 This function will automatically read a file named "generalized_video_heat.csv"
 from the specified course directory and output a csv named "wrangled_video.csv" in the same
 directory


## Usage

```r
wrangle_video(input_course, testing = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     String of course directory name

## Value


 No value returned


## Examples

```r 
 wrangle_video(input_course = "psyc1")
 ``` 

# `write_link_clean`: Export the tidy link dataframe

## Description


 Export the tidy link dataframe


## Usage

```r
write_link_clean(input_course, cleaned_data)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     
```cleaned_data```     |     tidy link dataframe

## Examples

```r 
 write_link_clean(input_course = "psyc1",cleaned_data = get_module_of_link )
 ``` 

# `write_page_clean`: Export the tidy page dataframe

## Description


 Export the tidy page dataframe


## Usage

```r
write_page_clean(input_course, cleaned_data)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     
```cleaned_data```     |     tidy page dataframe

## Examples

```r 
 write_page_clean(input_course = "psyc1",cleaned_data = prepare_tidy_page)
 ``` 

# `write_page_name`: Export the tidy course axis dataframe containing all non-video and non-problem elements with module/chapter information

## Description


 Export the tidy course axis dataframe containing all non-video and non-problem elements with module/chapter information


## Usage

```r
write_page_name(input_course, cleaned_data)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     
```cleaned_data```     |     tidy page_name dataframe

## Examples

```r 
 write_page_name(input_course = "psyc1",cleaned_data = prepare_page_name)
 ``` 

# `write_tidy_engagement_data`: Output cleaned student engagement data as csv

## Description


 Writes cleaned data as a csv into the course correct directory


## Usage

```r
write_tidy_engagement_data(input_course, cleaned_data)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     Name of course directory (ex. psyc1, spd1, marketing, etc)
```cleaned_data```     |     Dataframe containing cleaned data.

## Examples

```r 
 write_tidy_engagement_data(input_course = 'psyc1', cleaned_data= clean_engagement_data)
 ``` 

# `write_wrangled_video_data`: Outputs cleaned data as csv

## Description


 Writes cleaned data as a csv into the course correct directory


## Usage

```r
write_wrangled_video_data(input_course, cleaned_data, testing = FALSE)
```


## Arguments

Argument      |Description
------------- |----------------
```input_course```     |     Name of course directory (ex. psyc1, spd1, marketing, etc)
```cleaned_data```     |     Dataframe containing cleaned data. This cleaned data is typically obtained through `make_tidy_segments()`

## Value


 No return value


## Examples

```r 
 write_wrangled_video_data(input_course = 'psyc1', cleaned_data=start_end_df)
 ``` 

