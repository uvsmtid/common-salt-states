
Key `internal_net` configures network which is supposed to be managed as
part of the system (not externally).

In practice, it means that managed system is in control of IP address
assignment within this _internal_ network.
For example, if DHCP server is configured through Salt,
it will use parameters from `internal_net` configuration.

Note that `internal_net` may still be seen everywhere else and be routable
to and from. In other words, it does not mean it is
necessarily a [private network][2].

See also [external_net][1].

[1]: docs/pillars/common/system_networks/external_net/readme.md
[2]: https://en.wikipedia.org/wiki/Private_network

