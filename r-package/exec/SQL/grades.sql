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

 function getActivityLevel(row,emit) {
   emit({user_id: row.user_id,
         gender: row.gender,
         mode: row.mode,
         activity_level: decodeHelper(row.sum_dt)})
 }

 function decodeHelper(x) {
   if (x < 1800) {return 'under_30_min'}
   if (x >= 1800 & x < 18000) {return '30_min_to_5_hr'}
   if (x > 18000) {return 'over_5_hr'}
 }

 bigquery.defineFunction(
   'getActivityLevel',                           // Name of the function exported to SQL
   ['user_id', 'gender', 'mode', 'sum_dt'],                    // Names of input columns
   [{'name': 'activity_level', 'type': 'string'},
    {'name': 'user_id', 'type': 'integer'},
    {'name': 'gender', 'type': 'string'},
    {'name': 'mode', 'type': 'string'}],  // Output schema
   getActivityLevel                       // Reference to JavaScript UDF
 );
