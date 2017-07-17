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
  FROM (TABLE_QUERY(UBCx__China300_1x__1T2016_logs, "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 19700101 and 20380101"))
  WHERE
    event_type == "edx.ui.lms.link_clicked"
    AND event NOT LIKE '%target_url": "https://courses.edx.org%'
    AND event NOT LIKE '%target_url": "https://www.edx.org/%'
    AND event NOT LIKE '%target_url": "https://studio.edx.org%'
    AND event NOT LIKE '%target_url": "javascript:void(0)%'
  LIMIT
    10000000) AS A
LEFT JOIN
  [ubcxdata:UBCx__China300_1x__1T2016.person_course] AS B
ON
  A.username = B.username
WHERE
  B.sum_dt IS NOT NULL