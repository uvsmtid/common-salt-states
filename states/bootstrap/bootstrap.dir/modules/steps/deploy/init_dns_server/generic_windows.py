
###############################################################################

import logging
import os.path

from utils.exec_command import call_subprocess
from utils.set_network import set_dns_server_windows
from utils.set_network import ping_host_windows

###############################################################################
#

def do(action_context):

    # Set DNS servers on Windows.
    # This is both transient and persistent setting.
    set_dns_server_windows(
        dns_server_ip = action_context.conf_m.init_dns_server['dns_server_ip'],
    )

    # Make sure remote hosts are ping-able.
    ping_host_windows(
        resolvable_string = action_context.conf_m.init_dns_server['remote_hostname'],
    )

###############################################################################
# EOF
###############################################################################

