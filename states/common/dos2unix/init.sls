# Install `dos2unix` package.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

dos2unix_package:
    pkg.installed:
        - name: dos2unix
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

include:
    - common.cygwin.package

{% endif %}
# >>>
###############################################################################


