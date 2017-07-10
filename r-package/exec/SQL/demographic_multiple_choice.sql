SELECT
    A.user_id AS user_id,
    A.pa.problem_url_name AS problem_url_name,
    A.pa.item.response AS item_response,
    A.cp.avg_problem_pct_score AS avg_problem_pct_score,
    A.cp.problem_name AS problem_name,
    A.pa.created AS row_date,
    B.gender AS gender,
    B.mode AS mode,
    B.sum_dt AS sum_dt
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
  LEFT JOIN
    [ubcxdata:{course}.course_problem] cp
  ON
    pa.problem_url_name=cp.problem_id
  WHERE
    pa.created > PARSE_UTC_USEC("{date} 00:00:00")
  ORDER BY
    pa.created
  LIMIT
    {limit}) AS A
LEFT JOIN [ubcxdata:{course}.person_course] AS B
ON
  A.user_id = B.user_id