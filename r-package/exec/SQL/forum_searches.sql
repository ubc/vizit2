SELECT 
  FORMAT_UTC_USEC(time) AS date,
  search_query,
  A.username AS username,
  gender,
  mode AS registration_status,
  sum_dt
FROM
  (SELECT *
	FROM
	    [ubcxdata:{course}.forum_events]
	 WHERE search_query IS NOT NULL) AS A
LEFT JOIN [ubcxdata:{course}.person_course] AS B
ON A.username = B.username
ORDER BY date DESC
LIMIT {limit}
