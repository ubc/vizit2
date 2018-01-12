SELECT
  video_heat.time AS time,
  video_heat.event_type AS event_type,
  video_heat.user_id AS user_id,
  video_heat.video_id AS video_id,
  video_heat.position AS position,
  video_heat.old_time AS old_time,
  video_heat.new_time AS new_time,
  video_heat.old_speed AS old_speed,
  video_heat.new_speed AS new_speed,
  video_heat.speed_change_position AS speed_change_position,
  video_heat.video_name AS video_name,
  person_course.mode AS mode,
  person_course.gender AS gender,
  CASE
    WHEN person_course.sum_dt < 1800
      THEN "under_30_min"
    WHEN ((person_course.sum_dt >= 1800) & (person_course.sum_dt < 18000))
      THEN "30_min_to_5_hr"
    WHEN person_course.sum_dt >= 18000
      THEN "over_5_hr"
  END as activity_level
FROM (
  SELECT
    A.time AS time,
    A.event_type AS event_type,
    A.context.user_id AS user_id,
    A.video_id AS video_id,
    A.position AS position,
    A.old_time AS old_time,
    A.new_time AS new_time,
    A.old_speed AS old_speed,
    A.new_speed AS new_speed,
    A.speed_change_position AS speed_change_position,
    b.name AS video_name
  FROM (
    SELECT
      time,
      event_type,
      context.user_id,
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
    FROM (TABLE_QUERY( {course}_logs, "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN {table_date} and 20380101" ) )
    WHERE
      event IS NOT NULL
      AND username IS NOT NULL
      AND ( event_type = "load_video"
        OR event_type = "play_video"
        OR event_type = "pause_video"
        OR event_type = "stop_video"
        OR event_type = "seek_video"
        OR event_type = "speed_change_video"
        OR event_type = "seq_next"
        OR event_type = "seq_prev"
        OR event_type = "page_close"
        OR event_type LIKE "problem%" )
      AND time > PARSE_UTC_USEC("{date}")) AS A
  LEFT JOIN
    [ubcxdata:{course}.video_stats] AS B
  ON
    A.video_id = B.video_id) AS video_heat
INNER JOIN
  [ubcxdata:{course}.person_course] AS person_course
ON
  video_heat.user_id = person_course.user_id
ORDER BY
  time
LIMIT
  {limit}
