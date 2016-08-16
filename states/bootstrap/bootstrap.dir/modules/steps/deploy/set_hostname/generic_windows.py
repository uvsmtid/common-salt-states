from utils.exec_command import call_subprocess
from utils.set_network import set_hostname_windows

###############################################################################
#

def do(action_context):

    # Set currently used hostname.
    # NOTE: Unfortunately for Windows,
    #       the name will only become effective after restart.
    set_hostname_windows(
        hostname = action_context.conf_m.set_hostname['hostname'],
    )

###############################################################################
# EOF
###############################################################################


