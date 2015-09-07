
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
    pillars_repo_abs_path,
    projects_states_repo_abs_paths,
    bootstrap_target_pillars_repo_abs_path,
    is_generic_profile,
    load_bootstrap_target_envs,
    project_name,
    profile_name,
):
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

    for project_name in projects_states_repo_abs_paths.keys():
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
    # Make sure `pillars` symlink points to `pillars` repository.

    # Note that in case of generic profile instead of `pillars_repo_abs_path`
    # `states` repo of the project is used instead.
    effective_pillars_repo_abs_path = None
    if is_generic_profile:
        if project_name != 'common':
            effective_pillars_repo_abs_path = projects_states_repo_abs_paths[project_name]
        else:
            # common
            effective_pillars_repo_abs_path = states_repo_abs_path
    else:
        # Use conventional pillars location (as normal)
        effective_pillars_repo_abs_path = pillars_repo_abs_path

    assert(os.path.isabs(effective_pillars_repo_abs_path))
    command_args = [
        'ln',
        '-snf',
        os.path.join(
            effective_pillars_repo_abs_path,
            'pillars',
        ),
        '/srv/pillars',
    ]
    call_subprocess(
        command_args,
    )

    ###########################################################################
    # Make sure `pillars` contains symlinks to all bootstrap profiles.
    # NOTE: It is assumed that single repository contains branches with
    #       pillars for all bootstrap target profiles.
    # NOTE: None of the `pillars` repositories is considered
    #       when generic profile from `states` repository is used.

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
    #       pointing into effective pillars repository.
    #       On the other hand, when the function is called outside
    #       of bootstrap process, do not substitute bootstrap target
    #       profile pillars repository.
    if run_use_case is not None:
        # Inside bootstrap process.
        # Re-use the same pillars repository for bootstrap targets.
        # Make sure parent directory for symlink exists.
        command_args = [
            'mkdir',
            '-p',
            os.path.dirname(bootstrap_target_pillars_repo_abs_path),
        ]
        call_subprocess(
            command_args,
        )
        # Create symlink.
        command_args = [
            'ln',
            '-snf',
            effective_pillars_repo_abs_path,
            bootstrap_target_pillars_repo_abs_path,
        ]
        call_subprocess(
            command_args,
        )

    # Create links to all declared profiles names (plus current profile)
    # to make sure pillar can be loaded.
    # NOTE: Regardless whether pillars are stored in `states`, separate
    #       `pillars` repository or separate bootstrap target profile
    #       pillars repository, all symlinks will point to that chosen
    #       repository (effectively, they will all load the same pillars
    #       data).
    profile_names = [ profile_name ] + load_bootstrap_target_envs.keys()

    assert(os.path.isabs(bootstrap_target_pillars_repo_abs_path))

    for profile_name in profile_names:
        command_args = [
            'ln',
            '-snf',
            os.path.join(
                bootstrap_target_pillars_repo_abs_path,
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

###############################################################################
#

def do(action_context):

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
        pillars_repo_abs_path = pillars_destination_dir,
        projects_states_repo_abs_paths = action_context.conf_m.link_sources['projects_states_repo_abs_paths'],
        bootstrap_target_pillars_repo_abs_path = action_context.conf_m.link_sources['bootstrap_target_pillars_repo_abs_path'],
        is_generic_profile = action_context.conf_m.link_sources['is_generic_profile'],
        load_bootstrap_target_envs = action_context.conf_m.link_sources['load_bootstrap_target_envs'],
        project_name = action_context.conf_m.project_name,
        profile_name = action_context.conf_m.profile_name,
    )

###############################################################################
# EOF
###############################################################################

