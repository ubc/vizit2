SELECT
  user_id,
  gender,
  mode,
  certified,
  wrote,
  read,
  upvoted,
  slug_id,
  slug_type,
  commentable_id,
  body
FROM
  (SELECT
    user_id,
    gender,
    mode,
    certified,
    slug_id,
    slug_type,
    title,
    wrote,
    read,
    pinned,
    upvoted
  FROM
    (SELECT
      username,
      slug_id,
      slug_type,
      title,
      wrote,
      read,
      pinned,
      upvoted
     FROM
      [ubcxdata:UBCx__CW1_1x__1T2016.forum_person])
  AS A
  LEFT JOIN
    [ubcxdata:UBCx__CW1_1x__1T2016.person_course]
  AS B
  ON  A.username = B.username)
AS C
LEFT JOIN
  [ubcxdata:UBCx__CW1_1x__1T2016.forum]
AS D
ON C.slug_id = D.mongoid
WHERE
  commentable_id != "null"
LIMIT 5000
