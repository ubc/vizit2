import json

import requests

with open("../../.config.json") as config:
    config_json = json.load(config)

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36',
           'Referer': "https://studio.edge.edx.org"}

session = requests.Session()
r1 = session.get("https://studio.edge.edx.org/signin?next=/course/course-v1%3AUBCx%2BISB1%2B2015")
csrf_token = r1.cookies['csrftoken']

payload = {"email": config_json["edx_email"],
           "password": config_json["edx_password"],
           'csrfmiddlewaretoken': csrf_token,
           'next': '/course/course-v1:UBCx+ISB1+2015'}

p1 = session.post("https://studio.edge.edx.org/login_post", data=payload, headers=headers)

r2 = session.get("https://studio.edge.edx.org/course/course-v1:UBCx+ISB1+2015")
new_csrf_token = r2.cookies['csrftoken']

print(csrf_token)
print(new_csrf_token)

section_payload = {"parent_locator": "block-v1:UBCx+ISB1+2015+type@course+block@course",
                   "category": "chapter",
                   "display_name": "Section",
                   'csrfmiddlewaretoken': new_csrf_token}

post_section = session.post("https://studio.edge.edx.org/xblock/", data=section_payload, headers=headers)

section_response = post_section.text

section_name_url = "https://studio.edge.edx.org/xblock/outline/{locator}".format(locator=section_response["locator"])

section_name_dict = {"metadata": {"display_name": "AutoMDS2"},
                     'csrfmiddlewaretoken': csrf_token}

session.post(section_name_url, data=section_name_dict)

# https://studio.edge.edx.org/xblock/outline/block-v1:UBCx+ISB1+2015+type@chapter+block@da7a9be9cc604feb8d5ffd589cf46ad3
# {
#   "locator": "block-v1:UBCx+ISB1+2015+type@chapter+block@da7a9be9cc604feb8d5ffd589cf46ad3",
#   "courseKey": "course-v1:UBCx+ISB1+2015"
# }