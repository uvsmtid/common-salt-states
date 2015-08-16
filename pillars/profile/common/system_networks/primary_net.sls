
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

system_networks:

    # TODO: Add docs.
    #
    # Primary network is available on hypervisor without any virtualized
    # network interfaces.
    #
    # It is important to resolve master hostname on this network
    # (otherwise it won't be reachible until virtual networks are created).
    {{ primary_network['network_name'] }}:

        # AKA "network address":
        subnet: {{ primary_network['network_ip_subnet'] }}

        # WARNING: netmask and prefix should be consistent
        #          (they define the same thing).
        netmask: {{ primary_network['network_ip_netmask'] }}
        netprefix: {{ primary_network['network_ip_netprefix'] }}

        broadcast: {{ primary_network['network_ip_broadcast'] }}

        # Default route.
        gateway: {{ primary_network['network_ip_gateway'] }}

###############################################################################
# EOF
###############################################################################

