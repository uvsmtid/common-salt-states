# Set timezone

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

tzdata_package:
    pkg.installed:
        - name: tzdata

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
{% if grains['os'] in [ 'Windows' ] %}

# TODO: Implement time zone configuration on Windows.

{% endif %}
# >>>
###############################################################################


