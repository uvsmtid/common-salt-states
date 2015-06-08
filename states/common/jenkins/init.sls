# Jenkins
#
# Currently, this file does nothing.
#
# See also (sub) state files:
#   master.sls
#   slave.sls
#

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

{% endif %}
# >>>
###############################################################################


