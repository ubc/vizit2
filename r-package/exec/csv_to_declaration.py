import csv
from numbers import Number


def convert_to_declaration(r_csv):

    for line in r_csv:
        pass

def column_to_r_row(column):
    data = column[1:]

    if isinstance(column[1], Number):
        return '{header} = c({data}),'.format(header=column[0],
                                              data=', '.join(str(datum) for datum in data))


if __name__ == '__main__':
    pass
