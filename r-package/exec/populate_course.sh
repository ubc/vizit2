#!/usr/bin/env bash

SHORT=$1
LONG=$2
GCLOUD=$3


if [ ! -d "../data/$SHORT" ]; then
    mkdir ./../data/${SHORT}
fi


if [ ! -d "../results/$SHORT" ]; then
    mkdir ../results/${SHORT}
fi

python3 ./rbq.py demographic_multiple_choice -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py open_assessment -c ${SHORT} -l 1000000 --auto

python3 ./rbq.py generalized_video_heat -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py generalized_video_axis -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py generalized_demographics -c ${SHORT} -l 1000000 --auto

python3 ./rbq.py forum_posts -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py forum_searches -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py forum_views -c ${SHORT} -l 1000000 --auto

python3 ./rbq.py tower_item -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py tower_engage_dirt -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py course_axis -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py external_link_dirt -c ${SHORT} -l 1000000 --auto
python3 ./rbq.py page_dirt -c ${SHORT} -l 1000000 --auto

bash ./download_gcp_material.sh ${SHORT} "${GCLOUD}"

python3 xml_extraction.py ${SHORT} --problems
python3 xml_extraction.py ${SHORT} --assessments

Rscript ./wrangle_overview_engagement.R ${SHORT}
Rscript ./wrangle_forum.R ${SHORT}
Rscript ./wrangle_video.R ${SHORT}
Rscript ./wrangle_link_page.R ${SHORT}
Rscript ./wrangle_general.R ${SHORT}
Rscript ./wrangle_assessments.R ${SHORT}


