
Key `source_system_host` specifies host id to select host configuration
from [sytem_hosts][1] collection.

There are multipe use cases for this parameter.

## SSH-like URIs to Git repositories ##

Cupled with [origin_uri_ssh_path][4], this provides enough information
to form complete SSH-like URI for Git respository.

## Ids for Jenkins credentials ##

This is also used to access [hostname][2] and [primary_user][3]'s username
from host configuration to compose Jenkins credentials id.

## Access to all sources on Salt minions ##

State [common.source_symlinks][5] determines location of sources on Salt master
to expose repositories to Salt minions in Salt states using `salt://` URI
scheme.

The state combines [primary_users][3]'s home directory in [posix_user_home_dir][6]
to set symlink's target on Salt master (if host identified by `source_system_host`
is actually the Salt master).

[1]: /docs/pillars/common/system_host_roles/readme.md
[2]: /docs/pillars/common/system_hosts/_id/hostname/readme.md
[3]: /docs/pillars/common/system_hosts/_id/primary_user/readme.md
[4]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/git/origin_uri_ssh_path/readme.md
[5]: /docs/states/common/source_symlinks/init.sls.md
[6]: /docs/pillars/common/system_hosts/_id/primary_user/posix_user_home_dir/readme.md

