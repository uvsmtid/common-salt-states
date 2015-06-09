# Console mouse server.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

gpm_package:
    pkg.installed:
        - name: gpm
        - aggregate: True

gpm_service:
    service.running:
        - name: gpm
        - enable: True

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


