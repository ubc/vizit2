SELECT * FROM [ubcxdata:{course}.course_axis]
WHERE start > PARSE_UTC_USEC("{date} 00:00:00")
LIMIT {limit}
