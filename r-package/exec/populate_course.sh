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

Populate () {

    if [ ! -e "../data/$SHORT/$1.csv" ]; then
        python3 ./rbq.py $1 -c ${SHORT} -l 1000000000 --auto
    else
        echo "$SHORT $1 already exists. Ignoring."
    fi

}

Populate demographic_multiple_choice
Populate open_assessment

Populate generalized_video_heat
Populate generalized_video_axis
Populate generalized_demographics

Populate forum_posts
Populate forum_searches
Populate forum_views

Populate tower_item
Populate tower_engage_dirt
Populate course_axis
Populate external_link_dirt
Populate page_dirt

bash ./download_gcp_material.sh ${SHORT} "${GCLOUD}"

python3 xml_extraction.py ${SHORT} --problems
python3 xml_extraction.py ${SHORT} --assessments

Rscript ./wrangle_overview_engagement.R ${SHORT}
Rscript ./wrangle_forum.R ${SHORT}
Rscript ./wrangle_video.R ${SHORT}
Rscript ./wrangle_link_page.R ${SHORT}
Rscript ./wrangle_general.R ${SHORT}
Rscript ./wrangle_assessments.R ${SHORT}
