
###############################################################################

from utils.process_zero import enable_service_systemd as enable_service
from utils.process_zero import start_service_systemd as start_service

from utils.set_network import ping_host_linux

###############################################################################
#

def do(action_context):

    enable_service(action_context.conf_m.activate_salt_minion['service_name'])
    start_service(action_context.conf_m.activate_salt_minion['service_name'])

    # Just a 5 sec delay introduced through `ping` to let service start.
    ping_host_linux(
        'salt',
        5,
    )

###############################################################################
# EOF
###############################################################################

