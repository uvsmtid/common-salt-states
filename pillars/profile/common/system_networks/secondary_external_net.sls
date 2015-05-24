###############################################################################
#

system_networks:

    secondary_external_net:

        subnet: 192.168.62.0

        # WARNING: netmask and prefix should be consistent
        #          (they define the same thing).
        netmask: 255.255.255.0
        netprefix: 24

        broadcast: 192.168.62.255

        gateway: 192.168.62.254

###############################################################################
# EOF
###############################################################################

