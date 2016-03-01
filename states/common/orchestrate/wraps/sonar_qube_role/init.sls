# Configure `sonar_qube_role` role.

{% if 'sonar_qube_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['sonar_qube_role']['assigned_hosts'] %}

include:

    - common.mariadb
    - common.sonarqube

{% endif %}

{% endif %}

