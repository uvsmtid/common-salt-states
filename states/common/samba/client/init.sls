# Samba client - see:
#   https://www.samba.org/

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

samba_client_package:
    pkg.installed:
        - name: samba-client

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# Nothing to do. Maybe enable only?

{% endif %}
# >>>
###############################################################################


