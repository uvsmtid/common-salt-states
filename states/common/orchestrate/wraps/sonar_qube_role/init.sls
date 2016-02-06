# Configure `sonar_qube_role` role.

{% if grains['id'] in pillar['system_host_roles']['sonar_qube_role']['assigned_hosts'] %}

include:

    # TODO
    - common.mariadb
    - common.sonarqube

{% endif %}

