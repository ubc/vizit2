#!/opt/conda/envs/mooc/bin/python

import os
import subprocess
import json
import click as cl


@cl.command()
@cl.option("--overwrite", default=True)
def populate(overwrite):
    with open('../.config.json') as config:
        config_json = json.load(config)
        courses = config_json[0]["courses"]
        for course in courses:
            command = "bash ./populate_course.sh {short_name} {big_table} {gcloud}".format(
                short_name=course['short_name'],
                big_table=course['big_table'],
                gcloud=course["cloud_platform"])
            if overwrite:
                command = "{} --overwrite=true >> srv/shiny-server/logs/cron.log 2>&1".format(command)
            print(command)
            subprocess.call(command, shell=True)
    write_hashed_courses()


def write_hashed_courses():
    subprocess.call('Rscript write_hashed_courses.R', shell=True)


if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    populate()
