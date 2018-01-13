SELECT
	user_id,
	gender,
	mode AS registration_status,
	CASE
		WHEN sum_dt < 1800 THEN "under_30_min"
		WHEN ((sum_dt >= 1800) & (sum_dt < 18000)) THEN "30_min_to_5_hr"
		WHEN sum_dt >= 18000 THEN "over_5_hr"
	END as activity_level,
FROM
  [ubcxdata:{course}.person_course]
LIMIT {limit}
