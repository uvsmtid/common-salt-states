# Configure `openstack-client-role` role.

{% if grains['id'] in pillar['system_host_roles']['openstack-client-role']['assigned_hosts'] %}

include:

    - common.openstack.client

{% endif %}

