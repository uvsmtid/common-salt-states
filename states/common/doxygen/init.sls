# Install `doxygen` packages.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

doxygen_package:
    pkg.installed:
        - name: doxygen
        - aggregate: True

graphviz_package:
    pkg.installed:
        - name: graphviz
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


