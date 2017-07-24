SELECT * FROM [ubcxdata:{course}.course_axis]
WHERE start > PARSE_UTC_USEC("{date}")
LIMIT {limit}
