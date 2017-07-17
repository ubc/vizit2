SELECT
  FORMAT_UTC_USEC(time) AS date,
  search_query,
  A.username AS username,
  gender,
  mode AS registration_status,
  sum_dt
FROM (
  SELECT
    *
  FROM
    [ubcxdata:{course}.forum_events]
  WHERE
    search_query IS NOT NULL
    AND time > PARSE_UTC_USEC("{date} 00:00:00")) AS A
INNER JOIN (
  SELECT
    username,
    gender,
    mode,
    sum_dt
  FROM
    [ubcxdata:{course}.person_course]
  WHERE
    sum_dt IS NOT NULL) AS B
ON
  A.username = B.username
ORDER BY
  date DESC
LIMIT
  {limit}