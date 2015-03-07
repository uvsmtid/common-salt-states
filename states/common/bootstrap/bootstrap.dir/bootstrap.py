
import os
import os.path

import sys
import imp
import logging

start_path = sys.argv[0]
run_action = sys.argv[1]
run_case = sys.argv[2]
target_env = sys.argv[3]

# Script directory specified on command line.
script_dir = os.path.dirname(start_path)

# Add script dir's `modules` to import path.
sys.path.append(
    os.path.join(
        script_dir,
        'modules',
    )
)

# Import modules related to `bootstrap` after extending
# list of import directories.
import utils.set_log

# Set log level.
utils.set_log.setLoggingLevel('debug')

# Remember run dir:
run_dir = os.getcwd()

# Determine base dir:
if os.path.isabs(script_dir):
    base_dir = script_dir
else:
    base_dir = os.path.join(
        run_dir,
        script_dir,
    )

# Compose path to configuration module.
conf_module_path = os.path.join(
    base_dir,
    'conf',
    target_env + '.py',
)
logging.info('conf_module_path = ' + conf_module_path)

# Load config module.
conf_m = imp.load_source('conf_m', conf_module_path)

# Compose path to platform implementation module.
impl_module_path = os.path.join(
    base_dir,
    'modules',
    'platforms',
    conf_m.target_platform + '.py',
)
logging.info('impl_module_path = ' + impl_module_path)

# Load implementation module.
impl_m = imp.load_source('impl_m', impl_module_path)

# Create instance.
impl_i = impl_m.get_instance(
    run_dir,
    script_dir,
    base_dir,
    conf_m,
    run_action,
    run_case,
    target_env,
)

# Run action.
impl_i.do_action()

