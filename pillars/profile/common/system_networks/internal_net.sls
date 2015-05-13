###############################################################################
# Physical/external network which is accessible to VMs through `router-role`.
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

# Virtual/internal network between all VMs.
# This network configuration is supposed to be private to the system.
internal_net:

    subnet: 192.168.50.0

    # WARNING: netmask and prefix should be consistent (they define
    #          the same thing).
    netmask: 255.255.255.0
    netprefix: 24

    broadcast: 192.168.50.255

    # When development host is Windows (with the first IP on the network,
    # for example, 142.1.1.1), the control host is likely a VM with
    # Linux and its IP, by convention for such special network functions
    # like routing and NAT-ing, should be the last IP on the network,
    # for example, 142.1.1.254.

    dns_server: 8.8.8.8

    # TODO: Add descriptoin to docs.
    # This is a test hostname which is used in bootstrap to ensure
    # DNS settings are correct.
    # Examples:
    #   - Public services like: `google.com`
    resolvable_hostname: google.com

    gateway: 192.168.50.1

###############################################################################
# EOF
###############################################################################

