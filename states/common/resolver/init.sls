# Configure /etc/resolv.conf

# Both `virtual_machine_hypervisor_role` and `hostname_resolver_role` require `resolv.conf` modifications.
# They cannot get auto-modified `resolv.conf` because they are started
# _before_ DHCP (`virtual_machine_hypervisor_role` hosts all services, `hostname_resolver_role` does not resolve
# before fully up).

{% if grains['id'] in pillar['system_host_roles']['virtual_machine_hypervisor_role']['assigned_hosts'] or grains['id'] in pillar['system_host_roles']['hostname_resolver_role']['assigned_hosts'] %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

/etc/resolv.conf:
    file.managed:
        - source: salt://common/resolver/resolv.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
            selected_pillar: {{ pillar }}

{% endif %}
# >>>
###############################################################################

{% endif %}

