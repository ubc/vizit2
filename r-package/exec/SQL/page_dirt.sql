SELECT
  A.time,
  A.user_id AS user_id,
  A.page AS page,
  B.mode,
  B.gender AS gender,
  B.sum_dt AS activity_level
FROM (
  SELECT
    time,
    context.user_id AS user_id,
    event_type,
    page
  FROM (TABLE_QUERY( ubcxdata:{course}_logs, "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN {table_date} and 20380101"))
  WHERE
    (page IS NOT NULL)
    AND page!= "https://courses.edx.org/xblock"
    AND page != "x_module"
    AND time > PARSE_UTC_USEC("{date}")
  ORDER BY
    time
  LIMIT
    {limit}) AS A
INNER JOIN (
  SELECT
    user_id,
    gender,
    mode,
    sum_dt
  FROM [ubcxdata:{course}.person_course]
     WHERE
    sum_dt IS NOT NULL) AS B
ON
  A.user_id = B.user_id