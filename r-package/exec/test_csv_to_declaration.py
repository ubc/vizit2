from .csv_to_declaration import *


def test_csv_declaration():
    test_csv = """module_id,category,index
5,video,2
7,chapter,3
7,html,4
8,problem,1
9,html,5"""

    test_csv_parsed = [line.split(",") for line in test_csv.split('\n')]

    result_call = [['module_id', 5, 7, 7, 8, 9],
                   ["category", "video", "chapter", "html", "problem", "html"],
                   ["index", 2, 3, 4, 1, 5]]

    assert convert_to_declaration(test_csv_parsed) == result_call


def test_is_numeric():
    assert is_numeric('5')
    assert is_numeric('-9')
    assert is_numeric('-1.5')
    assert is_numeric('1.234e56')
    assert not is_numeric('one')
    assert not is_numeric('1one')


def test_convert_numeric():
    assert isinstance(convert_numeric('5'), int)
    assert isinstance(convert_numeric('-9'), int)
    assert isinstance(convert_numeric('-1.5'), float)
    assert isinstance(convert_numeric('1.234e56'), float)
    assert isinstance(convert_numeric('one'), str)
    assert isinstance(convert_numeric('1one'), str)


def test_column_to_r_row():
    test_column = ["module_id", 5, 7, 7, 8, 9]
    test_r_row = "module_id = c(5, 7, 7, 8, 9),"
    assert column_to_r_column(test_column) == test_r_row


def test_text_column_to_row():
    test_text_column = ["category", "video", "chapter", "html", "problem", "html"]
    test_text_r_row = 'category = c("video", "chapter", "html", "problem", "html"),'
    assert column_to_r_column(test_text_column) == test_text_r_row


def test_export_declaration():
    test_csv = """module_id,category,index
    5,video,2
    7,chapter,3
    7,html,4
    8,problem,1
    9,html,5"""

    result_call = """tibble(
module_id = c(5, 7, 7, 8, 9),
category = c("video", "chapter", "html", "problem", "html"),
index = c(2, 3, 4, 1, 5)
)"""

    test_csv_parsed = [line.split(",") for line in test_csv.split('\n')]

    test_columns = convert_to_declaration(test_csv_parsed)
    string_columns = [column_to_r_column(column) for column in test_columns]

    print(string_columns)

    assert export_declaration(string_columns) == result_call