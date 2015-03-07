
* Add support for generic networking configuration.
  Instead of setting parameters in each machine under `system_hosts`,
  use separate top-level key for network assignments (similar to
  role assignments via `system_host_role`).

* There should be support for mutliple network configurations.
  Each network may have its own DHCP, DNS, and other servers which may or
  may not be managed through Salt.

