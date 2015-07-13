#!/usr/bin/env python

# Save two pillars from bootstrap profiles into files for comparision.

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
    # * Left and Right pillar
    profile_name_left = sys.argv[1]
    profile_name_right = sys.argv[2]
    # * Path to pillars profile properties file.
    properties_file_path = sys.argv[3]

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
    content_dir = None
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
    # Load pillars and save them into separate files.

    # Check initial branch.
    command_args = [
        'git',
        'rev-parse',
        '--abbrev-ref',
        'HEAD',
    ]
    process_output = call_subprocess(
        command_args,
        capture_stdout = True,
        cwd = props['repo_path_bootstrap_target_pillars'],
    )
    initial_branch = process_output['stdout'].strip()
    assert(initial_branch != 'HEAD')

    try:
        # Collect profile pillars data in separate files.
        pillar_path_to_content = {}
        for profile_name in [ profile_name_left, profile_name_right ]:

            # Check out branch with required pillar.
            command_args = [
                'git',
                'checkout',
                profile_name,
            ]
            call_subprocess(
                command_args,
                cwd = props['repo_path_bootstrap_target_pillars'],
            )

            # Make sure pillars are updated.
            command_args = [
                'salt-call',
                'saltutil.refresh_pillar',
            ]
            call_subprocess(
                command_args,
            )

            # Run Salt's `pillar.items` and captrue its output.
            command_args = [
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

            # Save profile pillars in memory.
            project_name = pillars['local']['project_name']
            pillar_name_path = profile_name + '.yaml'
            pillar_path_to_content[ pillar_name_path ] = pillars['local']['bootstrap_target_envs'][ project_name + '.' + profile_name ]

            # Save pillars in a named file.
            pillar_name_stream = None
            try:
                pillar_name_stream = open(pillar_name_path, 'w')
                yaml.dump(
                    pillar_path_to_content[pillar_name_path],
                    pillar_name_stream,
                    default_flow_style = False,
                    indent = 4,
                )
            finally:
                try:
                    pillar_name_stream.close()
                except:
                    pass

    finally:
        # Switch back to initial branch.
        command_args = [
            'git',
            'checkout',
            initial_branch,
        ]
        call_subprocess(
            command_args,
            cwd = props['repo_path_bootstrap_target_pillars'],
        )

###############################################################################
#
if __name__ == '__main__':
    main()

###############################################################################
# EOF
###############################################################################

