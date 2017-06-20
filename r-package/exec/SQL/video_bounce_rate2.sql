SELECT  A.date as date,
        A.username as username,
        A.video_id as video_id,
        A.position as position,
        b.name as video_name


FROM

  (SELECT date(time)as date, username,
        (case when REGEXP_MATCH( JSON_EXTRACT(event, '$.id') , r'([-])' ) then REGEXP_EXTRACT(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', ''), r'(?:.*\/)(.*)') else REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(JSON_EXTRACT(event, '$.id'), '-', '/'), '"', ''), 'i4x/', '') end) as video_id, # This takes video id only
        max(case when JSON_EXTRACT_SCALAR(event, '$.speed') is not null then float(JSON_EXTRACT_SCALAR(event,'$.speed'))*float(JSON_EXTRACT_SCALAR(event, '$.currentTime')) else  float(JSON_EXTRACT_SCALAR(event, '$.currentTime')) end) as position,

  FROM (
  TABLE_QUERY(UBCx__Marketing1x__3T2015_logs,
  "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 20151121 and 20170312"))

  WHERE (event_type = "stop_video") and
        event is not null
  group by username, video_id, date
  order by date) AS A

INNER JOIN [ubcxdata:UBCx__Marketing1x__3T2015.video_stats] AS B
ON A.video_id = B.video_id

LIMIT 2000
