
Key `hostname` configures hostname for the managed minion.

How hostname is resolved depends on the chosen resolution
method in [hostname_resolution_type][2].

Note that the hostname must not contain any _underscores_ `_` because
they are not allowed in DNS names. This restriction is similar to
restriction for [hostname][4] specified for [system_host_roles][5].

[2]: /docs/pillars/common/system_features/hostname_resolution_config/hostname_resolution_type/readme.md
[4]: /docs/pillars/common/system_host_roles/_id/hostname/readme.md
[5]: /docs/pillars/common/system_host_roles/readme.md

