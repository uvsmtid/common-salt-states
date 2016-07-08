#!/usr/bin/env python

# The script is designed to be self-contained (in a single file).

"""
Usage:

*   process output file
        %(script_name)s path/to/salt/output/file [min_count]
        *   min_count - minimum expected total count (default: 1)
*   print usage
        %(script_name)s

*   run tests
        %(script_name)s test

At the moment Salt (version `2015.5.0`) does not return non-zero error code
consistently and this requies verification of result by parsing its output.

This script:
*   reads file with JSON output of Salt (use `--out json`);
*   returns non-zero error code if any of the Salt state fails;
*   supports various output data structures:
    *   `highstate` output produced by single host (i.e. using `salt-call ...`);
    *   `highstate` output produced by multiple hosts (i.e. using `salt '*' ...`);
    *   `orchestrate` runner's output (`salt state.orchestrate ...`).

Why JSON (and not default YAML)?

In fact, YAML parser is used to load JSON files (JSON is sub-syntax of YAML).
However, it appears that generated YAML format by Salt fails during parsing
on some platforms (JSON is has simpler syntax and more stable).

Issues with Salt output and solutions:

*   If you use Salt minion config options like `show_jid`, it will corrupt
    stdout injecting job id into JSON output.

    The script handles it by filtering out any line which is out of
    object data (first char is either braces or space in indended JSON output).

*   If `highstate` is used with multipe hosts, each of them will generate
    its own JSON object (which breaks parser expectations).

    The script handles this by loading one object at a time into
    a list of objects.

*   If `orchestrate` runner is used, the output data structure becomes
    rather complex to deal with assumed schema.

    The script simply traverses all objects within the data and processes
    only those which have `result` field (assuming it was state result).

    Basically, this is used as universal solution for all types of output.
"""

import re
import os
import sys
import yaml
import types
import logging
import cStringIO

###############################################################################
#

# This is what all states failed due to failed requisites have
# in their `comment` string.
requisite_failure_prefix = "One or more requisite failed:"

# Global statistics per script run.
# Currently it is used to show ordered list of execution time per state.
g_stats = []

###############################################################################
#

def process_file(
    file_path,
    min_count = 1,
):

    """
    Wrap processing to use file path to data as input.
    """

    # Instead of using `with` keyword, perform standard `try`/`finally`
    # to support Python 2.5 on RHEL5.
    yaml_file = open(file_path, 'r')
    try:
        return process_stream(yaml_file, min_count)
    finally:
        yaml_file.close()

###############################################################################
#

def process_string(
    string,
    min_count = 1,
):

    """
    Wrap processing to use string data as input.

    This function is normally used for test purposes
    (real output is normally provided via file - see `process_file`).
    """

    stream = cStringIO.StringIO(string)
    try:
        return process_stream(stream, min_count)
    finally:
        stream.close()

###############################################################################
#

def process_stream(
    stream,
    min_count = 1,
):

    """
    Process input stream treating it as JSON and pass for analysis.
    """

    output_data = json_multi_object_loader(stream)
    return check_output_data(output_data, min_count)

###############################################################################
#

def object_stream_splitter(stream):

    """
    Return a list with all lines for single JSON object.
    """

    # Patterns for beginning/end of new object.
    b_regex = re.compile('^[{]')
    e_regex = re.compile('^[}]')

    is_in_object = False

    # Loop through each line returning set of lines parsable as single object.
    object_lines = []
    for line in stream:
        if is_in_object:

            # Add lines continuously while in object.
            object_lines.append(line)

            # Look for end.
            if re.search(e_regex, line):
                is_in_object = False
                return object_lines
        else:
            # Look for beginning.
            if re.search(b_regex, line):
                is_in_object = True
                object_lines.append(line)

    # We haven't reached a natural return.
    # The lines do not have end or there is no object beginning.
    # Regardless of the reason, let parser decide what lines really are.
    return object_lines

###############################################################################
#

