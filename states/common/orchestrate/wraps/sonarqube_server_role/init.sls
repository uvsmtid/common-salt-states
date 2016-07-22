# Configure `sonarqube_server_role` role.

{% if 'sonarqube_server_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['sonarqube_server_role']['assigned_hosts'] %}

include:

    - common.mariadb
    - common.sonarqube

{% endif %}

{% endif %}

