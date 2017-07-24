Remote deployment of the EdXViz dashboard. 

EdXViz is a Shiny server application that allows instructors and course designers to see how their students are interacting with their courses. For best results, this application should be run from a server and installed there. This step-by-step guide will you set up such a server.

1. Spin up a server instance.
	This process was tested on an Azure instance with 7 Gb of RAM and 7 Gb of space. The amount of RAM needed is a function of the number of concurrent users you expect and whether they are working on multiple courses. This setup was tested with six separate courses and there was no lag.
2. SSH into your instance.
3. Install git, docker and docker-compose. In Ubuntu, type `sudo apt install -y git docker python-pip && sudo pip install docker-compose`
3. Type `git clone https://github.com/AndrewLim1990/mooc_capstone_public.git`
	This will clone the git repo. All the necessary code is included.
4. cd mooc_capstone_public/
4. Type `sudo docker run -ti --name gcloud-config google/cloud-sdk gcloud auth login` and authenticate your account.
5. `sudo docker run --rm -ti -p 3838:3838 --volumes-from gcloud-config --volumes-from gcloud-config-project -v $(pwd):/srv/shiny-server --name="populate" lstmemery/moocshiny bin/bash`
	This will download and deploy the docker image. The image is about 2 gigabytes and contains the scripts to populate the course and run the server.
6. `cd srv/shiny-server/`
7. Type `source activate mooc`
	This activates a virtual Python environment in which courses can be populated.
11. nano .config.json
	`.config.json` defines which courses should be populated. Each entry should have 
	1. A short_name (which defines it's path on the site)
	2. A BigQuery table name
	3. A Google Cloud Storage table name (likely similar to the BigQuery name)
12. `cd r-package/exec/`
13. python populate_courses.py
	This step can take a significant amount of time to complete, depending on the number of courses being populated.
14. Ctrl + p + q to exit out
15. `sudo docker-compose up`

## Running Shiny server without SSL
- Type `sudo docker run -d -p 80:3838 -v ~/mooc_capstone_public/r-package/inst/:/srv/shiny-server/ -v ~/mooc_capstone_public/logs/:/var/log/shiny-server/ lstmemery/moocshiny`