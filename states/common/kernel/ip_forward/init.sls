# Custom kernel configuration.

{% if grains['id'] in pillar['system_host_roles']['network_router_role']['assigned_hosts'] %}

###############################################################################
# <<< The `sysctl.d` dir does not exists on RHEL5.
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}


sysctl_reload:
    cmd.run:
        - name: "systemctl restart systemd-sysctl"
        - require:
            - file: /etc/sysctl.d/ip_forward.conf

/etc/sysctl.d/ip_forward.conf:
    file.managed:
        - source: salt://common/kernel/ip_forward/ip_forward.conf
        - user: root
        - group: root
        - mode: 644

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

    # TODO: If needed, ensure Windows host can route IP packets.

{% endif %}
# >>>
###############################################################################

{% endif %}

