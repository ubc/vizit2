import csv
from numbers import Number


def convert_to_declaration(r_csv):
    return list([convert_numeric(cell.strip()) for cell in line] for line in zip(*r_csv))


def is_numeric(num_string):
    return num_string.lstrip('-').replace(".", "").replace("e", "").isdigit()


def convert_numeric(num_string):
    if is_numeric(num_string):
        if "." in num_string:
            return float(num_string)
        else:
            return int(num_string)
    else:
        return num_string


def column_to_r_column(column):
    data = column[1:]

    if isinstance(column[1], Number):
        return '{header} = c({data})'.format(header=column[0],
                                              data=', '.join(str(datum) for datum in data))
    else:
        return '{header} = c("{data}")'.format(header=column[0],
                                                data='", "'.join(data))


def export_declaration(columns):
    column_string = ',\n'.join(columns)
    return 'tibble(\n{}\n)'.format(column_string)


def csv_to_r(csv_path):
    with open(csv_path) as csv_file:
        lines = [line for line in csv.reader(csv_file)]
        columns = convert_to_declaration(lines)
        string_columns = [column_to_r_column(column) for column in columns]
        return export_declaration(string_columns)


if __name__ == '__main__':
    print(csv_to_r(r"../tests/testthat/forum_wrangling/get_post_types/forum_posts_w_post_types.csv"))
