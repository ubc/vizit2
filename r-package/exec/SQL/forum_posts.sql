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
  body,
  created_at
FROM (
  SELECT
    author_id,
    author_username,
    mongoid,
    _type,
    thread_type,
    commentable_id,
    comment_thread_id,
    parent_id,
    title,
    body,
    created_at
  FROM
    [ubcxdata:{course}.forum]
  WHERE
    created_at > PARSE_UTC_USEC("{date} 00:00:00")) AS A
INNER JOIN (
  SELECT
    user_id,
    gender,
    mode,
    sum_dt
  FROM
    [ubcxdata:{course}.person_course]
  WHERE
    sum_dt IS NOT NULL) AS B
ON
  A.author_id = B.user_id
ORDER BY
  created_at
LIMIT
  {limit}
