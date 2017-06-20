import pytest
from .xml_extraction import *


def test_extract_chapter(chapter_xml):
    problem_xml = chapter_xml.find("problem")

    assert extract_chapter(problem_xml) == "Part 1: What Is Psychology?"


@pytest.fixture()
def chapter_xml():
    with open("test_extraction.xml") as test_xml:
        return BeautifulSoup(test_xml, "lxml")

