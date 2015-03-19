# Console mouse server.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

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
{% if grains['os'] in [ 'Windows' ] %}

# Not applicable. Nothing to do.

{% endif %}
# >>>
###############################################################################


