docker run --rm --privileged -ti --volumes-from gcloud-config --volumes-from gcloud-config-project -v /vizit2/r-package:/srv/shiny-server --name="populate" lstmemery/moocshiny bin/bash -c "
source activate mooc && python /srv/shiny-server/exec/populate_single_course.py >> /srv/shiny-server/logs/first_populate.log 2>&1"
