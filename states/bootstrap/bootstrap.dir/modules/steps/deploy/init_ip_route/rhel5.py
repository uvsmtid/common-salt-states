
###############################################################################

from utils.exec_command import call_subprocess
from utils.set_network import ping_host_linux
from utils.set_network import set_net_config_var
from utils.set_network import set_transient_route

###############################################################################
#

def do(action_context):

    # Persistent configuration of default route is in `GATEWAY` variable of
    # `/etc/sysconfig/network` file.
    set_net_config_var(
        var_name = 'GATEWAY',
        var_value = action_context.conf_m.init_ip_route['default_route_ip'],
        file_path = '/etc/sysconfig/network',
    )

    # Set transient default getway for this time.
    set_transient_route(
        network_address = '0.0.0.0/0',
        router_address = action_context.conf_m.init_ip_route['default_route_ip'],
    )

    # Test default gateway.
    ping_host_linux(
        action_context.conf_m.init_ip_route['remote_network_ip'],
    )

###############################################################################
# EOF
###############################################################################

