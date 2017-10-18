import click as cl

from jinja2 import Environment
from collections import namedtuple
import csv

Dashboard = namedtuple("Dashboard", "name, code")


class CourseNotFoundException(Exception):
    pass


def get_hashed_course(course_name, hash_path= "./../inst/data/.hashed_courses.csv"):
    with open(hash_path) as hash_file:
        hash_csv = csv.reader(hash_file)
        for line in hash_csv:
            if course_name == line[0]:
                return line[1]

    raise CourseNotFoundException("Course {} not found.".format(course_name))


def generate_template(html, dashboard, course, url="dev.vizit.edx.learninganalytics.ubc.ca"):
    hashed_course = get_hashed_course(course)

    template = Environment().from_string(source=html)
    print(template.render(dashboard=dashboard,
                          url=url,
                          hashed_course=hashed_course))

@cl.command()
@cl.argument('coursename')
def edxviz_html(coursename):
    list_of_dashboards = [Dashboard("Overview Engagement", "overview"),
                          Dashboard("Demographics", "demographics"),
                          Dashboard("Link and Page", "linkpage"),
                          Dashboard("Forum", "forum"),
                          Dashboard("Problem", "problem"),
                          Dashboard("Video", "video")]

    html = """
    {{ dashboard.name }} Dashboard

    <p>
        <iframe title="{{ dashboard.name }} Dashboard" src="https://{{ url }}/inst/global_dashboard/?dash={{ dashboard.code }}&course={{ hashed_course }}" marginwidth="0" marginheight="0" scrolling="yes" width=900 height=1000 frameborder="0">
            Your browser does not support IFrames.
        </iframe>
    </p>"""

    for dashboard in list_of_dashboards:
        generate_template(html, dashboard, coursename)


if __name__ == '__main__':
    edxviz_html()
