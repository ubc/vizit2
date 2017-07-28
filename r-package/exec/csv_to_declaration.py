import csv
from numbers import Number


def convert_to_declaration(r_csv):
    return list([line] for line in zip(*r_csv))


def is_numeric(num_string):
    return num_string.lstrip('-').replace(".", "").replace("e", "").isdigit()



def column_to_r_row(column):
    data = column[1:]

    if isinstance(column[1], Number):
        return '{header} = c({data}),'.format(header=column[0],
                                              data=', '.join(str(datum) for datum in data))
    else:
        return '{header} = c("{data}"),'.format(header=column[0],
                                                data='", "'.join(data))


def export_declaration(columns):
    pass


if __name__ == '__main__':
    pass
