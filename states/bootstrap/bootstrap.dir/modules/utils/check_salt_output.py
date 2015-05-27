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
    The script handles it by removing any line which does not match
    `^[{}\s]`(only indended JSON output gets through).

*   If `highstate` is used with multipe hosts, each of them will generate
    its own JSON object (which breaks parser expectations).

    TODO: Two approaches
    *
    The script handles it by wrapping file's content into another outter
    pair of brackets `[]` (making it an array). In addition to this,
    each objects within the array have to be separated by comma `,`.
    *
    The script handles this by loading one object at a time into
    a list of objects.

*   If `orchestrate` runner is used, the output data structure becomes
    too complex to deal with assumed schema.
    The script simply traverses all objects within the data and processes
    only those which have `result` field (assuming it was state result).

    This is basically used as solution for all outputs universally.
"""

import os
import re
import sys
import yaml
import logging

###############################################################################

def load_yaml_file_data(file_path):

    """
    Load YAML formated data from file_path.
    """

    # Instead of using `with` keyword, perform standard `try`/`finally`
    # to support Python 2.5 on RHEL5.
    yaml_file = open(file_path, 'r')
    try:
        loaded_data = yaml.load(yaml_file)
    finally:
        yaml_file.close()

    return loaded_data

###############################################################################

def load_yaml_string_data(text_content):

    """
    Load YAML formated data from string.
    """

    loaded_data = yaml.load(text_content)

    return loaded_data

###############################################################################

def check_result(salt_output):

    """
    Check result provided by Salt for local (see `salt-call`) execution.
    """

    local_result = salt_output['local']

    overall_result = True
    success_counter = 0
    total_counter = 0
    for state_key in local_result.keys():

        # Separate visually one result from another.
        logging.info("---")

        total_counter = total_counter + 1

        logging.info("`comment`: " + str(local_result[state_key]['comment']))
        if 'name' in local_result[state_key]:
            logging.info("`name`: " + str(local_result[state_key]['name']))

        result_value = local_result[state_key]['result']

        if result_value is None:
            logging.critical("unexpected `result` value: " + str(result_value))
            overall_result = False

        elif result_value == False:
            logging.info("result: " + str(result_value))
            overall_result = False
            # Do not break the loop.
            # Instead, keep on generating log output

        elif result_value == True:
            success_counter = success_counter + 1
            logging.info("result: " + str(result_value))

        else:
            logging.info("unexpected `result` value: " + str(result_value))
            overall_result = False

    if overall_result:
        logging.info("SUCCESS: " + str(success_counter) + " of " + str(total_counter))
    else:
        logging.critical("FAILURE: " + str(success_counter) + " of " + str(total_counter))

    return overall_result

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

    salt_output = load_yaml_file_data(file_path)

    overall_result = check_result(salt_output)

    if overall_result:
        sys.exit(0)
    else:
        sys.exit(1)

