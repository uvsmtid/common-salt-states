TODO

* TODO: Add support for generic networking configuration.
  Instead of setting parameters in each machine under `system_hosts`,
  use separate top-level key for network assignments (similar to
  role assignments via `system_host_role`).

*   TODO: There should be support for multiple network configurations.
    Each network may have its own DHCP, DNS, and other servers which may or
    may not be managed through Salt.

    At the moment there is only multiple networks.
    However, it is not clear how setup of DHCP or DNS is being
    automated to select service on which node manage which networks.

