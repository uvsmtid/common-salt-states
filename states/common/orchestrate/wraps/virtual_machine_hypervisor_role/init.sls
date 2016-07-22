# Configure `virtual_machine_hypervisor_role` role.

{% if 'virtual_machine_hypervisor_role' in pillar['system_host_roles'] %}

{% if grains['id'] in pillar['system_host_roles']['virtual_machine_hypervisor_role']['assigned_hosts'] %}

include:

    - common.resolver
    - common.libvirt

    # Vagrant is used to deal with all types of VMs.
    - common.vagrant

{% endif %}

{% endif %}

