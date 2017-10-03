SELECT
  A.user_id AS user_id,
  gender,
  mode AS registration_status,
  sum_dt,
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
