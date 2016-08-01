
###############################################################################

from utils.process_zero import disable_service_initd as disable_service
from utils.process_zero import stop_service_initd as stop_service

from utils.process_zero import enable_service_initd as enable_service
from utils.process_zero import start_service_initd as start_service

from utils.set_network import ping_host_linux

###############################################################################
#
def disable_firewall():

    # Disable and stop firewall.
    # TODO: Find a better way to deal with it.
    #       One option is to keep on disabling the firewall while leaving
    #       proper firewall configuration to Salt states executed later.
    disable_service('iptables')
    stop_service('iptables')

###############################################################################
#
def ensure_salt_master_activation(service_name):

    # Disable any running service - ignore errors.
    stop_service(service_name, raise_on_error = False)

    # Enable and start Salt master.
    enable_service(service_name)
    start_service(service_name)

    # Just a 5 sec delay introduced through `ping` to let service start.
    ping_host_linux(
        'salt',
        5,
    )

###############################################################################
#

def do(action_context):

    if not action_context.conf_m.activate_salt_master['is_salt_master']:
        return

    disable_firewall()
    ensure_salt_master_activation(
        action_context.conf_m.activate_salt_master['service_name'],
    )

###############################################################################
# EOF
###############################################################################

