# /etc/hosts file

{% set hostname_res = pillar['system_features']['hostname_resolution_config'] %}

{% if hostname_res['hostname_resolution_type'] == 'static_hosts_file' %}

# Set this `if`-guard agains Windows when the following issue
# for `file.blockreplace` (not just `file.replace`) appears again
# https://github.com/saltstack/salt/issues/11471
# if not grains['os_platform_type'].startswith('win')

managed_hosts_file:
    file.blockreplace:
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}
        - name: '/etc/hosts'
{% endif %}
{% if grains['os_platform_type'].startswith('win') %}
        - name: 'C:\Windows\system32\drivers\etc\hosts'
{% endif %}
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}
        #{# DISABLED: `file.exists` does not support this (yet)
        - user: root
        - group: root
        - mode: 644
        #}#
{% endif %}
        - backup: '.salt.backup'
        - append_if_not_found: True
        - marker_start: "# <<< AUTOMATICALLY MANAGED by Salt"
        - content: |
            # Host `salt` is the host assigned for `salt_master_role` role.
            {% set selected_role_id = 'salt_master_role' %}
            {% if pillar['system_host_roles'][selected_role_id]['assigned_hosts']|length != 0 %}
            {% set selected_minion_id = pillar['system_host_roles'][selected_role_id]['assigned_hosts'][0] %}
            {% set selected_host = pillar['system_hosts'][selected_minion_id] %}
            {% set selected_net = selected_host['resolved_in'] %}
            {% if selected_minion_id == grains['id'] %}
            # If this hosts file belongs to this minion, use localhost address.
            127.0.0.1 salt salt.{{ hostname_res['domain_name'] }}
            {% else %}
            {{ selected_host['host_networks'][selected_net]['ip'] }} salt salt.{{ hostname_res['domain_name'] }}
            {% endif %}
            {% endif %}

            # Set `x_display_server` based on pillar configuration.
            {{ hostname_res['x_display_server'] }} x_display_server x_display_server.{{ hostname_res['domain_name'] }}

            # Hosts by their hostname.
            {% for selected_minion_id in pillar['system_hosts'].keys() %}
            {% set selected_host = pillar['system_hosts'][selected_minion_id] %}
            {% set selected_net = selected_host['resolved_in'] %}
            # NOTE: Resoving hostname into local IP address
            #       breaks some test cases (they determing it as `localhost`)
            #       deep inside some framework code which is hard to resolve.
            #       The solution is to avoid using local IP addresses
            #       in this case.
            {{ selected_host['host_networks'][selected_net]['ip'] }} {{ selected_host['hostname'] }} {{ selected_host['hostname'] }}.{{ hostname_res['domain_name'] }}
            #{# DISABLED: Instead, use IP address from the network
              #           where minion is defined.
            {% if selected_minion_id == grains['id'] %}
            # If this hosts file belongs to this minion, use localhost address.
            127.0.0.1 {{ selected_host['hostname'] }} {{ selected_host['hostname'] }}.{{ hostname_res['domain_name'] }}
            {% else %}
            {{ selected_host['host_networks'][selected_net]['ip'] }} {{ selected_host['hostname'] }} {{ selected_host['hostname'] }}.{{ hostname_res['domain_name'] }}
            {% endif %}
            #}#
            {% endfor %}

            # Hosts by their role (the first in the list of assigned hosts).
            {% for selected_role_id in pillar['system_host_roles'].keys() %}
            {% if pillar['system_host_roles'][selected_role_id]['assigned_hosts']|length != 0 %}
            {% set selected_role = pillar['system_host_roles'][selected_role_id] %}
            {% set selected_minion_id = pillar['system_host_roles'][selected_role_id]['assigned_hosts'][0] %}
            {% set selected_host = pillar['system_hosts'][selected_minion_id] %}
            {% set selected_net = selected_host['resolved_in'] %}
            {% if selected_minion_id == grains['id'] %}
            # If this hosts file belongs to this minion, use localhost address.
            127.0.0.1 {{ selected_role['hostname'] }} {{ selected_role['hostname'] }}.{{ hostname_res['domain_name'] }}
            {% else %}
            {{ selected_host['host_networks'][selected_net]['ip'] }} {{ selected_role['hostname'] }} {{ selected_role['hostname'] }}.{{ hostname_res['domain_name'] }}
            {% endif %}
            {% endif %}
            {% endfor %}
        - marker_end:   "# >>> AUTOMATICALLY MANAGED by Salt"


{% endif %} # `hostname_resolution_type`

