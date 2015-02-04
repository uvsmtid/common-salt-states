# Virtualization using VirtualBox.

###############################################################################
# <<<
{% if grains['os'] in [ 'Fedora' ] %}

# To avoid unnecessary installation,
# require this host to be assigned to `hypervisor_role`.
{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] %}

# NOTE: On F21 this package comes from `rpmfusion-free-updates` yum repository.
#       TODO: Configure `rpmfusion-free-updates` automatically.
install_virtualbox_packages:
    pkg.installed:
        - pkgs:
            - VirtualBox

{% endif %} # hypervisor_role

{% endif %}
# >>>
###############################################################################

###############################################################################
# <<<
{% if grains['os'] in [ 'Windows' ] %}

# TODO

{% endif %}
# >>>
###############################################################################


