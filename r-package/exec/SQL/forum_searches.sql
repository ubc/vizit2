SELECT
  FORMAT_UTC_USEC(time) AS date,
  search_query,
  user_id,
  gender,
  mode AS registration_status,
  CASE
    WHEN sum_dt < 1800 THEN "under_30_min"
    WHEN ((sum_dt >= 1800) & (sum_dt < 18000)) THEN "30_min_to_5_hr"
    WHEN sum_dt >= 18000 THEN "over_5_hr"
  END as activity_level
FROM
  (SELECT *
        FROM
            [ubcxdata:{course}.forum_events]
         WHERE search_query IS NOT NULL) AS A
LEFT JOIN [ubcxdata:{course}.person_course] AS B
ON A.username = B.username
ORDER BY date DESC
LIMIT {limit}
