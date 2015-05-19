# Install default Java environments.

{% if grains['kernel'] == 'Linux' %}
{% set config_temp_dir = pillar['posix_config_temp_dir'] %}
{% endif %}
{% if grains['kernel'] == 'Windows' %}
{% set config_temp_dir = pillar['windows_config_temp_dir'] %}
{% endif %}

# Import generic template for Jenkins plugin installation.
{% from 'common/java/java_environments.lib.sls' import install_java_environment with context %}

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('fc') %}

{# if 'allow_package_installation_through_yum' in pillar['system_features'] and pillar['system_features']['allow_package_installation_through_yum']['feature_enabled'] #}

{{ install_java_environment('java-1.8.0-openjdk') }}

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel5') %}

# Default for all Java-dependent packages.
{{ install_java_environment('java-gcj-compat') }}

# Subsequent "upgrade" to overwrite default.
{{ install_java_environment('java-1.7.0-openjdk') }}

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') %}

{{ install_java_environment('java-1.7.0-openjdk') }}

{% endif %} # OS
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

install_observer_java_on_windows:
    cmd.run:
        - name: "echo TODO: java installation"

{% endif %}
# >>>
###############################################################################


