# Configure `maven_build_server_role` role.

{% if grains['id'] in pillar['system_host_roles']['maven_build_server_role']['assigned_hosts'] %}

include:

    - common.maven

{% endif %}

