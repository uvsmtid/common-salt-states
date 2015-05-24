# Configure `openstack_client_role` role.

{% if grains['id'] in pillar['system_host_roles']['openstack_client_role']['assigned_hosts'] %}

include:

    - common.openstack.client

{% endif %}

