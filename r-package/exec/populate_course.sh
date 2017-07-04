#!/usr/bin/env bash

SHORT=$1
LONG=$2
GCLOUD=$3
OVERWRITE=$4


if [ ! -d "../data/$SHORT" ]; then
    mkdir ./../data/${SHORT}
fi


if [ ! -d "../results/$SHORT" ]; then
    mkdir ../results/${SHORT}
fi

Populate () {

    if [[ ! -e "../data/$SHORT/$1.csv"  || ${OVERWRITE} =~ .*"true".*  ]]; then
        echo "python3 ./rbq.py $1 -c ${SHORT} -l 1000000000 --auto"
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

RPopulate () {

    if [[ ! -e "../data/$SHORT/$2.csv" ||  ${OVERWRITE} =~ .*"true".* ]]; then
        Rscript ./$1.R ${SHORT}
    else
        echo "$SHORT $1 already exists. Ignoring."
    fi

}

RPopulate wrangle_overview_engagement tower_engage
RPopulate wrangle_forum wrangled_forum_elements
RPopulate wrangle_video wrangled_video_heat
RPopulate wrangle_link_page external_link
RPopulate wrangle_general wrangled_demographics
RPopulate wrangle_assessments wrangled_assessment_csv_info
