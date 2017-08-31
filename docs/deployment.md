Remote deployment of the EdXViz dashboard. 

EdXViz is a Shiny server application that allows instructors and course designers to see how their students are interacting with their courses. For best results, this application should be run from a server and installed there. This step-by-step guide will you set up such a server.

1. Spin up a server instance.
	This process was tested on an Google Compute Instance instance with 7 Gb of RAM and 30 Gb of disk space (running on CentOS 7). The amount of RAM needed is a function of the number of concurrent users you expect and whether they are working on multiple courses. This setup was tested with sixty separate courses the site was still responsive.
2. SSH into your instance.
3. Install git, docker and docker-compose. In CentOs, type `sudo yum install -y git docker-ce python-pip && sudo pip install docker-compose`
3. Type `git clone https://github.com/AndrewLim1990/mooc_capstone_public.git`
	This will clone the git repo. All the necessary code is included.
4. `sudo systemctl start docker && sudo systemctl enable docker`to start docker and ensure that it starts after reboot.
5. `sudo groupadd docker && sudo usermod -aG docker $USER` to allow docker to run from without sudo
6. Reboot for the previous work to take effect.
7. `git clone https://github.com/lstmemery/moocshiny-nginx-tmpl.git && cp moocshiny-nginx-tmpl/.config.json mooc_capstone_public`
	Note: This is for UBC only. If you do not have access to this repo, you need to create your own `.config.json`. It should look like this:
```json
[{"courses": [{"short_name": "Biobank1x_1T2017", "big_table": "UBCx__Biobank1x__1T2017", "cloud_platform": "UBCx__Biobank1x__1T2017"}]
```
8 ` cp moocshiny-nginx-tmpl/nginx.tmpl mooc_capstone_public`
9. `cd mooc_capstone_public/`
10. Type `docker run -ti --name gcloud-config google/cloud-sdk gcloud auth login` and authenticate your account.
11. Type `docker run -ti --name gcloud-config-project google/cloud-sdk gcloud auth application-default login` to authenticate the project.
12. nano .config.json
	`.config.json` defines which courses should be populated. Each entry should have 
	1. A short_name (which defines it's path on the site)
	2. A BigQuery table name
	3. A Google Cloud Storage table name (likely similar to the BigQuery name)
13. `docker run --rm --privileged -ti --volumes-from gcloud-config --volumes-from gcloud-config-project -v $(pwd):/srv/shiny-server --name="populate" lstmemery/moocshiny bin/bash -c "source activate mooc && python /srv/shiny-server/r-package/exec/populate_courses.py >> /srv/shiny-server/logs/first_populate.log 2>&1"`
	This will download and deploy the docker image. The image is about 2 gigabytes and contains the scripts to populate the course and run the server.
14. `sudo mkdir -p ~/proxy/docker-gen/templates/ && sudo cp ~/moocshiny-nginx-tmpl/nginx.tmpl ~/proxy/docker-gen/templates`
	Note: This step is only required for UBC. Non-UBC users will have to make their own `nginx.tmpl`
15. Copy the contents of `crontab` into system crontab with `crontab -e`
16. Create a DNS record in Google Compute Engine
17. `docker network create nginx-proxy`
18. Edit the environmental variables in `docker-compose.yml`.
    1. `LETSENCRYPT_EMAIL` should be your email
    2. `LETSENCRYPT_HOST` and `VIRTUAL_HOST` should be the domain name you wish to host the Shiny server on
18. `docker-compose up`


### Running Shiny server without SSL
- Type `docker run -d -p 80:3838 -v ~/mooc_capstone_public/r-package/inst/:/srv/shiny-server/ -v ~/mooc_capstone_public/logs/:/var/log/shiny-server/ lstmemery/moocshiny`

## Population Command
`source activate mooc && python srv/shiny-server/r-package/exec/populate_courses.py >> srv/shiny-server/logs/cron.log 2>&1`