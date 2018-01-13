SELECT
  time,
  event_type,
  context.user_id AS user_id,
  (CASE
      WHEN REGEXP_MATCH( JSON_EXTRACT(event, '$.id'), r'([-])' )
        THEN REGEXP_EXTRACT(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', ''), r'(?:.*\/)(.*)')
      ELSE REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', '') END) AS video_id,
  # This takes video id only
  (CASE
      WHEN JSON_EXTRACT_SCALAR(event, '$.speed') IS NOT NULL
        THEN FLOAT(JSON_EXTRACT_SCALAR(event,'$.speed'))*FLOAT(JSON_EXTRACT_SCALAR(event, '$.currentTime'))
      ELSE FLOAT(JSON_EXTRACT_SCALAR(event, '$.currentTime')) END) AS position,
  event_struct.old_time AS old_time,
  event_struct.new_time AS new_time,
  event_struct.old_speed AS old_speed,
  event_struct.new_speed AS new_speed,
  event_struct.current_time AS speed_change_position
FROM (
  TABLE_QUERY(
    {course}_logs,
    "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN {table_date} and 20380101"
  ))
  WHERE
    event IS NOT NULL
    AND username IS NOT NULL
    AND (event_type = "seek_video" OR event_type = "speed_change_video")
    AND time > PARSE_UTC_USEC("{date}")
ORDER BY
  time
LIMIT
  {limit}
