
###############################################################################
#

system_networks:

    # TODO: Add docs.
    #
    # Primary network is available on hypervisor without any virtualized
    # network interfaces.
    #
    # It is important to resolve master hostname on this network
    # (otherwise it won't be reachible until virtual networks are created).
    primary_net:

        subnet: 192.168.1.0

        # WARNING: netmask and prefix should be consistent
        #          (they define the same thing).
        netmask: 255.255.255.0
        netprefix: 24

        broadcast: 192.168.1.255

        # Default route.
        gateway: 192.168.1.254

###############################################################################
# EOF
###############################################################################

