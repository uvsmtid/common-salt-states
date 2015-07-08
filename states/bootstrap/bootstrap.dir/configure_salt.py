#!/usr/bin/env python
# See: TODO: docs

import os
import sys
import imp
import yaml
import logging

# Required arguments:
# * Automatic argument - path to script as appeared in the command line.
start_path = sys.argv[0]
# * Path to pillars profile properties file.
properties_file_path = sys.argv[1]
# * The last argument is optional (used for convenience of development) -
#   path to `bootstrap.dir` with generated content (to keep this content
#   outside of source directory).
#   For "production" environment, `content_dir` is usually the same
#   with `modules_dir` and contains everything:
#   script sources, configuration, resources, etc.
content_dir = None
if len(sys.argv) > 4:
    content_dir = sys.argv[4]
sys.stderr.write("debug: initial content_dir = " + str(content_dir) + "\n") # before log level is set

# Path to script is _always_ derived from command line.
# NOTE: In other words, script is not accessible from PATH env var.
script_dir = os.path.dirname(start_path)
sys.stderr.write("debug: script_dir = " + str(script_dir) + "\n") # before log level is set

# Remember `run_dir`:
run_dir = os.getcwd()
sys.stderr.write("debug: run_dir = " + str(run_dir) + "\n") # before log level is set

# Redefine `content_dir` as absolute path.
if content_dir:
    if not os.path.isabs(content_dir):
        content_dir = os.path.join(
            run_dir,
            content_dir,
        )
else:
    if os.path.isabs(script_dir):
        content_dir =  os.path.join(
            script_dir,
        )
    else:
        content_dir = os.path.join(
            run_dir,
            script_dir,
        )
sys.stderr.write("debug: finalized content_dir = " + str(content_dir) + "\n") # before log level is set

# Determine `modules_dir`.
# Variable `modules_dir`is _always_ derived from command line.
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
sys.stderr.write("debug: modules_dir = " + str(modules_dir) + "\n") # before log level is set

# Add `modules` to import path.
sys.path.append(
    modules_dir,
)

###############################################################################

# Import modules related to `bootstrap` after extending
# list of import directories.
import utils.set_log
from utils.exec_command import call_subprocess

# Set log level.
utils.set_log.setLoggingLevel('debug')

logging.info('properties_file_path = ' + properties_file_path)

# Load properties.
props_file = None
props = None
try:
    props_file = open(properties_file_path, 'r')
except:
    try:
        props_file.close()
    except:
        pass
    raise
try:
    props = yaml.load(props_file)
finally:
    props_file.close()

# Make sure `states` symlink points to `states` repository.
command_args = [
    'ln',
    '-snf',
    os.path.join(
        props['key_repo_paths']['states'],
        'states',
    ),
    '/srv/states',
]
call_subprocess(
    command_args,
)

# Make sure `pillars` symlink points to `pillars` repository.
command_args = [
    'ln',
    '-snf',
    os.path.join(
        props['key_repo_paths']['pillars'],
        'pillars',
    ),
    '/srv/pillars',
]
call_subprocess(
    command_args,
)

