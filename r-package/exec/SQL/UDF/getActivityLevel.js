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

// Usage example:

// SELECT user_id, gender, mode, activity_level
// FROM getActivityLevel(
// SELECT user_id, gender, mode, sum_dt
// FROM [ubcxdata:UBCx__China300_2x__3T2015.person_course])
