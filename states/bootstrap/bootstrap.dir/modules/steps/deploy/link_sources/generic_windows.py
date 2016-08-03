
###############################################################################

import os
import logging

from utils.exec_command import call_subprocess

from utils.archive import unzip_files
from utils.archive import untar_files
from utils.archive import clone_files

###############################################################################
#

def deploy_repos(
    link_sources_step_config,
    action_context,
):

    # TODO: Implement for Windows.
    logging.critical("Implement for Windows.")
    return

    # Prepare all sources in there expected directory.
    for repo_conf in link_sources_step_config['repos'].values():

        logging.debug('repo_conf = ' + str(repo_conf))
        if action_context.run_use_case == 'offline-minion-installer':
            destination_dir = repo_conf['offline_destination_dir']
        else:
            destination_dir = repo_conf['online_destination_dir']

        # Make sure destination directory exists.
        if not os.path.exists(destination_dir):
            os.makedirs(destination_dir)

        # Unpack sources depending on `export_format`.
        if not repo_conf['export_format']:
            raise NotImplementedError
        elif repo_conf['export_format'] == 'zip':
            unzip_files(
                content_dir = action_context.content_dir,
                zip_file_path_rel = repo_conf['exported_source_archive'],
                dst_dir = destination_dir,
            )
        elif repo_conf['export_format'] == 'tar':
            untar_files(
                content_dir = action_context.content_dir,
                tar_file_path_rel = repo_conf['exported_source_archive'],
                dst_dir = destination_dir,
            )
        elif repo_conf['export_format'] == 'dir':
            clone_files(
                content_dir = action_context.content_dir,
                dir_path_rel = repo_conf['exported_source_archive'],
                dst_dir = destination_dir,
            )
        else:
            raise NotImplementedError

###############################################################################
#

def set_salt_states_and_pillars_symlinks(
    # TODO: Use better value for use case than None.
    #       At the moment `run_use_case` is expected to specify
    #       bootstrap use case or None for this script.
    #       However, how isn't it a use case as well (more meaningful
    #       than None)?
    run_use_case,
    states_repo_abs_path,
    overrides_pillars_repo_abs_path,
    projects_states_repo_abs_paths,
    overrides_bootstrap_target_pillars_repo_abs_path,
    project_name,
    profile_name,
):

    # TODO: Implement for Windows.
    logging.critical("Implement for Windows.")
    return

    ###########################################################################
    # Make sure `states` symlink points to `states` repository.

    assert(os.path.isabs(states_repo_abs_path))
    command_args = [
        'ln',
        '-snf',
        os.path.join(
            states_repo_abs_path,
            'states',
        ),
        '/srv/states',
    ]
    call_subprocess(
        command_args,
    )

    ###########################################################################
    # Make sure `states` contains symlinks to all project states repos.

    project_names = projects_states_repo_abs_paths.keys()
    logging.debug('symlinks to states of project_names: ' + str(project_names))
    for project_name in project_names:
        project_repo_path = projects_states_repo_abs_paths[project_name]
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
    # Make sure `main.sls` is a symlink to `main.sls`
    # under `states` directory of required project.

    command_args = [
        'ln',
        '-snf',
        os.path.join(
            project_name,
            'main.sls',
        ),
        '/srv/states/main.sls',
    ]
    call_subprocess(
        command_args,
    )

    ###########################################################################
    # Make sure all:
    #   - `commons`
    #   - `defaults`
    #   - `overrides`
    # symlinks point to `pillars` directories in relevant repositories.

    if project_name != 'common':
        defaults_pillars_repo_abs_path = projects_states_repo_abs_paths[project_name]
    else:
        # For `common` project `defaults` point to `common-salt-states`.
        defaults_pillars_repo_abs_path = states_repo_abs_path

    # `commons` pillars are in `common-salt-states` repository.
    commons_pillars_repo_abs_path = states_repo_abs_path

    # Create base `/srv/pillars` directory.
    command_args = [
        'mkdir',
        '-p',
        '/srv/pillars',
    ]
    call_subprocess(
        command_args,
    )

    # Make symlinks.
    for pillars_repo_map_item in [
        {
            'symlink_name': 'commons'
            ,
            'symlink_target': commons_pillars_repo_abs_path
        }
        ,
        {
            'symlink_name': 'defaults'
            ,
            'symlink_target': defaults_pillars_repo_abs_path
        }
        ,
        {
            'symlink_name': 'overrides'
            ,
            'symlink_target': overrides_pillars_repo_abs_path
        }
    ]:
        assert(os.path.isabs(pillars_repo_map_item['symlink_target']))

        abs_target_path = os.path.join(
            pillars_repo_map_item['symlink_target'],
            'pillars',
        )

        if not os.path.exists(abs_target_path):
            raise Exception('Repository does not have required subdirectory: ' + str(abs_target_path))

        abs_symlink_path = os.path.join(
            '/srv/pillars',
            pillars_repo_map_item['symlink_name'],
        )

        if not os.path.exists(os.path.dirname(abs_symlink_path)):
            raise Exception('Destination directory for symlink does not exist: ' + str(os.path.dirname(abs_symlink_path)))

        command_args = [
            'ln',
            '-snf',
            abs_target_path,
            abs_symlink_path,
        ]
        call_subprocess(
            command_args,
        )

    ###########################################################################
    # Make sure `pillars` contains symlinks to all bootstrap profiles.
    # NOTE: It is assumed that single repository contains branches with
    #       pillars for all bootstrap target profiles.

    # NOTE: When `run_use_case` is not specified, the function is used
    #       to run states oustide of bootstrap process.
    #       During bootstrap process the target pillars profile is not
    #       important (it was important on source system where
    #       the bootstrap package was generated, but not on the target
    #       system where it is used). Moreover, the target bootstrap
    #       profile pillars repository is not even exported (it is
    #       empty directory). So, symlinks to the target profile
    #       names will not contain loadable pillars. In order to
    #       avoid failures while loading pillars, create symlink
    #       named after bootstrap target profile pillars repository
    #       pointing into pillars repository.
    #       On the other hand, when the function is called outside
    #       of bootstrap process, do not substitute bootstrap target
    #       profile pillars repository.

    if run_use_case is not None:
        # Inside bootstrap process.
        # Re-use the same pillars repository for bootstrap targets -
        # target pillars are symlinked to source pillars.
        # Make sure parent directory for symlink exists.
        command_args = [
            'mkdir',
            '-p',
            os.path.dirname(overrides_bootstrap_target_pillars_repo_abs_path),
        ]
        call_subprocess(
            command_args,
        )
        # Create symlink.
        command_args = [
            'ln',
            '-snf',
            overrides_pillars_repo_abs_path,
            overrides_bootstrap_target_pillars_repo_abs_path,
        ]
        call_subprocess(
            command_args,
        )

    assert(os.path.isabs(overrides_bootstrap_target_pillars_repo_abs_path))

    # TODO: Create single symlink directly within `/srv/` directory
    #       rather than inside repository.
    #       It should provide `bootstrap_target_profile_pillar`.
    for pillars_repo_map_item in [
        # Layer `commons` points to itself (`common-salt-states.git`).
        {
            'symlink_name': 'commons'
            ,
            'symlink_target': commons_pillars_repo_abs_path
        }
        ,
        # Layer `defaults` points to itself (`project_name-salt-states.git`).
        {
            'symlink_name': 'defaults'
            ,
            'symlink_target': defaults_pillars_repo_abs_path
        }
        ,
        # This is a special case - the part of layered pillars
        # which is not shared per profile_name is bootstrap target pillar.
        # The rest are symlinked into `common-salt-states.git` and
        # `project_name-salt-states.git` repositories.
        {
            'symlink_name': 'overrides'
            ,
            'symlink_target': overrides_bootstrap_target_pillars_repo_abs_path
        }
    ]:

        abs_target_path = os.path.join(
            pillars_repo_map_item['symlink_target'],
            'pillars',
            'profile',
        )

        if not os.path.exists(abs_target_path):
            raise Exception('Repository does not have required subdirectory: ' + str(abs_target_path))

        abs_symlink_path = os.path.join(
            '/srv/pillars',
            pillars_repo_map_item['symlink_name'],
            'bootstrap/profiles',
            profile_name,
        )

        if not os.path.exists(os.path.dirname(abs_symlink_path)):
            raise Exception('Destination directory for symlink does not exist: ' + str(os.path.dirname(abs_symlink_path)))

        command_args = [
            'ln',
            '-snf',
            abs_target_path,
            abs_symlink_path,
        ]

        call_subprocess(
            command_args,
        )

