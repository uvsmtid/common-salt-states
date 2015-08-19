#!/usr/bin/env python

# This script automatically configures Salt master or minion to be used
# with `common-salt-states` repository.
# See: TODO: docs
#
# Key points (differences from bootstrap):
# * Configure Salt master only (no standalone masterless minions).
# * Salt master is supposed to be already installed.
# * Host with Salt master is supposed to be installed with Salt minion too.

import os
import sys
import imp
import yaml
import logging

salt_master_conf_path = '/etc/salt/master'

def main():

    ###########################################################################
    # Get input arguments and context.

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
    # Before log level is set:
    sys.stderr.write("debug: initial content_dir = " + str(content_dir) + "\n")

    # Path to script is _always_ derived from command line.
    # NOTE: In other words, script is not accessible from PATH env var.
    script_dir = os.path.dirname(start_path)
    # Before log level is set:
    sys.stderr.write("debug: script_dir = " + str(script_dir) + "\n")

    # Remember `run_dir`:
    run_dir = os.getcwd()
    # Before log level is set:
    sys.stderr.write("debug: run_dir = " + str(run_dir) + "\n")

    ###########################################################################
    # Init modules.

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
    # Before log level is set:
    sys.stderr.write("debug: finalized content_dir = " + str(content_dir) + "\n")

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
    # Before log level is set:
    sys.stderr.write("debug: modules_dir = " + str(modules_dir) + "\n")

    # Add `modules` to import path.
    sys.path.append(
        modules_dir,
    )

    # Import modules related to `bootstrap` after extending
    # list of import directories.
    import utils.set_log
    from utils.exec_command import call_subprocess

    # Set log level.
    utils.set_log.setLoggingLevel('debug')

    ###########################################################################
    # Load properties file.

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

    ###########################################################################
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

    ###########################################################################
    # Create aliases symlinks which map non-existing paths to existing ones.

    for symlink_name in props['symlinks_map'].keys():
        symlink_target = props['symlinks_map'][symlink_name]
        assert(symlink_name)
        assert(symlink_target)
        command_args = [
            'ln',
            '-snf',
            symlink_target,
            symlink_name,
        ]
        call_subprocess(
            command_args,
        )

    ###########################################################################
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

    ###########################################################################
    # Make sure `pillars` symlink points to `pillars` repository.

    # Note that in case of generic profile instead of `repo_path_pillars`
    # `states` repo of the project is used instead.
    repo_path_pillars = props['repo_path_pillars']
    if props['is_generic_profile']:
        if props['project_name'] != 'common':
            repo_path_pillars = props['projects_states_repo_paths'][props['project_name']]
        else:
            # common
            repo_path_pillars = props['repo_path_states']

    assert(repo_path_pillars)
    command_args = [
        'ln',
        '-snf',
        os.path.join(
            repo_path_pillars,
            'pillars',
        ),
        '/srv/pillars',
    ]
    call_subprocess(
        command_args,
    )

    ###########################################################################
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

    ###########################################################################
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

    ###########################################################################
    # Make sure `main.sls` is a symlink to `main.sls`
    # under `states` directory of required project.

    command_args = [
        'ln',
        '-snf',
        os.path.join(
            props['project_name'],
            'main.sls',
        ),
        '/srv/states/main.sls',
    ]
    call_subprocess(
        command_args,
    )

    ###########################################################################
    # Modify Salt configuration file.

    from utils.hosts_file import do_backup

    # - Create backup of configuration file.
    do_backup(
        salt_master_conf_path,
        dst_dir_path = os.path.dirname(salt_master_conf_path),
    )

    # - Load configuration file.
    salt_master_conf = None
    salt_master_conf_stream = None
    try:
        salt_master_conf_stream = open(salt_master_conf_path, 'r')
        salt_master_conf = yaml.load(salt_master_conf_stream)
    finally:
        salt_master_conf_stream.close()

    # If file is empty (or only with comments), parser will give None.
    # Change it to dict.
    if salt_master_conf is None:
        salt_master_conf = {}

    # Create necessary keys, if not available.
    if 'file_roots' not in salt_master_conf:
        salt_master_conf['file_roots'] = {}
    if 'pillar_roots' not in salt_master_conf:
        salt_master_conf['pillar_roots'] = {}

    # - Set `file_roots`.
    salt_master_conf['file_roots']['base'] = [
        '/srv/states',
        '/srv/sources',
        '/srv/resources',
    ]

    # - Set `pillar_roots`.
    salt_master_conf['pillar_roots']['base'] = [
        '/srv/pillars',
    ]

    # - Set additional configuration.
    salt_master_conf['auto_accept'] = True
    salt_master_conf['log_level'] = 'debug'
    salt_master_conf['log_level_logfile'] = 'debug'
    # NOTE: Properties are supposed to ged rid of the need for `pillar_opts`.
    salt_master_conf['pillar_opts'] = True
    salt_master_conf['show_jid'] = True
    salt_master_conf['show_timeout'] = True
    salt_master_conf['timeout'] = 30

    # - Save configuration.
    try:
        salt_master_conf_stream = open(salt_master_conf_path, 'w')
        yaml.dump(
            salt_master_conf,
            salt_master_conf_stream,
            default_flow_style = False,
            indent = 4,
        )
    finally:
        salt_master_conf_stream.close()

    ###########################################################################
    # Remove all minion keys.

    command_args = [
        'salt-key',
        '-y',
        '--delete-all',
    ]
    call_subprocess(
        command_args,
    )

    ###########################################################################
    # Restart both Salt master and Salt minion.

    # NOTE: Use `rhel5` implementation as it works for `systemd`-based too.
    from steps.deploy.activate_salt_master.rhel5 import ensure_salt_master_activation

    ensure_salt_master_activation('salt-master')

    ###########################################################################
    # Run initial configuration for Salt master.

    # Because we only care about Salt master and master can only be Linux.
    from steps.deploy.run_init_states.generic_linux import run_states

    state_names = [
        'common.source_symlinks',
        'common.resource_symlinks',
    ]

    run_states(
        state_names = state_names,
        salt_extra_args = [],
        cmd_extra_args = [],
    )

    ###########################################################################
    # NOTE: There is no code to add minion keys because
    #       it is considered that status of the minion is beyond control
    #       at the moment. Conventionally, this list should match the list
    #       defined in `enabled_minion_hosts` property.

###############################################################################
#
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

