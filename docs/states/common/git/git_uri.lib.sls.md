
File `states/common/git/git_uri.lib.sls` is a library with marcos to
obtain URI for Git repositories based on sources [id][1].

There are two marcos at the moment. Both of them take single argument `git_repo_id` which is
one of the sources ids listed in [source_repo_types][2] and it _must_ be mapped to [git][3]
configuration.

Macro `define_git_repo_uri` returns Git repository URI based on all existing
configuration, for example:
```
username@hostname:path/to/repo.git
```

Macro `define_git_repo_uri_maven` returns special format of Git repository URI
to be used in Maven settings, for example:
```
scm:git:ssh://username@hostname:22/~/path/to/repo.git
```

[1]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/readme.md
[2]: /docs/pillars/common/system_features/deploy_environment_sources/source_repo_types/readme.md
[3]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/git/readme.md



