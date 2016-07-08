# Time service (NTP).

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

ntp_package:
    pkg.installed:
        - name: ntp
        - aggregate: True

ntp_service:
    service.running:
        - name: ntpd
        - enable: True
        - require:
            - pkg: ntp_package

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


