SELECT
  A.module_type,
  A.module_id AS module_id,
  A.user_id,
  B.gender AS gender,
  B.mode AS mode,
  CASE
    WHEN B.sum_dt < 1800 THEN "under_30_min"
    WHEN ((B.sum_dt >= 1800) & (B.sum_dt < 18000)) THEN "30_min_to_5_hr"
    WHEN B.sum_dt >= 18000 THEN "over_5_hr"
  END as activity_level
FROM (
  SELECT
    module_type,
    module_id,
    student_id AS user_id,
    state,
    created
  FROM
    [ubcxdata:{course}.studentmodule]
  WHERE
    (module_type='video'
      AND state NOT LIKE '%00:00:00%')
    OR (module_type='problem'
      AND state LIKE '%student_answers%')
    OR module_type IN ('openassessment',
      'chapter',
      'html')
    AND created > PARSE_UTC_USEC("{date}")) AS A
INNER JOIN
  [ubcxdata:{course}.person_course] AS B
ON
  A.user_id = B.user_id
ORDER BY
  A.user_id
LIMIT
  {limit}
