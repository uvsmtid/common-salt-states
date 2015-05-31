
Key `external_net` configures network which is _not_ supposed to be managed as
part of the system.

In practice, it means that managed system does _not_ control IP address
assignment within this _external_ network. For example, there could be
a DHCP server on this network out of Salt control, or the network may
have assigned IP addresses.

One of the practical consequences is that DHCP server which is configured
through Salt will _not_ use parameters from `external_net`. Instead,
it will always use [internal_net][1].

[1]: /docs/pillars/common/system_networks/internal_net/readme.md

