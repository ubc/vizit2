import subprocess
import json

if __name__ == '__main__':
    with open('../../.config.json') as config:
        config_json = json.load(config)
        courses = config_json[0]["courses"]
        for course in courses:
            subprocess.call("sh ./populate_course.sh "
                            "{short_name} {big_table} {gcloud}".format(short_name=course['short_name'],
                                                                       big_table=course['big_table'],
                                                                       gcloud=course["cloud_platform"]),
                            shell=True)
