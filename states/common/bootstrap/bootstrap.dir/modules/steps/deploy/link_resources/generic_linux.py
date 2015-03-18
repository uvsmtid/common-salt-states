#

import logging

from utils.exec_command import call_subprocess

###############################################################################
#
def do(action_context):


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

    # TODO:
    # * Make resources available in the expected location (create symlinks
    #   to resources in boostrap directory).
    logging.critical("NOT FULLY IMPLEMENTED")

###############################################################################
# EOF
###############################################################################

