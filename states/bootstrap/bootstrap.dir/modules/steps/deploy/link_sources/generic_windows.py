
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
    # NOTE: This step is required for standalone (masterless) Salt minion.
    logging.critical("Implement for Windows: link_sources")
    return

    # TODO: Make this generic with Linux.

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
    overrides_profile_pillars_repo_abs_path,
    projects_states_repo_abs_paths,
    overrides_bootstrap_target_profile_pillars_repo_abs_path,
    project_name,
    profile_name,
):

    # TODO: Implement for Windows.
    # NOTE: This step is required for standalone (masterless) Salt minion.
    logging.critical("Implement for Windows: link_sources")
    return

    # TODO: Make this generic with Linux.

###############################################################################
#

def do(action_context):

    # TODO: Implement for Windows.
    # NOTE: This step is required for standalone (masterless) Salt minion.
    logging.critical("Implement for Windows: link_sources")
    return

    # TODO: Make this generic with Linux.

###############################################################################
# EOF
###############################################################################

