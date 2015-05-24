
###############################################################################
#

system_networks:

    secondary_internal_net:

        subnet: 192.168.52.0

        # WARNING: netmask and prefix should be consistent
        #          (they define the same thing).
        netmask: 255.255.255.0
        netprefix: 24

        broadcast: 192.168.52.255

        # Default route.
        gateway: 192.168.52.1

###############################################################################
# EOF
###############################################################################

