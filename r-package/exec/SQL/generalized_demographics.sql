SELECT
  user_id,
  registered,
  viewed,
  explored,
  certified,
  completed,
  cc_by_ip,
  countryLabel,
  continent,
  city,
  region,
  un_economic_group,
  un_developing_nation,
  LoE,
  YoB,
  gender,
  grade,
  passing_grade,
  start_time,
  nvideos_unique_viewed,
  nvideos_total_watched,
  ndays_act,
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