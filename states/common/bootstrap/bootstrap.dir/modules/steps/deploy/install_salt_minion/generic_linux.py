import os
import re
import logging
from utils.exec_command import call_subprocess
from utils.get_paths import get_abs_path

###############################################################################
#

def unzip_rpms(
    base_dir,
    zip_file_path,
    dst_dir,
):
    # Remember current dir and change to `rpms`.
    prev_cwd = os.getcwd()
    os.chdir(dst_dir)
    logging.debug('cwd: ' + os.getcwd())

    # Get absolute path to zip file.
    zip_file_abs_path = get_abs_path(
        base_dir,
        zip_file_path,
    )
    call_subprocess(
        command_args = [
            'unzip',
            # Overwrite files non-interactively.
            '-o',

            # Do not use `-v` opiont - it disables error code
            # and failures are not detected.
            #'-v',

            zip_file_abs_path,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Change back to previous current dir.
    os.chdir(prev_cwd)

###############################################################################
#

def install_rpms(
    base_dir,
    rpm_list,
):
    # Try to update already installed RPMs first.
    # Ignore failure.
    # RPM "upgrate" fail if there is nothing to upgrate (everything
    # up to date) in the list of RPMs.
    process_output = call_subprocess(
        command_args = [
            'rpm',
            '-Uv',
            # Option `--replacepkgs` is required, otherwise `rpm -U`
            # will exit with non-zero error code if package is
            # already updated.
            '--replacepkgs',
        ] + rpm_list,
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    #if process_output['code'] == 0:
    return

    # If "upgrade" failed, try to install RPMs.
    process_output = call_subprocess(
        command_args = [
            'rpm',
            '-iv',
        ] + rpm_list,
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
#

def do(action_context):

    # Make sure `rpms` dir exists.
    all_rpms_dir = 'rpms'
    if not os.path.exists(all_rpms_dir):
        os.makedirs(all_rpms_dir)

    # Prepare all rpm files in `rpms` dir.
    for rpm_source in action_context.conf_m.install_salt_minion['rpm_sources'].values():
        if rpm_source['source_type'] == 'zip':
            unzip_rpms(
                action_context.base_dir,
                rpm_source['file_path'],
                all_rpms_dir,
            )
        else:
            raise NotImplementedError

    # Compose list of all RPMs.
    rpm_list = []
    rpm_match = re.compile('^.*rpm$')
    for dir_item in os.listdir(all_rpms_dir):
        dir_item_path = os.path.join(
            all_rpms_dir,
            dir_item,
        )
        if os.path.isfile(dir_item_path):
            if rpm_match.match(dir_item_path):
                rpm_list.append(dir_item_path)
                logging.debug('dir_item added: ' + dir_item_path)
                continue
        logging.debug('dir_item skipped: ' + dir_item_path)

    # Install all RPMs.
    install_rpms(
        action_context.base_dir,
        rpm_list,
    )

    # Deploy minion configuration file.
    call_subprocess(
        command_args = [
            'cp',
            os.path.join(
                action_context.base_dir,
                action_context.conf_m.install_salt_minion['salt_minion_config_file'],
            ),
            '/etc/salt/minion',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Clean up: remove extracted RPMs.
    call_subprocess(
        command_args = [
            'rm',
            '-rf',
            all_rpms_dir,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################

