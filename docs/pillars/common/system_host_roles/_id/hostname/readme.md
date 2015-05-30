
Field `hostname` specify which hostname will be resolved to
the IP address of the 1st host in the list of [assigned_hosts][1].

In other words, it is possible to access the first host assigned
to the role by this additional hostname.

How hostname is resolved depends on the chosen resolution
method in [hostname_resolution_type][2].

Note that the hostname must not contain any _underscores_ `_` because
they are not allowed in DNS names. This restriction is similar to
restriction for [hostname][4] specified for [system_hosts][5].

See also description for the parent field [system_host_roles][3].

[1]: /docs/pillars/common/system_host_roles/_id/assigned_hosts/readme.md
[2]: /docs/pillars/common/system_features/hostname_resolution_config/hostname_resolution_type/readme.md
[3]: /docs/pillars/common/system_host_roles/readme.md
[4]: /docs/pillars/common/system_hosts/_id/hostname/readme.md
[5]: /docs/pillars/common/system_hosts/readme.md

