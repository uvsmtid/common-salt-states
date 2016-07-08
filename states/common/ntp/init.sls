# Time service (NTP).

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

ntp_package:
    pkg.installed:
        - name: ntp
        - aggregate: True

ntp_configuration_file:
    file.managed:
        - source: 'salt://common/ntp/ntp.conf'
        - name: '/etc/ntp.conf'
        - template: jinja
        - mode: 644
        - user: root
        - group: root
        - require:
            - pkg: ntp_package

ntp_service:
    service.running:
        - name: ntpd
        - enable: True
        - require:
            - pkg: ntp_package
        - watch:
            - file: ntp_configuration_file

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# TODO: How to configure it automatically?

{% endif %}
# >>>
###############################################################################


