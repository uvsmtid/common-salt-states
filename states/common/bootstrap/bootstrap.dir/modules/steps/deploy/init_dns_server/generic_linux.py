import os
from utils.exec_command import call_subprocess

###############################################################################
#

def do(action_context):

    # Deploy `resolv.conf` configuration file.
    call_subprocess(
        command_args = [
            'cp',
            os.path.join(
                action_context.base_dir,
                action_context.conf_m.init_dns_server['resolv_conf_file'],
            ),
            '/etc/resolv.conf',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Make sure remote hosts are ping-able.
    call_subprocess(
        command_args = [
            'ping',
            '-c',
            '3',
            action_context.conf_m.init_dns_server['remote_hostname'],
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################

