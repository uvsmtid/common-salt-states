#!/usr/bin/env python

"""
Usage: %(script_name)s path/to/salt/output/file

At the moment Salt version `2015.5.0` does not return non-zero error code
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

Differences between the Salt outputs:

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

    This is basically used as solution for all outputs universally.
"""

import os
import re
import sys
import yaml
import types
import logging

###############################################################################
#

# http://stackoverflow.com/a/7795029/441652
def object_stream_splitter(stream):

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

def describe_result(state_id_suspect, result_data):

    overall_result = True

    # Separate visually one result from another.
    logging.info("---")

    logging.info("`id`: " + str(state_id_suspect))

    logging.info("`comment`: " + str(result_data['comment']))
    if 'name' in result_data:
        logging.info("`name`: " + str(result_data['name']))

    result_value = result_data['result']

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

def consolidate_results(state_id_suspect, overall_result, item):

    result = check_objects(state_id_suspect, item)
    if not result['overall_result']:
        overall_result['overall_result'] = False

    overall_result['success_counter'] += result['success_counter']
    overall_result['total_counter'] += result['total_counter']

    logging.debug("overall_result: " + str(overall_result))
    return overall_result

###############################################################################
#

def check_objects(state_id_suspect, output_data):

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
            result = describe_result(state_id_suspect, output_data)
            return result
        else:
            # Key `result` does not exist - it must be complex object.
            for key, value in output_data.items():
                overall_result = consolidate_results(key, overall_result, value)
            return overall_result
    else:
        logging.debug("not list and not dict: " + str(output_data))

    # It must just a field (ignore).
    return overall_result

###############################################################################

def check_result(salt_output):

    """
    Check result provided by Salt for local (see `salt-call`) execution.
    """

    result = check_objects(None, salt_output)

    if result['overall_result']:
        logging.info("SUCCESS: " + str(result['success_counter']) + " of " + str(result['total_counter']))
    else:
        logging.critical("FAILURE: " + str(result['success_counter']) + " of " + str(result['total_counter']))

    return result['overall_result']

###############################################################################
# MAIN

# Execute futher only if this file is executed as a script
# (not imported as a module).
if __name__ == '__main__':

    logging.getLogger().setLevel(0)

    # http://stackoverflow.com/a/15064168/441652
    if len(sys.argv) < 2:
        print __doc__ % { 'script_name' : sys.argv[0].split(os.pathsep)[-1] }
        sys.exit(1)

    file_path = sys.argv[1]

    overall_result = None

    # Instead of using `with` keyword, perform standard `try`/`finally`
    # to support Python 2.5 on RHEL5.
    yaml_file = open(file_path, 'r')
    try:
        salt_output= json_multi_object_loader(yaml_file)
        overall_result = check_result(salt_output)
    finally:
        yaml_file.close()

    if overall_result:
        sys.exit(0)
    else:
        sys.exit(1)
