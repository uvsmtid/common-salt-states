import subprocess
import os


def do(conf):

    print 'generic_linux'

    # TODO: This is tranisent configuration - it will reset on reboot.
    #       Implement copying configuration files for specific interface.

    os.system("/sbin/ip route add default via " + conf['default_route_ip'])
    os.system("ping -c 3 " + conf['remote_network_ip'])


