
###############################################################################
#

system_networks:

    # TODO: Add docs.
    #
    # This localhost network represents 127.0.0.0/8 addresses.
    #
    # It is important to resolve some hosts on this network
    # so that they are always reachable.
    localhost_net:

        # AKA "network address":
        subnet: 127.0.0.0

        # WARNING: netmask and prefix should be consistent
        #          (they define the same thing).
        netmask: 255.0.0.0
        netprefix: 8

        broadcast: 127.255.255.255

        # Default route.
        gateway: 127.0.0.1

###############################################################################
# EOF
###############################################################################

