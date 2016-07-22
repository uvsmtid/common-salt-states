# Configure `network_router_role` role.

{% if 'network_router_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['network_router_role']['assigned_hosts'] %}

include:

    - common.kernel.ip_forward

{% endif %}

{% endif %}

