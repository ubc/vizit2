context("Testing forum wrangling functions.")

test_that("get_activity_levels() adds activity_level and removes sum_dt.", {
        
        post_w_sum_dt <- tibble(
          author_id = c(12345678),
          author_username = c("laingdk"),
          gender = c("m"),
          registration_status = c("audit"),
          sum_dt = c(453334.5436576)
        )
        
        post_w_activity_level <- tibble(
          author_id = c(12345678),
          author_username = c("laingdk"),
          gender = c("m"),
          registration_status = c("audit"),
          activity_level = c("over_5_hr")
        )
        
        expect_equal(get_activity_levels(post_w_sum_dt),
                     post_w_activity_level)
        
})

test_that("get_post_types() adds post_type and removes bq_post_type.", {
        
        forum_posts_w_bq_post_types <- tibble(
          mongoid = c("57d7f32f51efa305bc000bda", "57d7f35851efa305b3000b67", 
                      "57d7fbe6d3195b05a0000c17"),
          bq_post_type = c("CommentThread", "Comment", "Comment"),
          initial_post_type = c("Question", "", ""),
          commentable_id = c("123abc", "", ""),
          comment_thread_id = c("", "57d7f32f51efa305bc000bda", 
                                "57d7f32f51efa305bc000bda"),
          parent_id = c(NA, NA, "57d7f35851efa305b3000b67"),
          title = c("What is data science?", "", ""),
          body = c("Body1", "Body2", "Body3")
        )
        
        forum_posts_w_post_types <- tibble(
          mongoid = c("57d7f32f51efa305bc000bda", "57d7f35851efa305b3000b67", 
                      "57d7fbe6d3195b05a0000c17"),
          post_type = c("initial_post", "response_post", "comment_post"),
          initial_post_type = c("Question", "", ""),
          commentable_id = c("123abc", "", ""),
          comment_thread_id = c("", "57d7f32f51efa305bc000bda", 
                                "57d7f32f51efa305bc000bda"),
          parent_id = c(NA, NA, "57d7f35851efa305b3000b67"),
          title = c("What is data science?", "", ""),
          body = c("Body1", "Body2", "Body3")
        )
        
        print(get_post_types(forum_posts_w_bq_post_types)$post_type)
        print(forum_posts_w_post_types$post_type)
        
        
        expect_equal(get_post_types(forum_posts_w_bq_post_types),
                     forum_posts_w_post_types)
        
})

test_that("infer_post_subcategories() correctly infers the post subcategories.", {
        
        forum_posts_pre_subcategory_inference <- tibble(
          mongoid = c("57d7f32f51efa305bc000bda", "57d7f35851efa305b3000b67", "57d7fbe6d3195b05a0000c17"),
          post_type = c("initial_post", "response_post", "comment_post"),
          initial_post_type = c("Question", "", ""),
          commentable_id = c("123abc", "", ""),
          comment_thread_id = c("", "57d7f32f51efa305bc000bda", "57d7f32f51efa305bc000bda"),
          parent_id = c("", "", "57d7f35851efa305b3000b67"),
          title = c("What is data science?", "", ""),
          body = c("a", "b", "c")
        )
        
        forum_posts_post_subcategory_inference <- tibble(
          mongoid = c("57d7f32f51efa305bc000bda", "57d7f35851efa305b3000b67", "57d7fbe6d3195b05a0000c17"),
          post_type = c("initial_post", "response_post", "comment_post"),
          initial_post_type = c("Question", "", ""),
          commentable_id = c("123abc", "123abc", "123abc"),
          comment_thread_id = c("", "57d7f32f51efa305bc000bda", "57d7f32f51efa305bc000bda"),
          parent_id = c("", "", "57d7f35851efa305b3000b67"),
          title = c("What is data science?", "", ""),
          body = c("a", "b", "c"),
          responses = as.integer(c(1, 0, 0)),
          comments = as.integer(c(1, 1, 0))
        )
        
        forum_posts_post_subcategory_inference$commentable_id <- factor(forum_posts_post_subcategory_inference$commentable_id)
        
        expect_equal(infer_post_subcategories(forum_posts_pre_subcategory_inference),
                     forum_posts_post_subcategory_inference)
        
})

