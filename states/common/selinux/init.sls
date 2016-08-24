# SELinux configuration

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

selinux_config:
    file.managed:
        - name: /etc/selinux/config
        - source: salt://common/selinux/config
        - template: jinja
        - user: root
        - group: root
        - mode: 644
    cmd.run:
        # OBS-1873: Redefine PATH to include where `ldconfig` may be.
        {% if pillar['system_features']['selinux_settings']['selinux_mode'] == 'enforcing' %}
        - name: "PATH=$PATH:/usr/sbin setenforce 1"
        {% else %}
        - name: "PATH=$PATH:/usr/sbin setenforce 0"
        {% endif %}

{% endif %}
# >>>
###############################################################################

