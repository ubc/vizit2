import pytest

from .rbq import *


def test_malicious_date():
    with pytest.raises(MalformedQueryException):
        construct_query("dummy",
                        course="COURSE",
                        query_date="2017-01-01; MALICIOUS COMMAND")


def test_extract_limit():
    test_query = """SELECT * FROM [ubcxdata:{course}.course_axis]
WHERE start > PARSE_UTC_USEC("{date}")
LIMIT 1234"""
    assert extract_limit(test_query) == 1234

