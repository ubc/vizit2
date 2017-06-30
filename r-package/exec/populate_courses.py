import subprocess
import json
import click as cl


@cl.command()
@cl.option("--overwrite", default=False)
def populate(overwrite):
    with open('../../.config.json') as config:
        config_json = json.load(config)
        courses = config_json[0]["courses"]
        for course in courses:
            command = "bash ./populate_course.sh {short_name} {big_table} {gcloud}".format(
                short_name=course['short_name'],
                big_table=course['big_table'],
                gcloud=course["cloud_platform"])
            if overwrite:
                command = "{} --overwrite=true".format(command)
            else:
                command = "{} --overwrite=false".format(command)
            subprocess.call(command, shell=True)
    write_hashed_courses()


def write_hashed_courses():
    subprocess.call('R -e "edxviz::get_hashed_courses(\'../../.config.json\','
                    ' \'../data/.hashed_courses.csv\')"',
                    shell=True)


if __name__ == '__main__':
    populate()
