import json

from bs4 import BeautifulSoup
import click as cl
from glob import glob
import os


class MalformedQuestionException(Exception):
    pass


class MalformedChapterException(Exception):
    pass


def all_choices_same(problem: BeautifulSoup):
    if problem.choicegroup:
        answers = problem.choicegroup
    elif problem.checkboxgroup:
        answers = problem.checkboxgroup
    else:
        return False

    response_types = set()
    for answer in answers.find_all('choice'):
        response_types.add(answer.attrs['correct'].lower())

    return len(response_types) == 1


def parse_question(problem_xml: BeautifulSoup, chapters: list):
    result_dict = {"id": problem_xml.attrs['url_name_orig']}

    if problem_xml.choicegroup:
        choice_group = problem_xml.choicegroup
        if 'label' in choice_group.attrs:
            problem = choice_group.attrs['label']
        elif problem_xml.label:
            problem = problem_xml.label.text
        elif problem_xml.div or problem_xml.p:
            problem = problem_xml.get_text().strip().split('\n')[0]
        else:
            problem = problem_xml.attrs['display_name']
    elif problem_xml.checkboxgroup:
        choice_group = problem_xml.checkboxgroup
        if problem_xml.p:
            problem = problem_xml.p.text
        else:
            raise MalformedQuestionException("Could not parse Checkbox Group")
    else:
        raise MalformedQuestionException("Could not parse problem")

    choices = []
    for index, choice in enumerate(choice_group.find_all('choice')):
        choices.append({"choice": choice.text.strip(),
                        "correct": choice.attrs['correct'],
                        "choice_id": 'choice_{index}'.format(index=index)})

    result_dict['chapter_name'] = extract_chapter(problem_xml)

    for index, chapter in enumerate(chapters):
        if chapter == result_dict['chapter_name']:
            result_dict['chapter_index'] = index
            break
    else:
        # Place unordered chapters at the front
        result_dict['chapter_index'] = -1

    result_dict['problem'] = problem
    result_dict["choices"] = choices
    return result_dict


def extract_chapter(problem):
    return problem.parent.parent.parent.attrs['display_name']


def filter_problems(xml_soup: BeautifulSoup):
    chapters_raw = xml_soup.find_all('chapter')
    chapters = [chapter.attrs['display_name'] for chapter in chapters_raw]

    problems = []
    problems_raw = xml_soup.find_all('problem')
    for problem in problems_raw:
        if problem.has_attr('url_name_orig') and not all_choices_same(problem):
            try:
                problems.append(parse_question(problem, chapters))
            except MalformedQuestionException as e:
                print(e)
                print(problem.text)

    return problems


def parse_assessment(assessment: BeautifulSoup):
    assessment_dict = {"url_name": assessment.attrs["url_name"],
                       "title": assessment.title.text}

    criteria = assessment.find_all("criterion")

    criteria_labels = []
    for criterion in criteria:
        criteria_labels.append({"label": criterion.label.text,
                                "name": criterion.find('name').text})

    assessment_dict['labels'] = criteria_labels

    return assessment_dict


def filter_assessments(xml_soup: BeautifulSoup):
    assessments = []
    assessments_raw = xml_soup.find_all('openassessment')

    for assessment in assessments_raw:
        assessments.append(parse_assessment(assessment))

    return assessments


@cl.command()
@cl.argument("course")
@cl.option("--problems/--assessments", default=True)
def extract_xml(course, problems):
    xml_files = glob("../data/{course}/xbundle.xml".format(course=course))

    if not os.path.exists("../results/{course}".format(course=course)):
        os.mkdir("../results/{course}".format(course=course))

    with open(xml_files[0]) as xml_file:
        xml_soup = BeautifulSoup(xml_file.read(), "lxml")

        if problems:
            output_dict = filter_problems(xml_soup)

            with open("../results/{course}/multiple_choice_questions.json".format(course=course), 'w+') as output:
                json.dump(output_dict, output)
            print("Multiple Choice JSON Ready")

        else:
            output_dict = filter_assessments(xml_soup)

            with open("../results/{course}/assessments.json".format(course=course), 'w+') as output:
                json.dump(output_dict, output)
            print("Assessment JSON Ready")


if __name__ == '__main__':
    extract_xml()