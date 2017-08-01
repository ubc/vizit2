import json
import os.path
import re

from datetime import datetime
import pandas as pd
import click as cl

from latest_time import perform_timestamp_json_transaction, find_most_recent_job, TimeStampJSONException


class MalformedQueryException(Exception):
    pass


class MalformedCourseException(Exception):
    pass


def construct_query(sql: str,
                    course: str,
                    query_date="1970-01-01 00:00:00",
                    limit=100):
    """Constructs a legal BigQuery from a string.

    Parameters
    ----------
    sql : str
        A formattable SQL string derived from a script in the ./exec/SQL directory.
    course : str
        The table name of the course in Google BigQuery.
    query_date : str
        A string representing a day in ISO format.
    limit : int
        The maximum number of rows allowable.

    Returns
    -------
    str
        A completed SQL string to be submitted to Google BigQuery.
    """
    if not isinstance(course, str):
        raise MalformedQueryException("Course is not a string")
    try:
        datetime.strptime(query_date, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        raise MalformedQueryException("Query date is not a date")
    try:
        int(limit)
    except ValueError:
        raise MalformedQueryException("Limit is not an integer")

    with open(sql) as open_sql:
        sql_string = open_sql.read()
        return sql_string.format(course=course,
                                 date=query_date,
                                 limit=limit,
                                 table_date=''.join(query_date.split(" ")[0].split("-")))


def query_bigquery(query: str, output: str, confirm=True, full=True):
    if confirm:
        print(query)
        query_permission = input("Are you sure you wish to execute this query? [y/N] ")

        while True:
            if query_permission.lower() == 'y':
                write_sql_csv(output, query, full)
                return
            elif query_permission.lower() == 'n':
                return
            else:
                print("Command not understood.")
                query_permission = input("Are you sure you wish to execute this query? [y/N] ")
    else:
        write_sql_csv(output, query, full)
        print("Saved to {output}".format(output=output))


def write_sql_csv(output, query, full=True):
    limit = extract_limit(query)
    ubc_tbl = pd.read_gbq(query, "ubcxdata")
    print("Full Update? {}".format(full))
    first = True
    while ubc_tbl.shape[0] == limit:
        ubc_tbl = pd.read_gbq(query, "ubcxdata")
        if full and first:
            ubc_tbl.to_csv(output, index=False)
        else:
            ubc_tbl.to_csv(output, mode="a", index=False, header=False)

        if first:
            first = False
        query = add_offset(query)


def add_offset(query):
    offset = re.search("(?:OFFSET\s+)(\d+)", query, re.MULTILINE)
    if offset:
        limit = extract_limit(query)
        offset_number = int(offset.group(1))
        new_offset = str(limit + offset_number)
        new_query = re.sub(r"(OFFSET)\s+(\d+)", r"\1 {}".format(new_offset), query, re.MULTILINE)
    else:
        limit = extract_limit(query)
        new_query = re.sub(r"(LIMIT)\s+(\d+)", r"LIMIT \2 OFFSET {}".format(limit), query, re.MULTILINE)

    return new_query




def extract_limit(query):
    return int(re.search("LIMIT\s+(\d+)", query, re.MULTILINE).group(1))


@cl.command()
@cl.argument('sql')
@cl.option('--course', '-c', help="The course you are interested in.")
@cl.option('--date', '-d',
           default="1970-01-01 00:00:00",
           help="The date of the query in YYYY-MM-DD format, if applicable.")
@cl.option('--limit', '-l', default=100, help="Maximum number of rows")
@cl.option('--confirm/--auto', default=True, help="Warn before attempting BigQuery")
@cl.option('--output', '-o', default=False, help="Output directory")
@cl.option('--full/--increment', default=True,
           help="Full update or incremental update. (Full purges previous data)")
def bigquery(sql, course, date, limit, confirm, output, full):

    if not full and date == "1970-01-01 00:00:00":
        try:
            date = find_most_recent_job(course, sql)
            print("Incremental update selected with no datetime specified. Selecting "
                  "most recent date: {}".format(date))
        except TimeStampJSONException:
            full = True
            print("Incremental update has no record of previous query. performing full update.")

    long_name = find_course_long_name(course)
    sql_path = os.path.join(os.path.dirname(__file__),
                                "SQL",
                                "{sql}.sql".format(sql=sql))
    query = construct_query(sql_path, long_name, date, limit)

    if not output:
        output = os.path.join(os.path.dirname( __file__ ),
                              "..",
                              "data",
                              course,
                              "{sql}.csv".format(sql=sql))
    timestamp = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
    query_bigquery(query, output, confirm, full)
    perform_timestamp_json_transaction(course, sql, timestamp)


def find_course_long_name(short_name):
    with open("../../.config.json") as config:
        json_config = json.load(config)
        courses = json_config[0]["courses"]
        for course in courses:
            if short_name == course["short_name"]:
                return course["big_table"]
    raise MalformedCourseException("No shortcut found for {course}.".format(course=short_name))


if __name__ == '__main__':
    bigquery()
