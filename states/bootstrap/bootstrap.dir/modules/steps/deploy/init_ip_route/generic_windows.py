
###############################################################################

from utils.exec_command import call_subprocess
from utils.set_network import ping_host_windows
from utils.set_network import set_route_windows

###############################################################################
#

def do(action_context):

    # Set default getway (this is both transient and persistent for Windows).
    set_route_windows(
        network_destination = '0.0.0.0',
        network_mask = '0.0.0.0',
        router_address = action_context.conf_m.init_ip_route['default_route_ip'],
    )

    # Test default gateway.
    ping_host_windows(
        action_context.conf_m.init_ip_route['remote_network_ip'],
    )

###############################################################################
# EOF
###############################################################################

