# Capstone

## Links

* [Project proposal](https://github.ubc.ca/ubc-mds-2016/capstone_learning_analystics_students)
* [Questions for Ido and Sarah](docs/first_meeting_questions.md)


## Docker Image

`docker run --rm -ti -p 3838:3838 -v $(pwd):/srv/shiny-server lstmemery/moocshiny`

## Run R tests

`R CMD check`

## Deployment

The whole process is enclosed in a Dockerfile. The container creates a Shiny Server instance that downloads all the necessary data files based off what is in `.config.json`. Once the app collected and cleaned the data it will update the course and insert the appropriate iFrames into the backend. From there the course instructor can see the dashboards.