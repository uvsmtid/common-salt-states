# Configure `local_yum_mirrors_role` role.

{% if 'local_yum_mirrors_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['local_yum_mirrors_role']['assigned_hosts'] %}

include:

    - common.webserver.local_yum_mirrors_role

    - common.yum.local_yum_mirrors_role.mirrors_syncer

{% endif %}

{% endif %}

