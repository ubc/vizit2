SELECT
  *

FROM
  ( SELECT  A.username as username,
            A.max_time as max_time,
            A.time_diff as time_diff,
            B.event_type as event_type,
            B.page as page,
            B.course_id as course_id,
            B.mongoid as mongoid

    FROM
      ( SELECT username, max_time, time_diff
        FROM
        ( SELECT username, max_time, DATEDIFF(FORMAT_UTC_USEC(NOW()), max_time) AS time_diff
          FROM
            (SELECT  username,
                   MAX(time) as max_time
            FROM
              ( SELECT *
                FROM TABLE_QUERY  (UBCx__Marketing1x__3T2015_logs, "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 20140101 and 20170508")
                WHERE event_type NOT LIKE "%enrollment.deactivated%" AND
                      page != "https://courses.edx.org/xblock"
              )
            GROUP BY username
            LIMIT 12000
            )
         )
        WHERE time_diff > 60
      ) AS A


    LEFT JOIN
      (SELECT *
       FROM (TABLE_QUERY(  UBCx__Marketing1x__3T2015_logs,
                           "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 20140101 and 20170508"
                     ))
       ) AS B

    ON A.username = B.username AND A.max_time = B.time
  ) AS dropout


LEFT JOIN [ubcxdata:UBCx__Marketing1x__3T2015.person_course] AS user_info
ON  dropout.username = user_info.username
