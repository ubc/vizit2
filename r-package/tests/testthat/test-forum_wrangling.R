context("Testing forum wrangling functions.")

test_that("get_activity_levels() adds activity_level and removes sum_dt.", {
        
        post_w_sum_dt <- read_csv("../../data/test_data/forum_wrangling/get_activity_levels/post_w_sum_dt.csv")
        post_w_activity_level <- read_csv("../../data/test_data/forum_wrangling/get_activity_levels/post_w_activity_level.csv")
        
        expect_equal(get_activity_levels(post_w_sum_dt),
                     post_w_activity_level)
        
})

test_that("get_post_types() adds post_type and removes bq_post_type.", {
        
        forum_posts_w_bq_post_types <- read_csv("../../data/test_data/forum_wrangling/get_post_types/forum_posts_w_bq_post_types.csv")
        forum_posts_w_post_types <- read_csv("../../data/test_data/forum_wrangling/get_post_types/forum_posts_w_post_types.csv")
        
        expect_equal(get_post_types(forum_posts_w_bq_post_types),
                     forum_posts_w_post_types)
        
})

test_that("infer_post_subcategories() correctly infers the post subcategories.", {
        
        forum_posts_pre_subcategory_inference <- read_csv("../../data/test_data/forum_wrangling/infer_post_subcategories/forum_posts_pre_subcategory_inference.csv")
        forum_posts_post_subcategory_inference <- read_csv("../../data/test_data/forum_wrangling/infer_post_subcategories/forum_posts_post_subcategory_inference.csv")
        
        forum_posts_post_subcategory_inference$commentable_id <- factor(forum_posts_post_subcategory_inference$commentable_id)
        
        expect_equal(infer_post_subcategories(forum_posts_pre_subcategory_inference),
                     forum_posts_post_subcategory_inference)
        
})

test_that("prepare_words() successfully tokenizes the forum posts and removes stop words.", {
        
        single_post <- read_csv("../../data/test_data/forum_wrangling/prepare_words/single_post.csv")
        single_post_tokenized <- read_csv("../../data/test_data/forum_wrangling/prepare_words/single_post_tokenized.csv")
        
        expect_equal(prepare_words(single_post), single_post_tokenized)
        
})

test_that("prepare_json() works as expected.", {
        
        course_json <- jsonlite::fromJSON(txt = "../../data/test_data/forum_wrangling/prepare_json/prod_analytics.json")
        json_as_tidy_dataframe <- read.csv("../../data/test_data/forum_wrangling/prepare_json/json_as_tidy_dataframe.csv")
        
        json_as_tidy_dataframe <- json_as_tidy_dataframe %>% mutate_if(is.factor,as.character)
        prepared <- prepare_json(course_json) %>% mutate_if(is.factor,as.character)
        
        expect_equal(prepared, json_as_tidy_dataframe)
        
})

test_that("prepare_xml() works as expected.", {
        
        course_xml <- XML::xmlInternalTreeParse(file = "../../data/test_data/forum_wrangling/prepare_xml/xbundle.xml")
        
        # read.csv is required for expect_equal to work here
        xml_as_tidy_dataframe <- read.csv("../../data/test_data/forum_wrangling/prepare_xml/xml_as_tidy_dataframe.csv")
        
        xml_as_tidy_dataframe <- xml_as_tidy_dataframe %>% 
          mutate_if(is.factor, as.character)
        
        prepared <- prepare_xml(course_xml) %>% 
          mutate_if(is.factor, as.character)
        
        expect_equal(prepared, xml_as_tidy_dataframe)
        
})


