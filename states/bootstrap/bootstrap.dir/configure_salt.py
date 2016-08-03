#!/usr/bin/env python

# This script automatically configures Salt master
# to be used with `common-salt-states` repository.
#
# It takes profile properties file from pillars which define the system
# to configure (installed) Salt master automatically.
#
# See: TODO: docs
#
# Key points (differences from bootstrap):
# * Configure Salt master only (no standalone masterless minions).
# * Salt master is supposed to be already installed.
# * All repositories are expected in paths provided directly by
#   pillars (instead of paths into bootstrap package).
# * Host with Salt master is supposed to be installed and configured
#   with Salt minion too.
#   TODO: Implement Salt minion configuration in this script as well.
#         Actually, this is a corner case because when Salt master
#         is installed, it can generate bootstrap packages for their
#         minions so that can be installed and configured automatically.

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
    # Configure links for `states` and `pillars` repositories.

    from steps.deploy.link_sources.generic_linux import set_salt_states_and_pillars_symlinks

    # TODO: Make function args correspond keys from properties
    #       so that the same entities are searched by the same key.
    set_salt_states_and_pillars_symlinks(
        # TODO: Use better value for use case than None.
        #       At the moment `run_use_case` is expected to specify
        #       bootstrap use case or None for this script.
        #       However, how isn't it a use case as well (more meaningful
        #       than None)?
        run_use_case = None,
        states_repo_abs_path = props['repo_path_states'],
        overrides_pillars_repo_abs_path = props['repo_path_pillars'],
        projects_states_repo_abs_paths = props['projects_states_repo_paths'],
        overrides_bootstrap_target_pillars_repo_abs_path = props['repo_path_bootstrap_target_pillars'],
        project_name = props['project_name'],
        profile_name = props['profile_name'],
    )

    ###########################################################################
    # Modify Salt configuration file.
    # TODO: Make it common function with bootstrap.
    #       Perhaps, it is even possible to run Jinja template engine
    #       on current configuration template providing necessary
    #       context variables like `pillar`.

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
        '/srv/pillars/overrides',
        '/srv/pillars/defaults',
        '/srv/pillars/commons',
    ]

    # - Set additional configuration.
    salt_master_conf['auto_accept'] = True
    salt_master_conf['log_level'] = 'debug'
    salt_master_conf['log_level_logfile'] = 'debug'
    # NOTE: Properties are supposed to ged rid of the need for `pillar_opts`.
    salt_master_conf['pillar_opts'] = True
    salt_master_conf['show_jid'] = True
    salt_master_conf['show_timeout'] = True
    # NOTE: We are ready to wait for 10 min (600 sec) to get response.
    salt_master_conf['timeout'] = 600
    salt_master_conf['gather_job_timeout'] = 600
    # Original `worker_threads` is set to 5, but
    # maybe 15 will make it more responsive.
    salt_master_conf['worker_threads'] = 15

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

    # NOTE: We don't install Salt master,
    #       but we use common function to delete all minion keys.
    from utils.install_salt import delete_all_minion_keys_on_master

    delete_all_minion_keys_on_master()

    ###########################################################################
    # Restart both Salt master and Salt minion.

    # NOTE: Use `rhel5` implementation as it works for `systemd`-based too.
    from steps.deploy.activate_salt_master.rhel5 import ensure_salt_master_activation

    ensure_salt_master_activation('salt-master')

    ###########################################################################
    # Run initial configuration for Salt master.

    # Because we only care about Salt master and master can only be Linux.
    from steps.deploy.run_init_states.generic_linux import run_init_states

    run_init_states(
        # TODO: Use better value for use case than None.
        #       At the moment `run_use_case` is expected to specify
        #       bootstrap use case or None for this script.
        #       However, how isn't it a use case as well (more meaningful
        #       than None)?
        run_use_case = None,
        salt_extra_args = [],
        cmd_extra_args = [],
        extra_state_names = [],
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

