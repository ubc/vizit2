SELECT
  A.user_id AS user_id,
  gender,
  mode AS registration_status,
  CASE
    WHEN sum_dt < 1800 THEN "under_30_min"
    WHEN ((sum_dt >= 1800) & (sum_dt < 18000)) THEN "30_min_to_5_hr"
    WHEN sum_dt >= 18000 THEN "over_5_hr"
  END as activity_level,
  percent_grade,
  letter_grade
FROM (
  SELECT
    user_id,
    percent_grade,
    letter_grade
  FROM
    [ubcxdata:{course}.grades_persistent]
) AS A
INNER JOIN (
  SELECT
    user_id,
    gender,
    mode,
    sum_dt
  FROM
    [ubcxdata:{course}.person_course]
  WHERE
    sum_dt IS NOT NULL
) AS B
ON
  A.user_id = B.user_id
LIMIT
 {limit}