test_that("prepare_words() successfully tokenizes the forum posts and removes stop words.", {
        
        single_post <- tibble(
          author_id = c(12345678),
          author_username = c("laingdk"),
          gender = c("m"),
          registration_status = c("audit"),
          activity_level = c("over_5_hr"),
          mongoid = c("57d7f32f51efa305bc000bda"),
          post_type = c("initial_post"),
          initial_post_type = c("Question"),
          commentable_id = c("123abc"),
          comment_thread_id = c(""),
          parent_id = c(""),
          title = c("What is data science?"),
          body = c("Data science is a really cool new discipline that combines statistics and computer science. Is this correct?")
        )
        
        single_post_tokenized <- tibble(
          gender = c("m", "m", "m", "m", "m", "m", "m", "m", "m"),
          registration_status = c("audit", "audit", "audit", "audit", "audit", 
                                  "audit", "audit", "audit", "audit"),
          activity_level = c("over_5_hr", "over_5_hr", "over_5_hr", "over_5_hr", 
                             "over_5_hr", "over_5_hr", "over_5_hr", "over_5_hr", 
                             "over_5_hr"),
          commentable_id = c("123abc", "123abc", "123abc", "123abc", "123abc", 
                             "123abc", "123abc", "123abc", "123abc"),
          word = c("data", "science", "cool", "discipline", "combines", 
                   "statistics", "computer", "science", "correct")
        )
        
        expect_equal(prepare_words(single_post), single_post_tokenized)
        
})

test_that("prepare_json() works as expected.", {
        
        course_json <- jsonlite::fromJSON('{
  "block-v1:UBCx+MDS.1x+1T2016+type@course+block@123abc": {
        "category": "course",
        "metadata": {
        "discussion_topics": {
        "General": {
        "id": "123abc"
        }
        }
        }
},
        "block-v1:UBCx+MDS.1x+1T2016+type@discussion+block@234bcd": {
        "category": "discussion",
        "children": [],
        "metadata": {
        "discussion_category": "Block 1",
        "discussion_id": "234bcd",
        "discussion_target": "Programming for Data Science",
        "display_name": "Block 1, Programming for Data Science"
        }
        },
        "block-v1:UBCx+MDS.1x+1T2016+type@discussion+block@345cde": {
        "category": "discussion",
        "children": [],
        "metadata": {
        "discussion_category": "Block 1",
        "discussion_id": "345cde",
        "discussion_target": "Computing Platforms for Data Science",
        "display_name": "Block 1, Computing Platforms for Data Science"
        }
        }
        }')
          
        json_as_tidy_dataframe <- tibble(
          commentable_id = c("123abc", "234bcd", "345cde"),
          display_name = c("General", "Block 1, Programming for Data Science", "Block 1, Computing Platforms for Data Science"),
          discussion_category = c("General", "Block 1", "Block 1"),
          discussion_target = c("General", "Programming for Data Science", "Computing Platforms for Data Science")
        )
        
        json_as_tidy_dataframe <- json_as_tidy_dataframe %>% 
          mutate_if(is.factor, as.character)
        
        prepared <- prepare_json(course_json) %>% 
          mutate_if(is.factor, as.character) %>% 
          as_tibble()
        
        expect_equal(prepared, json_as_tidy_dataframe)
        
})

test_that("prepare_xml() works as expected.", {
        
        course_xml <- XML::xmlInternalTreeParse(file = "data/xbundle.xml")
        
        # read.csv is required for expect_equal to work here
        xml_as_tidy_dataframe <- tibble(
          discussion_target = c("General", "Programming for Data Science", 
                                "Computing Platforms for Data Science"),
          display_name = c("General", "Block 1, Programming for Data Science", 
                           "Block 1, Computing Platforms for Data Science"),
          discussion_category = c("General", "Block 1", "Block 1"),
          target_order = c(1, 2, 3),
          category_order = c(1, 2, 2)
        )
        
        xml_as_tidy_dataframe <- xml_as_tidy_dataframe %>% 
          mutate_if(is.factor, as.character) 
        
        prepared <- prepare_xml(course_xml) %>% 
          mutate_if(is.factor, as.character) %>%
          as_tibble() %>% 
          mutate_if(is.integer, as.numeric)
        
        expect_equal(prepared, xml_as_tidy_dataframe)
        
})


