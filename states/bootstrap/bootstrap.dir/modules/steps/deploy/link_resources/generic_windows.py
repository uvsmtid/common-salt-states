#

import logging
import os.path

from utils.exec_command import call_subprocess

###############################################################################
#
def do(action_context):

    # TODO: Implement for Windows.
    logging.critical("Implement for Windows.")
    return

    # NOTE: Location of all resources is re-written into the new pillar.
    #       The symlinks are adjusted through `common.resource_symlinks`.
    # NOTE: State `common.resources` expects directory `/srv/resources`
    #       to be created manually.
    # Make sure basedir destination directory exists.
    call_subprocess(
        command_args = [
            'mkdir',
            '-p',
            '/srv/resources',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Configuration provides location of symlink which has to be set to
    # the actual resource location.
    resource_symlink = action_context.conf_m.link_resources['resource_symlink']
    resource_base_dir_rel_path = action_context.conf_m.link_resources['resource_base_dir_rel_path']
    assert(os.path.isabs(resource_symlink))
    assert(not os.path.isabs(resource_base_dir_rel_path))
    # Create a directory for the symlink first.
    call_subprocess(
        command_args = [
            'mkdir',
            '-p',
            os.path.dirname(resource_symlink),
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )
    # Create symlink itself.
    call_subprocess(
        command_args = [
            'ln',
            '-snf',
            os.path.join(
                action_context.content_dir,
                resource_base_dir_rel_path,
            ),
            resource_symlink,
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################

