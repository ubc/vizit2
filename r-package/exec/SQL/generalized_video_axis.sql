SELECT
  video_id,
  index_chapter,
  index_video,
  chapter_name
FROM
  [ubcxdata:{course}.video_axis]
ORDER BY
  video_id
LIMIT
  {limit}
