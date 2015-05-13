
###############################################################################

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

    backup_dir_path = '/etc/yum.repos.d.backup.salt.bootstrap'
    # Backup all pre-configured yum repositories.
    # Backup only if backup directory does not exist yet
    # (on clean OS it should not exits).
    if not os.path.exists(backup_dir_path):
        call_subprocess(
            command_args = [
                'mv',
                '-T',
                '/etc/yum.repos.d',
                backup_dir_path,
            ],
            raise_on_error = True,
            capture_stdout = False,
            capture_stderr = False,
        )

    # Make sure parent dir `/etc/yum.repos.d` exists.
    call_subprocess(
        command_args = [
            'mkdir',
            '-p',
            '/etc/yum.repos.d',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Deploy `platform_repos_list.repo` configuration file.
    call_subprocess(
        command_args = [
            'cp',
            os.path.join(
                action_context.content_dir,
                action_context.conf_m.init_yum_repos['platform_repos_list'],
            ),
            '/etc/yum.repos.d/platform_repos_list.repo',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    for repo_config in action_context.conf_m.init_yum_repos['yum_repo_configs'].values():
        assert('key_file_resource_path' in repo_config)
        assert('key_file_path' in repo_config)
        import_rpm_key(
            action_context.content_dir,
            repo_config['key_file_resource_path'],
        )
        # Copy the key into expected location according to YUM configuration.
        call_subprocess(
            command_args = [
                'cp',
                '--force',
                os.path.join(
                    action_context.content_dir,
                    repo_config['key_file_resource_path'],
                ),
                repo_config['key_file_path'],
            ],
            # Ignore this error for now, just generate the output.
            # This is because copying the key in expected location is
            # not required as long as the import was successful.
            #raise_on_error = True,
            raise_on_error = False,
            capture_stdout = False,
            capture_stderr = False,
        )

###############################################################################
# EOF
###############################################################################

