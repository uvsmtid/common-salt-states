from utils.exec_command import call_subprocess
from utils.set_network import ping_host
from utils.set_network import set_net_config_var
from utils.set_network import set_transient_route
from steps.deploy.init_ip_route.rhel5 import do as do_rhel5

###############################################################################
#

def do(action_context):
    # At the moment, there is no difference with `rhel5`.    
    do_rhel5(action_context)

###############################################################################
# EOF
###############################################################################

