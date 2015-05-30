
Key `origin_uri_ssh_path` specifies path to Git repository _relative_ to
user's home directory.

User home directory is identified through [source_system_host][1] which points
to host id in [system_hosts][2] with `hostname` and [primary_user][3]'s
`username`. Combining all this information, it is possible to to form complete
SSH-like URI for Git respository:
```
{{ username }}@{{ hostname }}:{{ origin_uri_ssh_path }}
```

See some [limitations][4] associated with such approach to form SSH-like URI.

[1]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/git/source_system_host/readme.md
[2]: /docs/pillars/common/system_hosts/readme.md
[3]: /docs/pillars/common/system_hosts/_id/primary_user/readme.md
[4]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/git/readme.md#limitations

