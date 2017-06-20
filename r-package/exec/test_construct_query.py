import pytest

from ..rbq import *


def test_malicious_date():
    with pytest.raises(MalformedQueryException):
        construct_query("dummy",
                        course="COURSE",
                        query_date="2017-01-01; MALICIOUS COMMAND")


