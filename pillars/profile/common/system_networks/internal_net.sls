###############################################################################
#

# See: docs/pillars/common/internal_net/readme.md
internal_net:

    subnet: 192.168.50.0

    # WARNING: netmask and prefix should be consistent
    #          (they define the same thing).
    netmask: 255.255.255.0
    netprefix: 24

    broadcast: 192.168.50.255

    gateway: 192.168.50.1

###############################################################################
# EOF
###############################################################################

