SELECT
  A.username AS username,
  A.link AS link,
  A.path,
  A.time,
  B.gender AS gender,
  B.mode,
  B.sum_dt AS activity_level
FROM (
  SELECT
    username,
    REGEXP_EXTRACT(event, r'(.*)current') AS link,
    page AS path,
    time
  FROM (TABLE_QUERY({table_date}_logs, "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN {table_date} and 20380101"))
  WHERE
    event_type == "edx.ui.lms.link_clicked"
    AND event NOT LIKE '%target_url": "https://courses.edx.org%'
    AND event NOT LIKE '%target_url": "https://www.edx.org/%'
    AND event NOT LIKE '%target_url": "https://studio.edx.org%'
    AND event NOT LIKE '%target_url": "javascript:void(0)%'
  LIMIT
    {limit}) AS A
INNER JOIN
  [ubcxdata:{course}.person_course] AS B
ON
  A.username = B.username
WHERE
  B.sum_dt IS NOT NULL