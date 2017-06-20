SELECT author_id, date, gender, mode, certified, commentable_id, mongoid, body
FROM
  (SELECT author_id,
    DATE(created_at) AS date,
    commentable_id,
    body,
    mongoid
  FROM [ubcxdata:UBCx__UseGen_1x__1T2016.forum])
  as A
LEFT JOIN [ubcxdata:UBCx__UseGen_1x__1T2016.person_course] AS B
ON  A.author_id = B.user_id
ORDER BY A.date DESC
LIMIT 5000
