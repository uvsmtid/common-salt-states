###############################################################################
#

system_networks:

    # See: docs/pillars/common/system_networks/external_net/readme.md
    external_net:

        subnet: 192.168.1.0

        # WARNING: netmask and prefix should be consistent
        #          (they define the same thing).
        netmask: 255.255.255.0
        netprefix: 24

        broadcast: 192.168.1.255

        gateway: 192.168.1.254

###############################################################################
# EOF
###############################################################################

