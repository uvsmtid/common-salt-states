import re
import os
import logging

from utils.exec_command import call_subprocess

###############################################################################
#
def get_rpm_list(
    dir_path_rel,
):
    # Compose list of all RPMs.
    rpm_list = []
    rpm_match = re.compile('^.*rpm$')
    for dir_item in os.listdir(dir_path_rel):
        dir_item_path = os.path.join(
            dir_path_rel,
            dir_item,
        )
        if os.path.isfile(dir_item_path):
            if rpm_match.match(dir_item_path):
                rpm_list.append(dir_item_path)
                logging.debug('dir_item added: ' + dir_item_path)
                continue
        logging.debug('dir_item skipped: ' + dir_item_path)

    return rpm_list

###############################################################################
#

def install_rpms(
    content_dir,
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
            # Option `--nodeps` is required, otherwise `rpm`
            # complains due to chain of dependencies on the same package with
            # different version. It is assumed that such operation is safe
            # as the host will can be fixed under Salt managment.
            '--nodeps',
            # Option `--replacepkgs` is required, otherwise `rpm -U`
            # will exit with non-zero error code if package is
            # already updated.
            '--replacepkgs',
            # Option `--force` is required, otherwise `rpm` exists
            # with error due to dependencies.
            '--force',
        ] + rpm_list,
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################

