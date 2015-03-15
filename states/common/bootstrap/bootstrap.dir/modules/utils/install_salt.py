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

def deploy_salt(
    temp_rpm_dir_path_rel,
    salt_deploy_step_config,
    action_context,
):
    # Make sure `rpms` dir exists.
    if not os.path.exists(temp_rpm_dir_path_rel):
        os.makedirs(temp_rpm_dir_path_rel)

    # Prepare all rpm files in `rpms` dir.
    for rpm_source in salt_deploy_step_config['rpm_sources'].values():
        if rpm_source['source_type'] == 'zip':
            unzip_files(
                content_dir = action_context.content_dir,
                zip_file_path_rel = rpm_source['file_path'],
                dst_dir = temp_rpm_dir_path_rel,
            )
        elif rpm_source['source_type'] == 'tar':
            untar_files(
                content_dir = action_context.content_dir,
                tar_file_path_rel = rpm_source['file_path'],
                dst_dir = temp_rpm_dir_path_rel,
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
# EOF
###############################################################################