def json_multi_object_loader(stream):

    """
    Load invalid JSON containing many objects as list of them.
    """

    output_objects = []

    while True:
        object_lines = object_stream_splitter(stream)
        object_string = '\n'.join(object_lines)
        if object_string:
            output_object = yaml.load(object_string)
            output_objects.append(output_object)
        else:
            break

    return output_objects

###############################################################################
#

def describe_result(potential_state_id, output_data):

    global g_stats

    overall_result = True
    duration = None

    independent_failures = 0

    # Separate visually one result from another.
    logging.info("---")

    logging.info("`id`: " + str(potential_state_id))

    if 'comment' in output_data:
        logging.info("`comment`: " + str(output_data['comment']))
    else:
        logging.critical("missing expected `comment` field")
        overall_result = False

    if 'name' in output_data:
        logging.info("`name`: " + str(output_data['name']))

    if 'duration' in output_data:
        # NOTE: Convert duration from floating point to integer
        #       and print with leading zeroes.
        duration = int(output_data['duration'])
        logging.info("`duration`: " + str(duration).zfill(8))
    else:
        logging.warn("Field `duration` is absent")
        duration = -1

    # Add state id and duration into the list.
    g_stats.append((duration, potential_state_id))

    # Print result at the bottom of other state id data.
    result_value = output_data['result']
    logging.info("`result`: " + str(result_value))

    # Analyse different flavours of `result_value`.
    if result_value is None:
        logging.critical("unexpected `result` value: " + str(result_value))
        overall_result = False

    elif result_value == False:
        overall_result = False

        if not output_data['comment'].startswith(requisite_failure_prefix):
            logging.error("`independent_failure`: " + str(True))
            independent_failures += 1

    elif result_value == True:
        pass

    else:
        logging.info("unexpected `result` value: " + str(result_value))
        overall_result = False

    # Return object for accumulation.
    if overall_result:
        return {
            'overall_result': True,
            'total_counter': 1,
            'success_counter': 1,
            'independent_failures': independent_failures,
        }
    else:
        return {
            'overall_result': False,
            'total_counter': 1,
            'success_counter': 0,
            'independent_failures': independent_failures,
        }

###############################################################################
#

def consolidate_results(potential_state_id, overall_result, output_data):

    """
    Aggregate lower-level result counters in a higher-level accumulator object.
    """

    result = traverse_output_data(potential_state_id, output_data)
    if not result['overall_result']:
        overall_result['overall_result'] = False

    overall_result['success_counter'] += result['success_counter']
    overall_result['total_counter'] += result['total_counter']
    overall_result['independent_failures'] += result['independent_failures']

    logging.debug("overall_result: " + str(potential_state_id) + " = " + str(overall_result))
    return overall_result

###############################################################################
#

def traverse_output_data(potential_state_id, output_data):

    """
    Analyse current data node (as JSON object) whether it is state result.

    To recognize whether it is state result or not,
    key `result` is searched for.
    """

    overall_result = {
        'overall_result': True,
        'total_counter': 0,
        'success_counter': 0,
        'independent_failures': 0,
    }

    if (
        isinstance(output_data, list)
        or
        isinstance(output_data, types.GeneratorType)
    ):
        logging.debug("list")
        for item in output_data:
            # NOTE: Indirect recursive call.
            overall_result = consolidate_results(None, overall_result, item)
        return overall_result

    elif isinstance(output_data, dict):
        logging.debug("dict")
        if 'result' in output_data:
            # Key `result` exists - it must be result of state execution.
            # Generate analysis logs and determine
            # wither it was a failed state or not.
            overall_result = describe_result(potential_state_id, output_data)
            return overall_result
        else:
            # Key `result` does not exist - it must be complex object.
            # And every `key` of this complex object is potentially a state id.
            for potential_state_id, value in output_data.items():
                # NOTE: Indirect recursive call.
                overall_result = consolidate_results(potential_state_id, overall_result, value)
            return overall_result
    else:
        logging.debug("not list and not dict: " + str(output_data))

    # It must be just a field (ignore).
    return overall_result

###############################################################################
#

