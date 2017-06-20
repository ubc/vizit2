SELECT
    video_heat.time AS time,
    video_heat.event_type as event_type,
    video_heat.username as username,
    video_heat.video_id as video_id,
    video_heat.position as position,
    video_heat.old_time as old_time,
    video_heat.new_time as new_time,
    video_heat.old_speed as old_speed,
    video_heat.new_speed as new_speed,
    video_heat.speed_change_position as speed_change_position,
    video_heat.video_name AS video_name,
    person_course.mode as mode,
    person_course.certified as certified,
    person_course.gender as gender,
    person_course.sum_dt as sum_dt
FROM
  (SELECT
    A.time AS time,
    A.event_type as event_type,
    A.username as username,
    A.video_id as video_id,
    A.position as position,
    A.old_time as old_time,
    A.new_time as new_time,
    A.old_speed as old_speed,
    A.new_speed as new_speed,
    A.speed_change_position as speed_change_position,
    b.name AS video_name

  FROM
    (SELECT    time, event_type, username,
              (case when REGEXP_MATCH( JSON_EXTRACT(event, '$.id') , r'([-])' ) then REGEXP_EXTRACT(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', ''), r'(?:.*\/)(.*)') else REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', '') end) as video_id, # This takes video id only
              (case when JSON_EXTRACT_SCALAR(event, '$.speed') is not null then float(JSON_EXTRACT_SCALAR(event,'$.speed'))*float(JSON_EXTRACT_SCALAR(event, '$.currentTime')) else  float(JSON_EXTRACT_SCALAR(event, '$.currentTime')) end) as position,
              event_struct.old_time as old_time,
              event_struct.new_time as new_time,
              event_struct.old_speed as old_speed,
              event_struct.new_speed as new_speed,
              event_struct.current_time as speed_change_position


    FROM (TABLE_QUERY(  {course}_logs,
                        "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 20160401 and 20170501"
                     )
         )


    WHERE   event is not null AND
            username is not null AND
          ( event_type = "load_video" OR
            event_type = "play_video" OR
            event_type = "pause_video" OR
            event_type = "stop_video" OR
            event_type = "seek_video" OR
            event_type = "speed_change_video" OR
            event_type = "seq_next" OR
            event_type = "seq_prev" OR
            event_type = "page_close" OR
            event_type LIKE "problem%"
          )

    order by time

    LIMIT {limit}
  ) AS A

  LEFT JOIN [ubcxdata:{course}.video_stats] AS B
  ON A.video_id = B.video_id) AS video_heat


LEFT JOIN [ubcxdata:{course}.person_course] AS person_course

ON  video_heat.username = person_course.username
