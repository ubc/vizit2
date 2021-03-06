#!/usr/bin/env bash

SHORT=$1
LONG=$2
GCLOUD=$3
OVERWRITE=$4


if [ ! -d "./../inst/data/$SHORT" ]; then
    mkdir ./../inst/data/${SHORT}
fi


if [ ! -d "./../inst/results/$SHORT" ]; then
    mkdir ./../inst/results/${SHORT}
fi

Populate () {

    echo "../inst/data/$SHORT/$1.csv"
    if [[ ! -e "../inst/data/$SHORT/$1.csv"  || ${OVERWRITE} =~ .*"true".*  ]]; then
        echo "python ./rbq.py $1 -c ${SHORT} -l 1000000 --auto"
        python ./rbq.py $1 -c ${SHORT} -l 1000000 --auto
    else
        if [[ ! ${OVERWRITE} =~ .*"true".* ]]; then
            echo "python ./rbq.py $1 -c ${SHORT} -l 1000000 -d '$(python ./latest_time.py ${SHORT} $1)' --increment --auto"
             python ./rbq.py $1 -c ${SHORT} -l 1000000 -d "$(python ./latest_time.py ${SHORT} $1)" --increment --auto
        else
            echo "$SHORT $1 already exists. Ignoring."
        fi
    fi

}

Populate demographic_multiple_choice &
Populate open_assessment &

Populate generalized_video_heat &
Populate generalized_video_axis &
Populate generalized_demographics &

Populate forum_posts &
Populate forum_searches &
Populate forum_views &

Populate tower_item &
Populate tower_engage_dirt &
Populate course_axis
wait

bash ./download_gcp_material.sh ${SHORT} "${GCLOUD}"

python xml_extraction.py ${SHORT} --problems
python xml_extraction.py ${SHORT} --assessments

RPopulate () {

    if [[ ! -e "../inst/data/$SHORT/$2.csv" ||  ${OVERWRITE} =~ .*"true".* ]]; then
        echo "Rscript ./$1.R ${SHORT}"
        Rscript ./$1.R ${SHORT}
    else
        echo "$SHORT $1 already exists. Ignoring."
    fi

}

RPopulate wrangle_overview_engagement tower_engage
RPopulate wrangle_forum wrangled_forum_elements
RPopulate wrangle_video wrangled_video_heat
RPopulate wrangle_general wrangled_demographics
RPopulate wrangle_assessments wrangled_assessment_csv_info
