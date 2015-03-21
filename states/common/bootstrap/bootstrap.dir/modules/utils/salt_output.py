#!/usr/bin/env python

#

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
    for state_key in local_result.keys():

        name_value = local_result[state_key]['name']
        result_value = local_result[state_key]['result']
        logging.info("check result for `name`: " + str(name_value))

        if result_value is None:
            logging.critical("unexpected `result` value: " + str(result_value))
            overall_result = False

        elif result_value == False:
            logging.info("result: " + str(result_value))
            overall_result = False
            # Do not break the loop.
            # Instead, keep on generating log output

        elif result_value == True:
            logging.info("result: " + str(result_value))

        else:
            logging.info("unexpected `result` value: " + str(result_value))
            overall_result = False

    return overall_result

###############################################################################
# MAIN

# Execute futher only if this file is executed as a script (not imported
# as a module).
if __name__ == '__main__':

    logging.getLogger().setLevel(0)

    file_path = sys.argv[1]

    salt_output = load_yaml_file_data(file_path)

    overall_result = check_result(salt_output)

    if overall_result:
        sys.exit(0)
    else:
        sys.exit(1)

