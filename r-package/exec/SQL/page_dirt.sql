SELECT A.time, 
       A.username as username,
	   A.page as page,
       B.mode,
	   B.gender as gender,
	   B.sum_dt as activity_level
FROM       

(SELECT time,username,event_type,page 
 FROM  (TABLE_QUERY( ubcxdata:{course}_logs,
                     "integer(regexp_extract(table_id, r'tracklog_([0-9]+)')) BETWEEN 20160101 and 20170501"))
 WHERE (page is not null) AND page!= "https://courses.edx.org/xblock" AND page != "x_module"
 ORDER BY time
 LIMIT {limit}) as A 

LEFT JOIN [ubcxdata:{course}.person_course] AS B 
ON A.username = B.username