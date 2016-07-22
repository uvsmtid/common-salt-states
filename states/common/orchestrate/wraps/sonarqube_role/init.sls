# Configure `sonarqube_role` role.

{% if 'sonarqube_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['sonarqube_role']['assigned_hosts'] %}

include:

    - common.mariadb
    - common.sonarqube

{% endif %}

{% endif %}

