#!/usr/bin/env bash

# Parse Config
SHORT=$1
GCLOUD=$2


if [ ! -d "../data/$SHORT" ]; then
    mkdir ../data/${SHORT}
fi

gsutil cp gs://ubcxdata/${GCLOUD}/xbundle_${GCLOUD}.xml ../data/${SHORT}/xbundle.xml
gsutil cp gs://ubcxdata/${GCLOUD}/course_structure-prod-analytics.json.gz ../data/${SHORT}/prod_analytics.json.gz
gunzip -f ../data/${SHORT}/prod_analytics.json.gz