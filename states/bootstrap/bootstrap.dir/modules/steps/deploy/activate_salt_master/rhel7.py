#

from utils.process_zero import enable_service_systemd as enable_service
from utils.process_zero import start_service_systemd as start_service

###############################################################################
#

def do(action_context):

    if not action_context.conf_m.activate_salt_master['is_salt_master']:
        return

    enable_service(action_context.conf_m.activate_salt_master['service_name'])
    start_service(action_context.conf_m.activate_salt_master['service_name'])

###############################################################################
# EOF
###############################################################################
