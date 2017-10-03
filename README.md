# MDS Capstone Project:

[![Travis-CI Build Status](https://travis-ci.org/laingdk/mooc_capstone_public.svg?branch=travis)](https://travis-ci.org/laingdk/mooc_capstone_public)

### edXviz: Interactive Visualization of Student Engagement with edX MOOCs

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

See [the deployment walkthrough here](./docs/deployment.md)
