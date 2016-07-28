# Install default Java environments.

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
{% if grains['os_platform_type'].startswith('win') %}

install_default_java_on_windows:
    cmd.run:
        - name: "echo TODO: java installation"

{% endif %}
# >>>
###############################################################################


