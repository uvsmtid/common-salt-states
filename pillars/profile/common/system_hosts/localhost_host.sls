
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

# NOTE: `localhost_host` is always defined.
{% if 'localhost_host' %}

# NOTE: This is not a minion (managed host).
#       This host is only defined to point to some specific IP address
#       by its hostname.
#
#       Specifically, Jenkins Slave which is connected to master via
#       localhost address.

system_hosts:

    localhost_host:
        instantiated_by: ~

        # NOTE: Exact platform is not required for non-minion hosts.
        #       It should only point to correct type of OS
        #       (Linux in this case).
        os_platform: rhel7

        hostname: localhost-host
        resolved_in: localhost_net
        # NOTE: Any host can be connected to itself via localhost address.
        consider_online_for_remote_connections: True
        host_networks:
            localhost_net:
                ip: 127.0.0.1

        primary_user: default_user

{% endif %}

###############################################################################
# EOF
###############################################################################

