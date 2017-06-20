SELECT
  *
FROM
  [ubcxdata:UBCx__Marketing1x__3T2015.entry_survey_mapped] AS entry
LEFT OUTER JOIN
  [ubcxdata:UBCx__Marketing1x__3T2015.exit_survey_mapped] AS exit
ON
  entry.user_id=exit.user_id
LIMIT
  2000; 
