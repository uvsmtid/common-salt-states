# /etc/hosts file

{% set hostname_res = pillar['system_features']['hostname_resolution_config'] %}

{% if hostname_res['hostname_resolution_type'] == 'static_hosts_file' %}

# Set this `if`-guard agains Windows when the following issue
# for `file.blockreplace` (not just `file.replace`) appears again
# https://github.com/saltstack/salt/issues/11471
# if grains['os'] not in [ 'Windows' ]

managed_hosts_file:
    file.blockreplace:
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}
        - name: '/etc/hosts'
{% endif %}
{% if grains['os'] in [ 'Windows' ] %}
        - name: 'C:\Windows\system32\drivers\etc\hosts'
{% endif %}
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}
        - user: root
        - group: root
        - mode: 644
{% endif %}
        - backup: '.salt.backup'
        - append_if_not_found: True
        - marker_start: "# <<< AUTOMATICALLY MANAGED by Salt"
        - content: |
            # Host `salt` is the host assigned for `controller-role` role.
            {% set selected_role = 'controller-role' %}
            {% if pillar['system_host_roles'][selected_role]['assigned_hosts']|length != 0 %}
            {% set selected_minion_id = pillar['system_host_roles'][selected_role]['assigned_hosts'][0] %}
            {% set selected_host = pillar['system_hosts'][selected_minion_id] %}
            {% set selected_net = selected_host['defined_in'] %}
            {{ selected_host[selected_net]['ip'] }} salt salt.{{ hostname_res['domain_name'] }}
            {% endif %}

            # Set `x_display_server` based on pillar configuration.
            {{ hostname_res['x_display_server'] }} x_display_server x_display_server.{{ hostname_res['domain_name'] }}

            # Hosts by their hostname.
            {% for selected_host in pillar['system_hosts'].values() %}
            {% set selected_net = selected_host['defined_in'] %}
            {{ selected_host[selected_net]['ip'] }} {{ selected_host['hostname'] }} {{ selected_host['hostname'] }}.{{ hostname_res['domain_name'] }}
            {% endfor %}

            # Hosts by their role (the first in the list of assigned hosts).
            {% for selected_role in pillar['system_host_roles'].keys() %}
            {% if pillar['system_host_roles'][selected_role]['assigned_hosts']|length != 0 %}
            {% set selected_minion_id = pillar['system_host_roles'][selected_role]['assigned_hosts'][0] %}
            {% set selected_host = pillar['system_hosts'][selected_minion_id] %}
            {% set selected_net = selected_host['defined_in'] %}
            {{ selected_host[selected_net]['ip'] }} {{ selected_role }} {{ selected_role }}.{{ hostname_res['domain_name'] }}
            {% endif %}
            {% endfor %}
        - marker_end:   "# >>> AUTOMATICALLY MANAGED by Salt"


{% endif %} # `hostname_resolution_type`

