SELECT
	author_id,
	gender,
	mode AS registration_status,
	CASE
		WHEN sum_dt < 1800 THEN "under_30_min"
		WHEN ((sum_dt >= 1800) & (sum_dt < 18000)) THEN "30_min_to_5_hr"
		WHEN sum_dt >= 18000 THEN "over_5_hr"
	END as activity_level,
	mongoid,
  _type AS bq_post_type,
  thread_type AS initial_post_type,
  commentable_id,
  comment_thread_id,
  parent_id,
  title,
  body
FROM
  (SELECT
    author_id,
    mongoid,
    _type,
    thread_type,
    commentable_id,
    comment_thread_id,
    parent_id,
    title,
    body,
    created_at
  FROM [ubcxdata:{course}.forum])
  as A
LEFT JOIN [ubcxdata:{course}.person_course] AS B
ON  A.author_id = B.user_id
LIMIT {limit}
