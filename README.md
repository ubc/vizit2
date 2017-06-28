# MDS Capstone Project:

### edXviz: Interactive Visualization of Student Engagement with edX MOOCs

Welcome to our capstone project.

### Links

* [Project proposal](https://github.ubc.ca/ubc-mds-2016/capstone_learning_analystics_students)
* [Repository hosting our complete R package](https://github.ubc.ca/alim1990/mooc_capstone_private/tree/master/r-package)

### Dashboard

Using data from an edX psychology course, the links below demonstrate the six views of our dashboard:

* [Engagement Overview Dashboard](http://40.83.221.86/inst/global_dashboard/?dash=overview&course=psyc1)
* [General Demographics Dashboard](http://40.83.221.86/inst/global_dashboard/?dash=general&course=psyc1)
* [Links and Pages Dashboard](http://40.83.221.86/inst/global_dashboard/?dash=linkpage&course=psyc1)
* [Discussion Dashboard](http://40.83.221.86/inst/global_dashboard/?dash=forum&course=psyc1)
* [Problems Dashboard](http://40.83.221.86/inst/global_dashboard/?dash=problems&course=psyc1)
* [Video Dashboard](http://40.83.221.86/inst/global_dashboard/?dash=video&course=psyc1)

### Documentation

* [All documentation](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/index.html): This page contains all of our documentation, including the following topics:
    * [Engagement Overview Dashboard](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/engagement-overview-dashboard-overview.html)
    * [General Demographics Dashboard](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/general-demographics-overview.html)
    * [Links and Pages Dashboard](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/link-and-page-dashboard-overview.html)
    * [Forum Discussion Dashboard](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/forum-overview.html)
    * [Problems Dashboard](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/problem-overview.html)
    * [Video Dashboard](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/video-overview.html)
    * [Deployment](https://andrewlim1990.github.io/edx_dashboard_documentation.github.io/deployment-walkthrough.html)

## Docker Image

`docker run --rm -ti -p 3838:3838 -v $(pwd):/srv/shiny-server lstmemery/moocshiny`

## Run R tests

`R CMD check`

## Deployment

The whole process is enclosed in a Dockerfile. The container creates a Shiny Server instance that downloads all the necessary data files based off what is in `.config.json`. Once the app collected and cleaned the data it will update the course and insert the appropriate iFrames into the backend. From there the course instructor can see the dashboards.
