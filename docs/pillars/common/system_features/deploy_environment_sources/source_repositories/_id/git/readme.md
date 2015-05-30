
Key `git` sepecifies [Git](http://git-scm.com/) source control system to manage
sources specified as [id][1] to [source_repositories][2] dictionary and
provides configuration to access them.

## Limitations ##

TODO: Provide concise and generic solution to the following problem.

Note that if Git repository has _arbitrary_ SSH-like URI which cannot be
determined through host id in [source_system_host][3] and its primary user,
it is currently _impossible_ to specify such URL.

For example, if non-primary user provides repository on
host identified by `source_system_host` or if `source_system_host` is not
listed in [system_hosts][4] at all, then there is technically no enough
information to generate such URL.

However, this is not supposed to be a problem in many cases.
For example, if Git repository is hosted on some arbitrary unmanaged host
like `git.example.com` under [GitLab][http://gitlab.com/] and accessed
with SSH public key authentication via SSH-like URI
`git@git.example.com:devops/common-salt-states.git`, it is possible to define
such `git.example.com` host under `system_hosts` with [primary_user][5] equal
to `git` and set [origin_uri_ssh_path][6] to `devops/common-salt-states.git`:
```
system_hosts:
    git.example.com:
        consider_online_for_remote_connections: False
        os_platform: rhel7
        hostname: git.example.com
        primary_user:
            username: git
system_features:
    deploy_environment_sources:
        source_repositories:
            'common-salt-states':
                git:
                    source_system_host: 'git.example.com'
                    origin_uri_ssh_path: 'devops/common-salt-states.git'
```
It important that:
* There should not be Salt minion named as `git.example.com` and listed as accepted in the output of `salt-key` command.
* Key [consider_online_for_remote_connections][7] should be False to avoid contacts with this host during various deployment stages (i.e. to distribute SSH keys).

[1]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/readme.md
[2]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/readme.md
[3]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/git/source_system_host/readme.md
[4]: /docs/pillars/common/system_hosts/readme.md
[5]: /docs/pillars/common/system_hosts/_id/primary_user/readme.md
[6]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/git/origin_uri_ssh_path/readme.md
[7]: /docs/pillars/common/system_hosts/_id/consider_online_for_remote_connections/readme.md

