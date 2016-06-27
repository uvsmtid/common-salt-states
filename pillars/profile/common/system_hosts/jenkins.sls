
###############################################################################
#

# Import properties.
{% set properties_path = profile_root.replace('.', '/') + '/properties.yaml' %}
{% import_yaml properties_path as props %}

{% set primary_network = props['primary_network'] %}

{% if 'jenkins' in props['enabled_minion_hosts'].keys() %}

# NOTE: This is not a minion (managed host).
#       This host is only defined to point to some specific IP address
#       by its hostname.

system_hosts:

    jenkins:
        instantiated_by: ~

        # NOTE: Exact platform is not required for non-minion hosts.
        #       It should only point to correct type of OS
        #       (Linux in this case).
        os_platform: rhel5

        hostname: jenkins
        resolved_in: {{ primary_network['network_name'] }}
        consider_online_for_remote_connections: False
        host_networks:
            {{ primary_network['network_name'] }}:
                ip: {{ props['enabled_minion_hosts']['sonar'] }}

        primary_user: default_user

{% endif %}

###############################################################################
# EOF
###############################################################################

