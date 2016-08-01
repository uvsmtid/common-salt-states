import os

from utils.rpm_yum import get_rpm_list
from utils.rpm_yum import install_rpms
from utils.exec_command import call_subprocess
from utils.archive import unzip_files
from utils.archive import untar_files

###############################################################################
#

def deploy_salt_config_file(
    src_content_dir,
    src_salt_config_path_rel,
    dst_salt_config_path_abs,
):
    # Deploy Salt configuration file.
    call_subprocess(
        command_args = [
            'cp',
            os.path.join(
                src_content_dir,
                src_salt_config_path_rel,
            ),
            dst_salt_config_path_abs,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def deploy_salt_rhel(
    temp_rpm_dir_path_rel,
    salt_deploy_step_config,
    action_context,
):

    # Skip Salt master installation if this host
    # is not supposed to be Salt master.
    # Deployment config only for Salt master has key `is_master`.
    if 'is_master' in salt_deploy_step_config:
        if not salt_deploy_step_config['is_master']:
            return

    # Make sure `rpms` dir exists.
    if not os.path.exists(temp_rpm_dir_path_rel):
        os.makedirs(temp_rpm_dir_path_rel)

    # Prepare all rpm files in `rpms` dir.
    for package_resource in salt_deploy_step_config['package_resources'].values():
        if package_resource['resource_type'] == 'zip':
            unzip_files(
                content_dir = action_context.content_dir,
                zip_file_path_rel = package_resource['file_path'],
                dst_dir = temp_rpm_dir_path_rel,
            )
        elif package_resource['resource_type'] == 'tar':
            untar_files(
                content_dir = action_context.content_dir,
                tar_file_path_rel = package_resource['file_path'],
                dst_dir = temp_rpm_dir_path_rel,
            )
        elif package_resource['resource_type'] == 'rpm':
            # Simply copy that file.
            call_subprocess(
                command_args = [
                    'cp',
                    os.path.join(
                        action_context.content_dir,
                        package_resource['file_path'],
                    ),
                    temp_rpm_dir_path_rel,
                ],
                raise_on_error = True,
                capture_stdout = False,
                capture_stderr = False,
            )
        else:
            raise NotImplementedError

    # Compose list of all RPMs.
    rpm_list = get_rpm_list(
        dir_path_rel = temp_rpm_dir_path_rel,
    )

    # Install all RPMs.
    install_rpms(
        action_context.content_dir,
        rpm_list,
    )

    # Deploy configuration file.
    deploy_salt_config_file(
        src_content_dir = action_context.content_dir,
        # Note that minion has offline and online config.
        # The version of the config is assigned in the calling function to
        # `src_salt_config_file` key.
        src_salt_config_path_rel = salt_deploy_step_config['src_salt_config_file'],
        dst_salt_config_path_abs = salt_deploy_step_config['dst_salt_config_file'],
    )

    # Clean up: remove extracted RPMs.
    call_subprocess(
        command_args = [
            'rm',
            '-rf',
            temp_rpm_dir_path_rel,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def deploy_salt_windows(
    temp_rpm_dir_path_rel,
    salt_deploy_step_config,
    action_context,
):

    # Skip Salt master installation if this host
    # is not supposed to be Salt master.
    # Deployment config only for Salt master has key `is_master`.
    if 'is_master' in salt_deploy_step_config:
        if not salt_deploy_step_config['is_master']:
            return

    # Prepare all rpm files in `rpms` dir.
    for package_resource in salt_deploy_step_config['package_resources'].values():
        if package_resource['resource_type'] == 'exe':

            # Translate Cygwin path into Windows path
            process_output = call_subprocess(
                command_args = [
                    'cygpath',
                    '-w',
                    os.path.join(
                        action_context.content_dir,
                        package_resource['file_path'],
                    ),
                ],
                raise_on_error = True,
                capture_stdout = True,
                capture_stderr = False,
            )
            salt_installer_path_windows = process_output["stdout"].strip()

            # Copy installer to another directory to
            # avoid "NSIS Error" "Error launching installer" -
            # nobody knows why this happens.
            call_subprocess(
                command_args = [
                    'cp',
                    salt_installer_path_windows,
                    '/cygdrive/c',
                ],
                raise_on_error = True,
                capture_stdout = False,
                capture_stderr = False,
            )
            salt_installer_path_windows = 'C:\\' + os.path.basename(package_resource['file_path'])

            # Run official Salt Minion installer.
            call_subprocess(
                command_args = [
                    'cmd',
                    '/c',
                    'start',
                    '/i',
                    '/b',
                    '/wait',
                    salt_installer_path_windows,
                    '/S',

                    # Rely on propertly resolved `salt` hostname.
                    #'/master=' + 'salt',

                    # NOTE: The minion id is pre-set in from configuration
                    #       file deployed later.
                    '/minion-name=' + salt_deploy_step_config['salt_minion_id'],

                    # NOTE: Do not start server here.
                    #       Start it later at specific step
                    #       after configuration is done.
                    '/start-service=' + '0',
                ],
                raise_on_error = True,
                capture_stdout = False,
                capture_stderr = False,
            )
        else:
            raise NotImplementedError

    # Deploy configuration file.
    deploy_salt_config_file(
        src_content_dir = action_context.content_dir,
        # Note that minion has offline and online config.
        # The version of the config is assigned in the calling function to
        # `src_salt_config_file` key.
        src_salt_config_path_rel = salt_deploy_step_config['src_salt_config_file'],
        dst_salt_config_path_abs = salt_deploy_step_config['dst_salt_config_file'],
    )

###############################################################################
#

def delete_all_minion_keys_on_master():

    command_args = [
        'salt-key',
        '-y',
        '--delete-all',
    ]
    call_subprocess(
        command_args,
    )

###############################################################################
# EOF
###############################################################################

