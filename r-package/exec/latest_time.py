import json

import click as cl

class TimeStampJSONException(Exception):
    pass


def read_timestamp_json():
    with open("../data/job_timestamps.json", "r") as timestamp_file:
        return json.load(timestamp_file)


def update_timestamp_json(timestamp_dict, course, job, timestamp):

    courses = timestamp_dict['courses']

    for course_dict in courses:
        if course_dict['course'] == course:
            jobs = course_dict['jobs']

            for jobs_dict in jobs:
                if jobs_dict['job'] == job:
                    jobs_dict['time'] = timestamp
                    return timestamp_dict

            jobs.append({"job": job, "time": timestamp})
            return timestamp_dict

    courses.append({"course": course,
                    "jobs": [{"job": job,
                              "time": timestamp}]})
    return timestamp_dict


def write_timestamp_json(timestamp_dict):
    with open("../data/job_timestamps.json", "w+") as timestamp_file:
        json.dump(timestamp_dict, timestamp_file)


def perform_timestamp_json_transaction(course, job, time):
    timestamp_dict = read_timestamp_json()
    new_timestamp_dict = update_timestamp_json(timestamp_dict, course, job, time)
    write_timestamp_json(new_timestamp_dict)


def find_most_recent_job(course, job):
    timestamp_dict = read_timestamp_json()

    for course_dict in timestamp_dict["courses"]:
        if course_dict["course"] == course:
            for jobs_dict in course_dict["jobs"]:
                if jobs_dict["job"] == job:
                    return jobs_dict["time"]
            raise TimeStampJSONException("Previous job {} doesn't exist for course {}".format(course, job))

    raise TimeStampJSONException("Course {} doesn't exist".format(course))


@cl.command()
@cl.argument('course')
@cl.argument('job')
def latest_time(course, job):
    try:
        cl.echo(find_most_recent_job(course, job))
    except TimeStampJSONException:
        cl.echo("1970-01-01 00:00:00")

if __name__ == '__main__':
    latest_time()
