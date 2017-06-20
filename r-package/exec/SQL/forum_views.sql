SELECT
  user_id,
  gender,
  mode AS registration_status,
  sum_dt,
  subject AS commentable_id,
  thread_id AS comment_thread_id
FROM
  (SELECT
    username,
    subject,
    thread_id
   FROM
    [ubcxdata:{course}.forum_events]
   WHERE
    (forum_action = "read"))
AS A
LEFT JOIN
  [ubcxdata:{course}.person_course]
AS B
ON A.username = B.username
LIMIT {limit}
