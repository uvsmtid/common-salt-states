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

# TODO: Based on properties:
# * Set `file_roots` in `/etc/salt/master` (or `minion`).
# * Set `pillar_roots` in `/etc/salt/master` (or `minion`).
# * Set `auto_accept` in `/etc/salt/master`.
# * Set `pillar_opts` if it is still actual
#   (properties are supposed to ged rid of the need for `pillar_opts`).

# Make sure `states` symlink points to `states` repository.
assert(os.path.isabs(props['repo_path_states']))
command_args = [
    'ln',
    '-snf',
    os.path.join(
        props['repo_path_states'],
        'states',
    ),
    '/srv/states',
]
call_subprocess(
    command_args,
)

# Make sure `pillars` symlink points to `pillars` repository.
assert(os.path.isabs(props['repo_path_pillars']))
command_args = [
    'ln',
    '-snf',
    os.path.join(
        props['repo_path_pillars'],
        'pillars',
    ),
    '/srv/pillars',
]
call_subprocess(
    command_args,
)

# Make sure `states` contains symlinks to all project states repos.
for project_name in props['projects_states_repo_paths'].keys():
    project_repo_path = props['projects_states_repo_paths'][project_name]
    assert(os.path.isabs(project_repo_path))
    command_args = [
        'ln',
        '-snf',
        os.path.join(
            project_repo_path,
            'states',
            project_name,
        ),
        os.path.join(
            '/srv/states',
            project_name,
        ),
    ]
    call_subprocess(
        command_args,
    )

# Make sure `pillars` contains symlinks to all bootstrap profiles.
# NOTE: It is assumed that single repository contains branches with
#       pillars for all profiles.
profile_names = [ props['profile_name'] ] + props['load_bootstrap_target_envs'].keys()
bootstrap_target_pillars_repo_path = props['repo_path_bootstrap_target_pillars']
assert(os.path.isabs(bootstrap_target_pillars_repo_path))
for profile_name in profile_names:
    command_args = [
        'ln',
        '-snf',
        os.path.join(
            bootstrap_target_pillars_repo_path,
            'pillars',
            'profile',
        ),
        os.path.join(
            '/srv/pillars/bootstrap/profiles',
            profile_name,
        ),
    ]
    call_subprocess(
        command_args,
    )

# Remove old symlinks to `sources` and `resources`.
command_args = [
    'rm',
    '-rf',
    '/srv/sources',
    '/srv/resources',
]
call_subprocess(
    command_args,
)

# Configure symlinks to `sources` and `resources`.
# NOTE: The state are expected to do nothing on hosts with unrelated role.
command_args = [
    'salt-call',
    'state.sls',
    'common.source_symlinks' + ',' + 'common.resource_symlinks',
]
call_subprocess(
    command_args,
)

###############################################################################
# EOF
###############################################################################

