#!/usr/bin/env python

# This script generates CSV table - a join of:
# * `system_hosts`
# * `system_host_roles`
# * `system_network`

import os
import csv
import sys
import yaml
import datetime
import logging

################################################################################
# Import non-standard modules.

# Determine path for additional modules to import.
start_path = sys.argv[0]
script_dir = os.path.dirname(start_path)
run_dir = os.getcwd()
if os.path.isabs(script_dir):
    modules_dir = os.path.join(
        script_dir,
        'modules',
    )
else:
    modules_dir = os.path.join(
        run_dir,
        script_dir,
        'modules',
    )
sys.path.append(
    modules_dir,
)

import utils.set_log
from utils.exec_command import call_subprocess

################################################################################
#

def join_data():
    pass

################################################################################
#

def load_pillars():

    # Run Salt's `pillar.items` and captrue its output.
    command_args = [
        'sudo',
        'salt-call',
        '--out=yaml',
        'pillar.items',
    ]
    process_output = call_subprocess(
        command_args,
        capture_stdout = True,
    )

    # Parse profile pillars content.
    salt_output = process_output['stdout']
    pillars = yaml.load(salt_output)

    # Return profile pillars loaded in memory.
    return pillars['local']

################################################################################
#

def write_data():
    pass

    # Open CSV output file.
    result_csv_file = open('result.csv', "w")
    result_writer = csv.writer(result_csv_file, delimiter=',', quotechar='"')

    # List of tab names to generate reporting data for.
    # Currently, only two tabs can be handled by generating functions.
    tab_list = [
    ]

    # Order in which rows are sorted in result output.
    # This is supposed to be a static data (seldom updated).
    rows_order = [
    ]

    # Write header.
    header = [ "tab" ] + [ "row" ] + map(str, months_list)
    logging.info("header = " + str(header))
    result_writer.writerow (
        [ "tab" ] + [ "row" ] + map(str, months_list)
    )


    # Generate table.
    for tab_name in tab_list:
        for row_name in rows_order:
            if row_name not in rows_per_tab_config[tab_name].keys():
                logging.debug("row is not part of tab configuration tab / row: " + str(tab_name) + " / " + str(row_name))
                continue

            column_values = [ tab_name, row_name ]

            row_config = rows_per_tab_config[tab_name][row_name]

            result_writer.writerow(column_values)

################################################################################
#

def print_yaml(data):

    yaml.dump(
        data,
        sys.stdout,
        default_flow_style = False,
        indent = 4,
    )

################################################################################
#

def main():

    # Set log level.
    utils.set_log.setLoggingLevel('debug')

    pillars = load_pillars()

    print_yaml(pillars)

###############################################################################
# MAIN

# Execute further only if this file is executed as a script
# (not imported as a module).
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

