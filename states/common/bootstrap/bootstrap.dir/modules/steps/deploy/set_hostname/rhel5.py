import os
from utils.exec_command import call_subprocess

###############################################################################
#

def do(action_context):

    # Persistent configuration of hostname is in `HOSTNAME` variable of
    # `/etc/sysconfig/network` file.
    call_subprocess(
        command_args = [
            'sed',
            '-i',
            's/^HOSTNAME=.*$/HOSTNAME=' + action_context.conf_m.set_hostname['hostname'] + '/g',
            '/etc/sysconfig/network',
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

    # Set currently used hostname.
    call_subprocess(
        command_args = [
            '/bin/hostname',
            action_context.conf_m.set_hostname['hostname'],
        ],
        raise_on_error = True,
        capture_stdout = False,
        capture_stderr = False,
    )

###############################################################################
# EOF
###############################################################################


