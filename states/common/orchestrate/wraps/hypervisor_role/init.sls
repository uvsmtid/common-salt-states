# Configure `hypervisor_role` role.

{% if grains['id'] in pillar['system_host_roles']['hypervisor_role']['assigned_hosts'] %}

include:

    - common.libvirt

    # Vagrant is used to deal with all types of VMs.
    - common.vagrant

{% endif %}

