from utils.exec_command import call_subprocess
from utils.set_network import set_net_config_var

###############################################################################
#

def do(action_context):

    # Persistent configuration of hostname is in `HOSTNAME` variable of
    # `/etc/sysconfig/network` file.
    set_net_config_var(
        var_name = 'HOSTNAME',
        var_value = action_context.conf_m.set_hostname['hostname'],
        file_path = '/etc/sysconfig/network',
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


