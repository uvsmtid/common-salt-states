# Install `wget` package.

include:
# Install `wget` for Windows through installing Cygwin.
{% if grains['os_platform_type'].startswith('win') %}
    - common.cygwin.package
{% endif %}
    - common.dummy

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

wget_package:
    pkg.installed:
        - name: wget
        - aggregate: True

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


