
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set project_name = props['project_name'] %}

system_features:

    # Hostname resolution configuration.
    hostname_resolution_config:

        # See: docs/pillars/common/system_features/hostname_resolution_config/hostname_resolution_type/readme.md
        hostname_resolution_type: static_hosts_file

        # Managed DNS zone for this system.
        #
        # The DNS server is configured in `hostname_resolver_role` role. See `system_host_roles`.
        domain_name: {{ project_name }}.example.com

        # TODO: It is better to use role name to select host (with IP)
        #       rather than specify raw IP address.
        # X server (where X applications can open display).
        # This name will be resolvable by DNS.
        # Normally, it should be the IP of the machine (usually physical) from which
        # developer interacts with the system.
        x_display_server: 142.1.1.1

        # See: docs/pillars/common/system_features/hostname_resolution_config/dns_server_type/readme.md
        dns_server_type: external

        # See: docs/pillars/common/system_features/hostname_resolution_config/dns_server_type/readme.md
        external_dns_server: 8.8.8.8

        # See: docs/pillars/common/system_features/hostname_resolution_config/resolvable_hostname/readme.md
        {% if props['use_internet_http_proxy'] %}
        resolvable_hostname: proxy.example.com
        {% else %}
        resolvable_hostname: google.com
        {% endif %}

        # Networks to be served by DHCP server.
        dchp_networks:

            internal_net_A:
                enabled: False
            internal_net_B:
                enabled: False
            external_net_A:
                enabled: False
            external_net_B:
                enabled: False

        #######################################################################

        # TODO: Add additional networks here.

###############################################################################
# EOF
###############################################################################

