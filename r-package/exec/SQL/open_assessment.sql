SELECT
 A.username as username,
 A.time as time,
 A.module_id as module_id,
 A.event as event,
 A.event_type as event_type,
 B.gender AS gender,
 B.mode AS mode,
 B.sum_dt AS sum_dt
FROM (
SELECT
  *
FROM (TABLE_QUERY( {course}_logs, "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN {table_date} and 20380101" ) )
WHERE
  event_type contains "openassessment" AND
  event contains "submission_uuid" AND
  event contains "score_type"
LIMIT
  {limit}
) AS A
LEFT JOIN [ubcxdata:{course}.person_course] AS B
ON
  A.username = B.username