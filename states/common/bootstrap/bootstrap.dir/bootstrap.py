#!/usr/bin/env python

# See: http://stackoverflow.com/a/14981125/441652
from __future__ import print_function

import os
import os.path

import sys
import imp
import logging

# Required arguments:
# * Automatic argument - path to script as appeared in the command line.
start_path = sys.argv[0]
# * Action to run (i.e. `build`, `deploy`, etc.).
run_action = sys.argv[1]
# * Use case for action (i.e. `offline-minion-installer`).
run_use_case = sys.argv[2]
# * Target environment - path to configuration file as:
#   ```
#   path/to/conf/project_name/system_profile_name/host_id.py`
#   ```
target_env_conf = sys.argv[3]
# * The last argument is optional (used for convenience of development) -
#   path to `bootstrap.dir` with generated content (to keep this content
#   outside of source directory).
#   For production environment, `base_dir` specifies root directory for
#   everything: script sources, configuration, resources, etc.
content_dir = None
if len(sys.argv) > 4:
    content_dir = sys.argv[4]
print("debug: initial content_dir = " + str(content_dir), file=sys.stderr)

# Path to script is _always_ derived from command line.
# NOTE: In other words, script is not accessible from PATH env var.
script_dir = os.path.dirname(start_path)
print("debug: script_dir = " + str(script_dir), file=sys.stderr)

# Remember `run_dir`:
run_dir = os.getcwd()
print("debug: run_dir = " + str(run_dir), file=sys.stderr)

# Redefine `content_dir` as absolute path.
if content_dir:
    if not os.path.isabs(content_dir):
        content_dir = os.path.join(
            run_dir,
            content_dir,
        )
print("debug: finalized content_dir = " + str(content_dir), file=sys.stderr)

# Determine `base_dir`.
# Variable `base_dir`is _always_ derived from command line.
if os.path.isabs(script_dir):
    base_dir = script_dir
else:
    base_dir = os.path.join(
        run_dir,
        script_dir,
    )

# Debug before logging ready.
print("debug: initial base_dir = " + str(base_dir), file=sys.stderr)

# If `content_dir` is specified, `base_dir` is overwritten but only _after_
# paths to modules has already been set through `base_dir`.
modules_dir = os.path.join(
    base_dir,
    'modules',
)
print("debug: modules_dir = " + str(modules_dir), file=sys.stderr)

# Add `modules` to import path.
sys.path.append(
    modules_dir,
)

# Redefine `base_dir` if `content_dir` is specifed.
if content_dir:
    base_dir = content_dir
    print("IMPORTANT: REDEFINED base_dir = " + str(base_dir), file=sys.stderr)

# Import modules related to `bootstrap` after extending
# list of import directories.
import utils.set_log

# Set log level.
utils.set_log.setLoggingLevel('debug')

# Compose path to configuration module.
conf_module_path = os.path.join(
    base_dir,
    target_env_conf,
)
logging.info('conf_module_path = ' + conf_module_path)

# Load config module.
conf_m = imp.load_source('conf_m', conf_module_path)

# Compose path to platform implementation module.
impl_module_path = os.path.join(
    modules_dir,
    'platforms',
    conf_m.target_platform + '.py',
)
logging.info('impl_module_path = ' + impl_module_path)

# Load implementation module.
impl_m = imp.load_source('impl_m', impl_module_path)
logging.debug('impl_m = ' + str(impl_m))

# Create instance.
impl_i = impl_m.get_instance(
    run_dir,
    script_dir,
    base_dir,
    modules_dir,
    conf_m,
    run_action,
    run_use_case,
    target_env_conf,
)

# Run action.
impl_i.do_action()

