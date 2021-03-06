# Global snmpd configuration for the node.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

{% if pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}
install_snmp_packages:
    pkg.installed:
        - pkgs:
            - net-snmp
            - net-snmp-utils
        - aggregate: True
{% endif %}

enable_snmp_service:
    service.running:
        - name: snmpd
        - enable: True
{% if pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}
        - require:
            - pkg: install_snmp_packages
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
{% if pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] %}
        - require:
            - pkg: install_snmp_packages
{% endif %}


{% endif %}
# >>>
###############################################################################

