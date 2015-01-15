# Global snmpd configuration for the node.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

snmp:

{% if pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}

    pkg.installed:
        - pkgs:
            - net-snmp
            - net-snmp-utils
{% endif %}

    service.running:
        - name: snmpd
        - enable: True
{% if pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}
        - require:
            - pkg: snmp
{% endif %}
        - watch:
            - file: /etc/snmp/snmpd.conf

snmpd_conf:
    file.managed:
        - name: /etc/snmp/snmpd.conf
        - source: salt://common/snmp/snmpd.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja


{% endif %}
# >>>
###############################################################################

