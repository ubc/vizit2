from .latest_time import *
from itertools import chain


import pytest


def test_update_timestamp_json(timestamp):
    new_timestamps = update_timestamp_json(timestamp, "c_b", "j_b", "2018-01-01 00:00:00")

    assert "c_b" in [key["course"] for key in new_timestamps['courses']]
    assert "j_b" in list(chain.from_iterable([[inner_key["job"] for inner_key in key["jobs"]]
                                              for key in new_timestamps['courses']]))


def test_update_timestamp_json_same_course(timestamp):
    new_timestamps = update_timestamp_json(timestamp, "c_a", "j_b", "2018-01-01 00:00:00")

    assert "c_a" in [key["course"] for key in new_timestamps['courses']]
    assert len([key["course"] for key in new_timestamps['courses']]) == 1
    assert "j_b" in list(chain.from_iterable([[inner_key["job"] for inner_key in key["jobs"]]
                                              for key in new_timestamps['courses']]))
    assert len(list(chain.from_iterable([[inner_key["job"] for inner_key in key["jobs"]]
                                         for key in new_timestamps['courses']]))) == 2

def test_update_timestamp_json_same_course_same_job(timestamp):
    new_timestamps = update_timestamp_json(timestamp, "c_a", "j_a", "2018-01-01 00:00:00")
    assert "c_a" in [key["course"] for key in new_timestamps['courses']]
    assert len([key["course"] for key in new_timestamps['courses']]) == 1

    assert "j_a" in list(chain.from_iterable([[inner_key["job"] for inner_key in key["jobs"]]
                                              for key in new_timestamps['courses']]))
    assert len(list(chain.from_iterable([[inner_key["job"] for inner_key in key["jobs"]]
                                         for key in new_timestamps['courses']]))) == 1

    assert "2018-01-01 00:00:00" in list(chain.from_iterable([
        [inner_key["time"] for inner_key in key["jobs"]]
        for key in new_timestamps['courses']]))


@pytest.fixture()
def timestamp():
    return {
        "courses": [{
            "course": "c_a",
            "jobs": [{
                "job": "j_a",
                "time": "2017-07-03 18:05:38"
            }]
        }]
    }