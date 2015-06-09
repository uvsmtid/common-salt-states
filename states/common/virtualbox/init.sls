# Virtualization using VirtualBox.

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('rhel7') or grains['os_platform_type'].startswith('fc') %}

# To avoid unnecessary installation,
# require this host to be assigned to `hypervisor_role`.
{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] %}

# NOTE: On F21 this package comes from `rpmfusion-free-updates` yum repository.
#       TODO: Configure `rpmfusion-free-updates` automatically.
install_virtualbox_packages:
    pkg.installed:
        - pkgs:
            - VirtualBox
        - aggregate: True

{% endif %} # hypervisor_role

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os_platform_type'].startswith('win') %}

# TODO

{% endif %}
# >>>
###############################################################################


