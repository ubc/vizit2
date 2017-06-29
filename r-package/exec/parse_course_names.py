import difflib
import json

def extract_html_line(line: str):
    return line.split('"')[1].split(".")[0]

if __name__ == '__main__':

    course_dict = [{"courses": []}]

    with open("html/courses.html") as course_html:
        courses = course_html.readlines()
        course_names = []
        for line in courses:
            if "UBCx__" in line:
                course_names.append(extract_html_line(line))

    with open("html/bucket_list.txt") as bucket_txt:
        buckets = bucket_txt.readlines()
        cleaned_buckets = []
        for bucket in buckets:
            if "UBCx__" in bucket:
                cleaned_buckets.append(bucket.split("/")[3])

    for course_name in course_names:
        print(course_name, difflib.get_close_matches(course_name, cleaned_buckets, 1)[0])

        course_dict[0]["courses"].append({"short_name": "_".join(course_name.split("__")[1:]),
                                          "big_table": course_name,
                                          "cloud_platform": difflib.get_close_matches(course_name, cleaned_buckets, 1)[0]})

    with open("../../.config.json", "w+") as config:
        json.dump(course_dict, config)
