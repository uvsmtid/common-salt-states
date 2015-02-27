
import os
import os.path

import sys
import imp

start_path = sys.argv[0]
run_action = sys.argv[1]
run_case = sys.argv[2]
target_env = sys.argv[3]

# Script's base directory.
base_dir = os.path.dirname(start_path)

# Add base_dir to import path.
sys.path.append(
    os.path.join(
        base_dir,
        'modules',
    )
)

# Compose path to configuration module.
conf_module_path = os.path.join(
    base_dir,
    'conf',
    target_env + '.py',
)
print 'conf_module_path = ' + conf_module_path

# Load config module.
conf_m = imp.load_source('conf_m', conf_module_path)

# Compose path to platform implementation module.
impl_module_path = os.path.join(
    base_dir,
    'modules',
    'platforms',
    conf_m.target_platform + '.py',
)
print 'impl_module_path = ' + impl_module_path

# Load implementation module.
impl_m = imp.load_source('impl_m', impl_module_path)

# Create instance.
impl_i = impl_m.get_instance(
    conf_m,
    run_action,
    run_case,
    target_env,
)

# Run action.
impl_i.do_action()