def check_output_data(
    output_data,
    min_count = 1,
):

    """
    Check result provided by Salt output.
    """

    global g_stats

    overall_result = traverse_output_data(None, output_data)

    # Print state ids sorted by duration time.
    # http://stackoverflow.com/a/3121985/441652
    sorted_by_duration = sorted(
        g_stats,
        key=lambda tup: tup[0],
        reverse=True,
    )
    logging.info("sorted_by_duration ----------------------------------------")
    for sorted_item in sorted_by_duration:
        logging.info("sorted_by_duration: " + str(sorted_item))
    logging.info("sorted_by_duration ----------------------------------------")

    # Check minimal required total count.
    if overall_result['total_counter'] < min_count:
        logging.critical("FAILURE: " + str(overall_result['total_counter']) + " is less than `min_count` = " + str(min_count))
        overall_result['overall_result'] = False
    else:
        logging.info(str("`total_counter` = " + str(overall_result['total_counter'])) + " satisfies `min_count` = " + str(min_count))

    # Notify about overall result.
    if overall_result['overall_result']:
        logging.info("SUCCESS: " + str(overall_result['success_counter']) + " of " + str(overall_result['total_counter']))
    else:
        logging.critical("FAILURE: " + str(overall_result['success_counter']) + " of " + str(overall_result['total_counter']))

    return overall_result['overall_result']

###############################################################################
# MAIN

def main():

    logging.getLogger().setLevel(0)

    if len(sys.argv) < 2:
        # Print Python file's docstring as usage help.
        # http://stackoverflow.com/a/15064168/441652
        print __doc__ % { 'script_name' : sys.argv[0].split(os.pathsep)[-1] }
        # In addition to usage output, run tests.
        sys.exit(1)
    elif sys.argv[1] == "test":
        # Run tests if only signle `test` argument is provided.
        # NOTE: Yes, if file to be processed is named `test`,
        #       it will be ignored.
        run_tests()
        logging.info("SUCCESS: ALL TESTS PASSED")
        return

    file_path = sys.argv[1]

    min_count = 1
    if len(sys.argv) > 2:
        min_count = int(sys.argv[2])

    overall_result = process_file(file_path, min_count)

    if overall_result:
        sys.exit(0)
    else:
        sys.exit(1)

###############################################################################
# TEST

