from utils.exec_command import call_subprocess

###############################################################################
#

def do(action_context):

    # Persistent configuration of hostname is simply content of
    # `/etc/hostname` file.
    # Use `w` to overwrite content of the file.
    with open('/etc/hostname', 'w') as config_file:
        config_file.write(action_context.conf_m.set_hostname['hostname'])

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


