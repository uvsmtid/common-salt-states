###############################################################################
# Physical/external network which is accessible to VMs through `router_role`.
# WARNING: these settings are normally provided by DHCP server on the
#          external network. They should be adjusted manually
#          based on that network configuration.
#
#          However, they are not supposed to be used for purposes
#          other than validation and identification, for example:
#          - select correct network interface;
#          - configure service which should be aware of other networks;
#          - validate gateway's IP configuration;
#          - etc.

external_net:

    subnet: 192.168.1.0

    # WARNING: netmask and prefix should be consistent (they define
    #          the same thing).
    #netmask: 255.255.255.0
    netprefix: 24

    broadcast: 192.168.1.255

    # Some forwarders used before:
    # - 141.1.1.198
    # - 128.1.6.64
    # - 10.33.68.94
    dns_server: 8.8.8.8

    gateway: 192.168.1.254

###############################################################################
# EOF
###############################################################################

