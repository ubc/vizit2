SELECT    (case when REGEXP_MATCH( JSON_EXTRACT(event, '$.id') , r'([-])' ) then REGEXP_EXTRACT(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', ''), r'(?:.*\/)(.*)') else REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', '') end) as video_id, # This takes video id only
          MAX(case when JSON_EXTRACT_SCALAR(event, '$.speed') is not null then float(JSON_EXTRACT_SCALAR(event,'$.speed'))*float(JSON_EXTRACT_SCALAR(event, '$.currentTime')) else  float(JSON_EXTRACT_SCALAR(event, '$.currentTime')) end) as position


FROM (TABLE_QUERY(  {course}_logs,
                    "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 20160401 and 20170501"
                 )
     )


WHERE   event is not null AND
        event_type = "stop_video"

GROUP BY video_id

ORDER BY position
