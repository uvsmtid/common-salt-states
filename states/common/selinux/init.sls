# SELinux configuration

###############################################################################
# <<< Any RedHat-originated OS
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

selinux_config:
    file.managed:
        - name: /etc/selinux/config
        - source: salt://common/selinux/config
        - user: root
        - group: root
        - mode: 644
    cmd.run:
        - name: "setenforce 0"

{% endif %}
# >>>
###############################################################################

