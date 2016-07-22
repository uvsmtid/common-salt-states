# Configure `hostname_resolver_role` role.

{% if 'hostname_resolver_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['hostname_resolver_role']['assigned_hosts'] %}

include:

    - common.resolver
    - common.dhcp

    # TODO: Where is `named`/`bind` DNS server deployment states?
    #- common.dns

{% endif %}

{% endif %}