###############################################################################
#

def do(action_context):

    # TODO: Implement for Windows.
    logging.critical("Implement for Windows.")
    return

    # Unpack sources into expected locations.
    deploy_repos(
        action_context.conf_m.link_sources,
        action_context,
    )

    # We only set primary states and pillars repos.
    # Symlinks to other repositories are already handled by
    # Salt based on config from these initial states and pillars.
    states_src = action_context.conf_m.link_sources['salt_states_sources']
    pillars_src = action_context.conf_m.link_sources['salt_pillars_sources']
    # NOTE: In online system, sources are on specific remote
    #       host (likely Salt master).
    #       In offline system, each minion has its own sources.
    #       `offline_destination_dir` and `online_destination_dir`.
    #       In other words, their absolute path is different for
    #       `offline-minion-installer` (where sources are deployed
    #       on specific minion with its own primary user) and
    #       `initial-online-node` (where sources are deployed
    #       on master with possibly different primary user).
    if action_context.run_use_case == 'offline-minion-installer':
        states_destination_dir = action_context.conf_m.link_sources['repos'][states_src]['offline_destination_dir']
        pillars_destination_dir = action_context.conf_m.link_sources['repos'][pillars_src]['offline_destination_dir']
    else:
        states_destination_dir = action_context.conf_m.link_sources['repos'][states_src]['online_destination_dir']
        pillars_destination_dir = action_context.conf_m.link_sources['repos'][pillars_src]['online_destination_dir']

    set_salt_states_and_pillars_symlinks(
        # TODO: Use better value for use case than None.
        #       At the moment `run_use_case` is expected to specify
        #       bootstrap use case or None for this script.
        #       However, how isn't it a use case as well (more meaningful
        #       than None)?
        run_use_case = action_context.run_use_case,
        states_repo_abs_path = states_destination_dir,
        overrides_pillars_repo_abs_path = pillars_destination_dir,
        projects_states_repo_abs_paths = action_context.conf_m.link_sources['projects_states_repo_abs_paths'],
        overrides_bootstrap_target_pillars_repo_abs_path = action_context.conf_m.link_sources['overrides_bootstrap_target_pillars_repo_abs_path'],
        project_name = action_context.conf_m.project_name,
        profile_name = action_context.conf_m.profile_name,
    )

###############################################################################
# EOF
###############################################################################

