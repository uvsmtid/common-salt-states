#

import os
import logging

from utils.exec_command import call_subprocess
from utils.archive import unzip_files
from utils.archive import untar_files

###############################################################################
#

def deploy_repos(
    link_sources_step_config,
    action_context,
):
    # Prepare all sources in there expected directory.
    for repo_conf in link_sources_step_config['repos'].values():

        logging.debug('repo_conf = ' + str(repo_conf))
        destination_dir = repo_conf['destination_dir']

        # Make sure destination directory exists.
        if not os.path.exists(destination_dir):
            os.makedirs(destination_dir)

        # Unpack sources depending on `archive_type`.
        if repo_conf['archive_type'] == 'zip':
            unzip_files(
                content_dir = action_context.content_dir,
                zip_file_path_rel = repo_conf['exported_source_archive'],
                dst_dir = destination_dir,
            )
        elif repo_conf['archive_type'] == 'tar':
            untar_files(
                content_dir = action_context.content_dir,
                tar_file_path_rel = repo_conf['exported_source_archive'],
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

    # Set `/srv/states` symlink to Salt sources's `states` directory.
    # Set `/srv/pillars` symlink to Salt sources's `pillars` directory.
    #
    # TODO: There can be multiple sources of states (i.e. in
    #       multi-project case. Figure out how to make it generic.
    state_sources = action_context.conf_m.link_sources['state_sources']
    state_sources_destination_dir = action_context.conf_m.link_sources['repos'][state_sources]['destination_dir']
    for link_name in ['states', 'pillars']:
        call_subprocess(
            command_args = [
                'ln',
                '-snf',
                os.path.join(
                    state_sources_destination_dir,
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

