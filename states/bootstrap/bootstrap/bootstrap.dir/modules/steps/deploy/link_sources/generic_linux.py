#

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
def do(action_context):

    # Unpack sources into expected locations.
    deploy_repos(
        action_context.conf_m.link_sources,
        action_context,
    )

    # Set `/srv/states` symlink to Salt `states` directory.
    # Set `/srv/pillars` symlink to Salt `pillars` directory.
    #
    # TODO: There can be multiple sources of states (i.e. in
    #       multi-project case. Figure out how to make it generic.
    states_src = action_context.conf_m.link_sources['salt_states_sources']
    pillars_src = action_context.conf_m.link_sources['salt_pillars_sources']
    if action_context.run_use_case == 'offline-minion-installer':
        states_destination_dir = action_context.conf_m.link_sources['repos'][states_src]['offline_destination_dir']
        pillars_destination_dir = action_context.conf_m.link_sources['repos'][pillars_src]['offline_destination_dir']
    else:
        states_destination_dir = action_context.conf_m.link_sources['repos'][states_src]['online_destination_dir']
        pillars_destination_dir = action_context.conf_m.link_sources['repos'][pillars_src]['online_destination_dir']

    symlink_to_dst_dir_map = {
        'states': states_destination_dir,
        'pillars': pillars_destination_dir,
    }

    for link_name in symlink_to_dst_dir_map.keys():
        call_subprocess(
            command_args = [
                'ln',
                '-snf',
                os.path.join(
                    symlink_to_dst_dir_map[link_name],
                    link_name,
                ),
                '/srv/' + link_name,
            ],
            raise_on_error = True,
            capture_stdout = False,
            capture_stderr = False,
        )

###############################################################################
# EOF
###############################################################################

