import json

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


if __name__ == '__main__':
    # df = pd.read_csv("../data/PSYC_1x_3T2016/demographic_multiple_choice.csv")
    # timestamps = read_timestamp_json()
    # new_timestamps = update_timestamp_json(timestamps, "test_course", "test_job", datetime.utcnow())
    # print(new_timestamps)

    test_timestamp = {
        "courses": [{
            "course": "c_a",
            "jobs": [{
                "job": "j_a",
                "time": "2017-07-03 18:05:38"
            }]
        }]
    }

    print(update_timestamp_json(test_timestamp, "c_b", "j_b", "2017-07-03 18:05:38"))