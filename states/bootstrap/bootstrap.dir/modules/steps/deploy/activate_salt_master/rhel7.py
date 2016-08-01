
###############################################################################

from utils.process_zero import disable_service_systemd as disable_service
from utils.process_zero import stop_service_systemd as stop_service

from utils.process_zero import enable_service_systemd as enable_service
from utils.process_zero import start_service_systemd as start_service

from utils.set_network import ping_host_linux

###############################################################################
#

def do(action_context):

    if not action_context.conf_m.activate_salt_master['is_salt_master']:
        return

    # Disable and stop firewall.
    # TODO: Find a better way to deal with it.
    #       One option is to keep on disabling the firewall while leaving
    #       proper firewall configuration to Salt states executed later.
    disable_service('firewalld')
    stop_service('firewalld')

    # Enable and start Salt master.
    enable_service(action_context.conf_m.activate_salt_master['service_name'])
    start_service(action_context.conf_m.activate_salt_master['service_name'])

    # Just a 5 sec delay introduced through `ping` to let service start.
    ping_host_linux(
        'salt',
        5,
    )

###############################################################################
# EOF
###############################################################################

