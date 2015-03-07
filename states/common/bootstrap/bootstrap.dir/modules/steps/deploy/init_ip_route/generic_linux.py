import os

###############################################################################
#

def do(action_context):

    # TODO: This is tranisent configuration - it will reset on reboot.
    #       Implement copying configuration files for specific interface.

    os.system("/sbin/ip route add default via " + action_context.conf_m.init_ip_route['default_route_ip'])
    os.system("ping -c 3 " + action_context.conf_m.init_ip_route['remote_network_ip'])

###############################################################################
# EOF
###############################################################################

