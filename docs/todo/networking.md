TODO

* TODO: Add support for generic networking configuration.
  Instead of setting parameters in each machine under `system_hosts`,
  use separate top-level key for network assignments (similar to
  role assignments via `system_host_role`).

* TODO: There should be support for mutliple network configurations.
  Each network may have its own DHCP, DNS, and other servers which may or
  may not be managed through Salt.



* TODO: Fix all hostnames, host ids and host role ids to use `-` instead
  of `_` in their names. Using underscore `_` violates rules for
  hostnames. And commands on some platforms fail due to this.
  Even though host ids are not addded to hostsfiles or DNS entries, it is
  still better to change them for consistency.

