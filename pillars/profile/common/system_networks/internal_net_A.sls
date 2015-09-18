
###############################################################################
#

system_networks:

    internal_net_A:

        subnet: 192.168.51.0

        # WARNING: netmask and prefix should be consistent
        #          (they define the same thing).
        netmask: 255.255.255.0
        netprefix: 24

        broadcast: 192.168.51.255

        # Default route.
        gateway: 192.168.51.1

###############################################################################
# EOF
###############################################################################

