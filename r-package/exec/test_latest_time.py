from .latest_time import *


def test_update_timestamp_json():
    test_timestamp = {
        "courses": [{
            "course": "c_a",
            "jobs": [{
                "job": "j_a",
                "time": "2017-07-03 18:05:38"
            }]
        }]
    }

    new_timestamps = update_timestamp_json(test_timestamp, "c_b", "j_b", "2018-01-01 00:00:00")
    assert "c_b" in [key["course"] for key in new_timestamps['courses']]
    assert "j_b" in list(chain.from_iterable([[inner_key["job"] for inner_key in key["jobs"]]
                                              for key in new_timestamps['courses']]))
