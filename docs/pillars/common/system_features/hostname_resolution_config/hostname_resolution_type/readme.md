
Key `hostname_resolution_type` specifies type of hostname resolution used
within managed system.

Host name resolution can be achieved by multiple means.

Even for DNS there are two types considered:

*   `named_and_dhcpd_services`

    This option configures ISC BIND DNS and DHCP services.

    There is a problem with `libvirt` which enforces `dnsmasq` service
    in each virtual network. And it conflicts with both DNS and DHCP
    services which are configured through this option on the same network
    separately.

*   `libvirtd_dnsmasq`

    This configures `dnsmasq` through `libvirtd`.

    Use this option only when host with role `virtual_machine_hypervisor_role` is also
    assigned `hostname_resolver_role` role and `libvirt` is running
    on `virtual_machine_hypervisor_role` (typically, KVM virtualization).

The last one is the simplest type:

*   `static_hosts_file`

    This options pushes all names in hosts file.
    It is not recommended because it does not provide DHCP and IP
    configuration should be done manually for all minions.

