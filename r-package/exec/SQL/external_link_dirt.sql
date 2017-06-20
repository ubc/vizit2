SELECT A.username as username, 
       A.link as link, 
	   A.path,
       B.gender as gender ,
	   B.mode,
	   B.sum_dt as activity_level
FROM

    (SELECT username,
        REGEXP_EXTRACT(event, r'(.*)current') AS link,
        page AS path
		
	 FROM (TABLE_QUERY({course}_logs,
                        "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 20160501 and 20170501"))


     WHERE  event_type == "edx.ui.lms.link_clicked"
            AND event NOT Like '%target_url": "https://courses.edx.org%'
            AND event NOT Like '%target_url": "https://www.edx.org/%'
            AND event NOT Like '%target_url": "https://studio.edx.org%'
            AND event NOT Like '%target_url": "javascript:void(0)%'


     LIMIT {limit}) AS A

LEFT JOIN [ubcxdata:{course}.person_course] AS B

ON A.username = B.username
