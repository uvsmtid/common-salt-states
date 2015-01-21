# Configuration for hosts which may run X applications displaying them on
# remote X server.

###############################################################################
# <<<
{% if grains['os'] in [ 'RedHat', 'CentOS', 'Fedora' ] %}

x_client_packages:
    pkg.installed:
        - names:
            # This is required on remote host for SSH X Forwarding to
            # work there:
            - xorg-x11-xauth
            # This is also needed for something:
            - xorg-x11-utils

            # X apps for quick testing:
            - xorg-x11-apps

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}


{% endif %}
# >>>
###############################################################################


