#

from utils.process_zero import enable_service_systemd as enable_service
from utils.process_zero import start_service_systemd as start_service

###############################################################################
#

def do(action_context):

    enable_service(action_context.conf_m.activate_salt_minion['service_name'])
    start_service(action_context.conf_m.activate_salt_minion['service_name'])

###############################################################################
# EOF
###############################################################################

