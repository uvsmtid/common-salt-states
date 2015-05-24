# Configure /etc/resolv.conf

# Both `hypervisor_role` and `resolver_role` require `resolv.conf` modifications.
# They cannot get auto-modified `resolv.conf` because they are started
# _before_ DHCP (`hypervisor_role` hosts all services, `resolver_role` does not resolve
# before fully up).

{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] or grains['id'] in pillar['system_host_roles']['resolver_role']['assigned_hosts'] %}

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

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

