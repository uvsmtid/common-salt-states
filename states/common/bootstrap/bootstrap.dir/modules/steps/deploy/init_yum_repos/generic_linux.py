#

import os.path
import logging

from utils.exec_command import call_subprocess
from utils.get_paths import get_abs_path

###############################################################################
#

def import_rpm_key(
    content_dir,
    rpm_key_file_path,
):
    rpm_key_file_abs_path = get_abs_path(
        content_dir,
        rpm_key_file_path,
    )

    call_subprocess(
        command_args = [
            'rpm',
            '-v',
            '--import',
            rpm_key_file_abs_path,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def do(action_context):

    # Deploy `yum.conf` configuration file.
    call_subprocess(
        command_args = [
            'cp',
            os.path.join(
                action_context.content_dir,
                action_context.conf_m.init_yum_repos['yum_main_config'],
            ),
            '/etc/yum.conf',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # TODO: Is it required? Can it be done through Salt?
    # * Loop through all required YUM repositories and either install
    #   necessary RPM packages for repository configuration
    #   or copy pre-generated repo configs to
    #   `/etc/yum.repos.d`.
    # * Test connection to YUM repository.
    #   For example, install `git` package.

    for repo_config in action_context.conf_m.init_yum_repos['yum_repo_configs'].values():
        if 'rpm_key_file' in repo_config:
            import_rpm_key(
                action_context.content_dir,
                repo_config['rpm_key_file'],
            )
        if 'installation_type' in repo_config:
            if repo_config['installation_type']:
                pass

    logging.critical('NOT FULLY IMPLEMENTED')

###############################################################################
# EOF
###############################################################################

