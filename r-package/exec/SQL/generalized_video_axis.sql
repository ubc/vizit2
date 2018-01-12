SELECT
  video_id,
  name AS video_name,
  index_chapter,
  index_video,
  chapter_name
FROM
  [ubcxdata:{course}.video_axis]
ORDER BY
  video_id
LIMIT
  {limit}
