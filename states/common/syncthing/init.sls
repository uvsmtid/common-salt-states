# Deploy syncthing service for primary user.

###############################################################################
# [[[
{% if grains['os_platform_type'].startswith('rhel') or grains['os_platform_type'].startswith('fc') %}

# TODO: Use this repository and installation steps (it seems the most popular):
# https://copr.fedorainfracloud.org/coprs/decathorpe/syncthing/
# The steps to enable repository:
#   sudo yum install -y dnf dnf-plugins-core
#   sudo dnf copr enable decathorpe/syncthing
#   sudo dnf install -y syncthing

{% endif %}
# ]]]
###############################################################################

