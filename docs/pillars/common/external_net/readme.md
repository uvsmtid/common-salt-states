
Key `external_net` configures network which is _not_ supposed to be managed as
part of the system.

In practice, it means that managed system does _not_ control IP address
assignment within this _external_ network.
For example, if DHCP server is configured through Salt,
it will _not_ use parameters from this configuration.

See also [internal_net][1].

[1]: docs/pillars/common/internal_net/readme.md

