#!/usr/bin/env python

# The script is designed to be self-contained (in a single file).

"""
Usage:
*   %(script_name)s path/to/salt/output/file # process output file
*   %(script_name)s                          # print usage
*   %(script_name)s test                     # run tests

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

def process_file(file_path):

    # Instead of using `with` keyword, perform standard `try`/`finally`
    # to support Python 2.5 on RHEL5.
    yaml_file = open(file_path, 'r')
    try:
        return process_stream(yaml_file)
    finally:
        yaml_file.close()

###############################################################################
#

def process_string(string):
    stream = cStringIO.StringIO(string)
    try:
        return process_stream(stream)
    finally:
        stream.close()

###############################################################################
#

def process_stream(stream):
    output_data = json_multi_object_loader(stream)
    return check_output_data(output_data)

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

def describe_result(potential_state_id, output_data):

    overall_result = True

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

    result_value = output_data['result']

    if result_value is None:
        logging.critical("unexpected `result` value: " + str(result_value))
        overall_result = False

    elif result_value == False:
        overall_result = False
        # Do not break the loop.
        # Instead, keep on generating log output

    elif result_value == True:
        pass

    else:
        logging.info("unexpected `result` value: " + str(result_value))
        overall_result = False

    if overall_result:
        return {
            'overall_result': True,
            'total_counter': 1,
            'success_counter': 1,
        }
    else:
        return {
            'overall_result': False,
            'total_counter': 1,
            'success_counter': 0,
        }

###############################################################################
#

def consolidate_results(potential_state_id, overall_result, output_data):

    """
    """

    result = traverse_output_data(potential_state_id, output_data)
    if not result['overall_result']:
        overall_result['overall_result'] = False

    overall_result['success_counter'] += result['success_counter']
    overall_result['total_counter'] += result['total_counter']

    logging.debug("overall_result: " + str(potential_state_id) + " = " + str(overall_result))
    return overall_result

###############################################################################
#

def traverse_output_data(potential_state_id, output_data):

    overall_result = {
        'overall_result': True,
        'total_counter': 0,
        'success_counter': 0,
    }

    if (
        isinstance(output_data, list)
        or
        isinstance(output_data, types.GeneratorType)
    ):
        logging.debug("list")
        for item in output_data:
            overall_result = consolidate_results(None, overall_result, item)
        return overall_result

    elif isinstance(output_data, dict):
        logging.debug("dict")
        if 'result' in output_data:
            # Key `result` exists - it must be result of state execution.
            overall_result = describe_result(potential_state_id, output_data)
            return overall_result
        else:
            # Key `result` does not exist - it must be complex object.
            # And every `key` of this complex object is potentially a state id.
            for potential_state_id, value in output_data.items():
                overall_result = consolidate_results(potential_state_id, overall_result, value)
            return overall_result
    else:
        logging.debug("not list and not dict: " + str(output_data))

    # It must just a field (ignore).
    return overall_result

###############################################################################

def check_output_data(output_data):

    """
    Check result provided by Salt for local (see `salt-call`) execution.
    """

    overall_result = traverse_output_data(None, output_data)

    if overall_result['overall_result']:
        logging.info("SUCCESS: " + str(overall_result['success_counter']) + " of " + str(overall_result['total_counter']))
    else:
        logging.critical("FAILURE: " + str(overall_result['success_counter']) + " of " + str(overall_result['total_counter']))

    return overall_result['overall_result']

###############################################################################
#

def main():

    logging.getLogger().setLevel(0)

    # http://stackoverflow.com/a/15064168/441652
    if len(sys.argv) < 2:
        print __doc__ % { 'script_name' : sys.argv[0].split(os.pathsep)[-1] }
        # In addition to usage output, run tests.
        sys.exit(1)
    elif sys.argv[1] == "test":
        run_tests()       
        logging.info("SUCCESS: ALL TESTS PASSED")
        return

    file_path = sys.argv[1]

    overall_result = process_file(file_path)

    if overall_result:
        sys.exit(0)
    else:
        sys.exit(1)

###############################################################################
# TEST

def run_tests():

    # Blank output shall be success.
    assert(
        process_string(
            """

            """
        ) == True
    )

    # Empty object shall be success.
    assert(
        process_string(
            """
{
}
            """
        ) == True
    )

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
            """
        ) == True
    )

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
                "comment": "whenever there is `result`, there must be `comment`"
            }
        ]
    }
}
            """
        ) == False
    )

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

###############################################################################
# MAIN

# Execute further only if this file is executed as a script
# (not imported as a module).
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

