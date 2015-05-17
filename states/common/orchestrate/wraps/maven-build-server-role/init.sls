# Configure `maven-build-server-role` role.

{% if grains['id'] in pillar['system_host_roles']['maven-build-server-role']['assigned_hosts'] %}

include:

    - common.maven

{% endif %}

