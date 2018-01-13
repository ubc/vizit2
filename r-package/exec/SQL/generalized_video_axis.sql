SELECT
  video_id,
  name AS video_name,
  index_chapter,
  index_video,
  chapter_name
FROM
  [ubcxdata:{course}.video_axis]
ORDER BY
  index_chapter, index_video
LIMIT
  {limit}
