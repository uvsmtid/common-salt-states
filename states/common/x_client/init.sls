# Configuration for hosts which may run X applications displaying them on
# remote X server.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

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


