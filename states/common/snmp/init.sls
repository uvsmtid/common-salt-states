# Global snmpd configuration for the node.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

snmp:
    pkg.installed:
        - pkgs:
            - net-snmp
            - net-snmp-utils
    service.running:
        - name: snmpd
        - enable: True
        - require:
            - pkg: snmp
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

