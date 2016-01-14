# Install list of packages based on `grains['os_platform_type']`.

###############################################################################
# <<<

# NOTE: Only Linux-based distributions are currently
#       supported for package installation.

{% if grains['kernel'] in [ 'Linux' ] %}

{% for os_platform_type in pillar['system_features']['packages_per_os_platfrom_type'].keys() %}

{% if grains['os_platform_type'].startswith(os_platform_type) %}

{% for package_name in pillar['system_features']['packages_per_os_platfrom_type'][os_platform_type] %}

packages_per_os_platfrom_type_{{ os_platform_type }}_{{ package_name }}:
    pkg.installed:
        - name: {{ package_name }}
        - aggregate: True

{% endfor %}

{% endif %}

{% endfor %}

{% endif %}

# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# Not applicable. Nothing to do.

{% endif %}
# >>>
###############################################################################


