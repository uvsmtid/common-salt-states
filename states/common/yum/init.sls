# Global yum configuration for the node.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

yum_conf:
    file.managed:
        - name: /etc/yum.conf
        - source: salt://common/yum/yum.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja

{% endif %}
# >>>
###############################################################################

