SELECT
  user_id,
  cc_by_ip,
  countryLabel,
  LoE,
  YoB,
  gender,
  language,
  mode,
  sum_dt
FROM
  [ubcxdata:{course}.person_course]
WHERE
  cc_by_ip IS NOT NULL
  AND start_time > PARSE_UTC_USEC("{date}")
ORDER BY
  start_time
LIMIT
  {limit}
