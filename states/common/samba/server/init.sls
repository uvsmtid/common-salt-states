# Samba server - see:
#   https://www.samba.org/

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

samba_server_package:
    pkg.installed:
        - name: samba

samba_server_configuration_file:
    file.managed:
        - source: 'salt://common/samba/server/smb.conf'
        - name: '/etc/samba/smb.conf'
        - template: jinja
        - mode: 644
        - user: root
        - group: root
        - require:
            - pkg: samba_server_package

samba_service:
    service.running:
        - name: smb
        - enable: True
        - require:
            - pkg: samba_server_package
        - watch:
            - file: samba_server_configuration_file

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


