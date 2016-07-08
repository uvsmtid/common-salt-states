# Test availability of time servers.

{% if pillar['system_features']['time_configuration']['use_time_server_role'] %} # use_time_server_role

{% if grains['id'] in pillar['system_host_roles']['time_server_role']['assigned_hosts'] %} # time_server_role

# Test `time_server_role_parent_stratum_servers` for hosts
# assigned to `time_server_role`.
{% for time_server in pillar['system_features']['time_configuration']['time_server_role_parent_stratum_servers'] %} # time_server_role
test_parent_stratum_servers_ntp_service_availability_{{ time_server }}:
    cmd.run:
        - name: 'ntpdate -q {{ time_server }}'

{% endfor %}

{% else %} # time_server_role

# For every other host, list hosts assigned to `time_server_role`.
{% for time_server_host_id in pillar['system_host_roles']['time_server_role']['assigned_hosts'] %}
{% set time_server_host_config = pillar['system_hosts'][time_server_host_id] %}
test_time_server_role_ntp_service_availability_{{ time_server_host_config['hostname'] }}:
    cmd.run:
        - name: 'ntpdate -q {{ time_server_host_config['hostname'] }}'
{% endfor %}

{% endif %} # time_server_role

{% else %} # use_time_server_role

{% endif %} # use_time_server_role

