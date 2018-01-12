SELECT
    A.user_id AS user_id,
    A.pa.problem_url_name AS problem_url_name,
    A.pa.item.response AS item_response,
    A.cp.avg_problem_pct_score AS avg_problem_pct_score,
    A.cp.problem_name AS problem_name,
    A.pa.created AS row_date,
    B.gender AS gender,
    B.mode AS mode,
    CASE
      WHEN B.sum_dt < 1800 THEN "under_30_min"
      WHEN ((B.sum_dt >= 1800) & (B.sum_dt < 18000)) THEN "30_min_to_5_hr"
      WHEN B.sum_dt >= 18000 THEN "over_5_hr"
    END as activity_level
FROM (
  SELECT
    pa.user_id AS user_id,
    pa.problem_url_name,
    pa.item.response,
    pa.item.correctness,
    cp.avg_problem_pct_score,
    cp.problem_name,
    pa.created
  FROM
    [ubcxdata:{course}.problem_analysis] pa
  INNER JOIN
    [ubcxdata:{course}.course_problem] cp
  ON
    pa.problem_url_name=cp.problem_id
  WHERE
    pa.created > PARSE_UTC_USEC("{date}")
  ORDER BY
    pa.created) AS A
INNER JOIN (
  SELECT
    user_id,
    gender,
    mode,
    sum_dt
  FROM [ubcxdata:{course}.person_course]
     WHERE
    sum_dt IS NOT NULL) AS B
ON
  A.user_id = B.user_id
WHERE
  B.sum_dt IS NOT NULL
LIMIT
    {limit}
