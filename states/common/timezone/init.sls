# Set timezone

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

tzdata_package:
    pkg.installed:
        - name: tzdata
        - aggregate: True

/etc/localtime:
    file.symlink:
        - target: /usr/share/zoneinfo/{{ pillar['system_features']['time_configuration']['timezone'] }}
        # Force symlink (it appears that RHEL5 by default has file instead).
        - force: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# TODO: Implement time zone configuration on Windows.

{% endif %}
# >>>
###############################################################################


