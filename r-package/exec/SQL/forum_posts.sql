SELECT
	author_id,
	author_username,
	gender,
	mode AS registration_status,
	sum_dt,
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
    author_username,
    mongoid,
    _type,
    thread_type,
    commentable_id,
    comment_thread_id,
    parent_id,
    title,
    body
  FROM [ubcxdata:{course}.forum])
  as A
LEFT JOIN [ubcxdata:{course}.person_course] AS B
ON  A.author_id = B.user_id
LIMIT {limit}