# Samba server - see:
#   https://www.samba.org/

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

samba_server_package:
    pkg.installed:
        - name: samba

samba_service:
    service.running:
        - name: smb
        - enable: True
        - require:
            - pkg: samba_server_package

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


