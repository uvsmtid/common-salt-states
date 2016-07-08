# Configure `time_server_role` role.

{% if 'time_server_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['time_server_role']['assigned_hosts'] %}

include:

    # Normally, NTP service is installed by default.
    # Hosts assigned to `time_server_role` are simply configured differently.
    - common.ntp

{% endif %}

{% endif %}

