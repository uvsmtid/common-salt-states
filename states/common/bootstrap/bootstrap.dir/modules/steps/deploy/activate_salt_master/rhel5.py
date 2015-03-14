#

from utils.process_zero import enable_service_initd as enable_service
from utils.process_zero import start_service_initd as start_service

###############################################################################
#

def do(action_context):

    enable_service(action_context.conf_m.activate_salt_master['service_name'])
    start_service(action_context.conf_m.activate_salt_master['service_name'])

###############################################################################
# EOF
###############################################################################