def run_tests():

    global g_stats

    #--------------------------------------------------------------------------
    # Blank output shall be success.
    assert(
        process_string(
            """

            """,
            0,
        ) == True
    )

    #--------------------------------------------------------------------------
    # Empty object shall be success.
    assert(
        process_string(
            """
{
}
            """,
            0,
        ) == True
    )

    #--------------------------------------------------------------------------
    # Minimal couter shall trigger error without results.
    assert(
        process_string(
            """
{
}
            """,
            0,
        ) == True
    )

    #--------------------------------------------------------------------------
    # Any additional characters between objects shall be ignored (success).
    assert(
        process_string(
            """
whatever
{
}
asdfghjkl
{
}
            This line is also ignored.
            """,
            0,
        ) == True
    )

    #--------------------------------------------------------------------------
    # Schema of any structural depth is acceptable with some
    # expectations about objects which describe result of the state.
    assert(
        process_string(
            """
{
    "field_dict": {
        "field_list": [
            'q'
            ,
            "something_like_state_id": {
                "result": true
                ,
                "comment": "whenever there is `result`, there must be `comment`"
            }
        ]
        ,
        "field_value": 5
    }
}
            """
        ) == True
    )
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 1)

    #--------------------------------------------------------------------------
    # Any `"result": false` makes overall result False.
    assert(
        process_string(
            """
{
    "field_dict": {
        "field_list": [
            "something_like_state_id": {
                "result": false
                ,
                "duration": 100.1
                ,
                "comment": "whenever there is `result`, there must be `comment`"
            }
        ]
    }
}
            """
        ) == False
    )
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 2)

    #--------------------------------------------------------------------------
    # Any missing `comment` field makes overal result False.
    # The point to fail is absense of valuable description what went wrong.
    # Salt may not have `name` output in some cases (not sure, probably when
    # state was not executed for some reasons), but it always describe
    # what was going on in `comment` field. Let's require it then until
    # it breaks in the future.
    assert(
        process_string(
            """
{
    "field_dict": {
        "field_list": [
            "something_like_state_id": {
                "result": true
            }
        ]
    }
}
            """
        ) == False
    )
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 3)

    #--------------------------------------------------------------------------
    # If many requisite states fail, the output is very noizy (having
    # many failed results) while the requisite state which caused
    # these failures has to be found manually. In order to highlight
    # such state, `failed_state` field is added to the final output.
    # All states with failed requisites have similar signature -
    # their `comment` starts with string saved in `requisite_failure_prefix`.
    #
    # * Case A: one independent and one dependent failures.
    case_result = traverse_output_data(
        None
        ,
        yaml.load(
"""
{
    "dependent_1": {
        "result": false
        ,
        "comment": """ + '"' + requisite_failure_prefix + """ whatever the 1st reason is"
    }
    ,
    "independent_2": {
        "result": false
        ,
        "duration": 150
        ,
        "comment": "whatever the 2nd reason is"
    }
}
"""
        )
    )
    logging.debug(str(case_result))
    assert(case_result['independent_failures'] == 1)
    assert(case_result['overall_result'] == False)
    assert(case_result['total_counter'] == 2)
    assert(case_result['success_counter'] == 0)
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 5)
    #
    # * Case B: two dependent failures.
    case_result = traverse_output_data(
        None
        ,
        yaml.load(
"""
{
    "dependent_1": {
        "result": false
        ,
        "comment": """ + '"' + requisite_failure_prefix + """ whatever the 1st reason is"
    }
    ,
    "dependent_2": {
        "result": false
        ,
        "comment": """ + '"' + requisite_failure_prefix + """ whatever the 2nd reason is"
    }
}
"""
        )
    )
    logging.debug(str(case_result))
    assert(case_result['independent_failures'] == 0)
    assert(case_result['overall_result'] == False)
    assert(case_result['total_counter'] == 2)
    assert(case_result['success_counter'] == 0)
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 7)
    #
    # * Case C: two independent failures.
    case_result = traverse_output_data(
        None
        ,
        yaml.load(
"""
{
    "independent_1": {
        "result": false
        ,
        "comment": "whatever the 1st reason is"
    }
    ,
    "independent_2": {
        "result": false
        ,
        "comment": "whatever the 2nd reason is"
    }
}
"""
        )
    )
    logging.debug(str(case_result))
    assert(case_result['independent_failures'] == 2)
    assert(case_result['overall_result'] == False)
    assert(case_result['total_counter'] == 2)
    assert(case_result['success_counter'] == 0)
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 9)
    #
    # * Case D: no actual failure (only comments look like failure).
    case_result = traverse_output_data(
        None
        ,
        yaml.load(
"""
{
    "success_1": {
        "result": true
        ,
        "comment": """ + '"' + requisite_failure_prefix + """ whatever the 1st reason is"
    }
    ,
    "success_2": {
        "result": true
        ,
        "comment": """ + '"' + requisite_failure_prefix + """ whatever the 2nd reason is"
    }
}
"""
        )
    )
    logging.debug(str(case_result))
    assert(case_result['independent_failures'] == 0)
    assert(case_result['overall_result'] == True)
    assert(case_result['total_counter'] == 2)
    assert(case_result['success_counter'] == 2)
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 11)

    #--------------------------------------------------------------------------
    # Just one more test to print final sorted duration list.
    assert(
        process_string(
            """
{
    "field_dict": {
        "field_list": [
            "something_like_state_id": {
                "result": false
                ,
                "duration": 100.01
                ,
                "comment": "whatever"
            }
        ]
    }
}
            """
        ) == False
    )
    # Also, make sure number of objects in the `g_stats`.
    assert(len(g_stats) == 12)


###############################################################################
# MAIN

# Execute further only if this file is executed as a script
# (not imported as a module).
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

