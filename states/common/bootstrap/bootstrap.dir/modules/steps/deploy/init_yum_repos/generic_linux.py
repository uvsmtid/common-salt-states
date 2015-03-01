import os
from utils.exec_command import call_subprocess
from utils.get_paths import get_abs_path

###############################################################################
#

def import_rpm_key(
    base_dir,
    rpm_key_file_path,
):
    rpm_key_file_abs_path = get_abs_path(
        base_dir,
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

    # TODO:
    # * Loop through all required YUM repositories and either install
    #   necessary RPM packages or copy pre-generated repo configs to
    #   `/etc/yum.repos.d`.
    # * Make sure to import RPM key for signed packages.
    # * Copy pre-generated YUM config `/etc/yum.conf`.

    for repo_config in action_context.conf_m.init_yum_repos['yum_repo_configs'].values():
        if 'rpm_key_file' in repo_config:
            import_rpm_key(
                action_context.base_dir,
                repo_config['rpm_key_file'],
            )

    print 'NOT FULLY IMPLEMENTED'

###############################################################################

