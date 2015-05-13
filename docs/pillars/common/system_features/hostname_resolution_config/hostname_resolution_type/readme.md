
Key `hostname_resolution_type` specifies type of hostname resolution used
within managed system.

Host name resolution can be acheived by multiple means.

Even for DNS there are two types considered:
* `named_and_dhcpd_services`
   This option configures ISC BIND DNS and DHCP services.
   The problem is that `libvirt` enforces `dnsmasq` service in each
   virtual netwrok and it conflicts with both DNS and DHCP. Therefore,
   when host with role `hypervisor_role` is also assigned `resolver-role` role
   and `libvirt` is running on `hypervisor_role` (typically, KVM environments),
   use this option.
* `libvirtd_dnsmasq`
   This option should be used in opposite condition described for
   `named_and_dhcpd_services` value. This configures `dnsmasq` through
   `libvirtd`.

The last one is the simplest type:
* `static_hosts_file`
   This options pushes all names in hosts file.
   It is not recommended because it does not provide DHCP and IP
   configuration should be done manually for all minions.

