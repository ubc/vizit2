# Course Visualization for Instructional Teams (VizIT)

VizIT is a capstone project completed by Matthew Emery, David Laing, Andrew Lim, and Subi Zhang, in partial fulfillment of the degree requirements for the Master of Data Science at the University of British Columbia (UBC). The project was completed in partnership with the Centre for Teaching, Learning and Technology (CTLT) at UBC.

Hundreds of thousands of students worldwide are enrolled in UBC’s many massive open online courses (MOOCs). These MOOCs generate huge amounts of data, much of which could be used to help instructors understand how students are engaging with their courses. For our capstone project, we built a dashboard that is accessible to MOOC instructors directly in their edX course website. The dashboard helps instructors to discover patterns across the structures of their courses, with a special focus on course elements where student engagement is especially high or low. The dashboard includes visualizations of how students are interacting with course content such as videos and pages, how they are performing on problem sets, and how they are behaving in the discussion forums. Development is ongoing.

### Documentation

* [All documentation](https://ubc.github.io/vizit2/): This page contains all of our documentation, including the following topics:
    * [Engagement Overview Dashboard](https://ubc.github.io/vizit2//engagement-overview-dashboard-overview.html)
    * [General Demographics Dashboard](https://ubc.github.io/vizit2//general-demographics-overview.html)
    * [Forum Discussion Dashboard](https://ubc.github.io/vizit2//forum-overview.html)
    * [Problems Dashboard](https://ubc.github.io/vizit2//problem-overview.html)
    * [Video Dashboard](https://ubc.github.io/vizit2//video-overview.html)
    * [Deployment](https://ubc.github.io/vizit2//deployment-walkthrough.html)

## Docker Image

`docker run --rm -ti -p 3838:3838 -v $(pwd):/srv/shiny-server lstmemery/moocshiny`

## Run R tests

`R CMD check`

## Deployment

See [the deployment walkthrough here](./extra_docs/deployment.md).
