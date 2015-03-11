import os
import logging

from utils.exec_command import call_subprocess
from utils.get_paths import get_abs_path

###############################################################################
#

def unzip_files(
    base_dir,
    zip_file_path_rel,
    dst_dir,
):
    # Remember current dir, then change to dir with RPMs.
    prev_cwd = os.getcwd()
    os.chdir(dst_dir)
    logging.debug('cwd: ' + os.getcwd())

    # Get absolute path to zip file.
    zip_file_abs_path = get_abs_path(
        base_dir,
        zip_file_path_rel,
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

def untar_files(
    base_dir,
    tar_file_path_rel,
    dst_dir,
):
    # Remember current dir, then change to dir with RPMs.
    prev_cwd = os.getcwd()
    os.chdir(dst_dir)
    logging.debug('cwd: ' + os.getcwd())

    # Get absolute path to tar file.
    tar_file_abs_path = get_abs_path(
        base_dir,
        tar_file_path_rel,
    )
    call_subprocess(
        command_args = [
            'tar',
            '-xvf',
            tar_file_abs_path,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Change back to previous current dir.
    os.chdir(prev_cwd)

###############################################################################
# EOF
###############################################################################
