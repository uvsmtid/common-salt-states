
Key `source_repo_types` specifies a map between [unique id][1] of sources
used by the project_name and their corresponding repository type.

It is possible to support various types of repositories, for example:
* `git` specifies [Git](http://git-scm.com/) and selects its [git][2]-specific configuration
* `svn` specifies [Subversion](http://subversion.apache.org/) and selects its [svn][3]-specific configuration

Combinded with unique id of the sources, the repository type value
(mapped through `source_repo_types`) is later used to select related
configuration under [source_repositories][4].

[1]: docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/readme.md
[2]: docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/git/readme.md
[3]: docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/svn/readme.md
[4]: docs/pillars/common/system_features/deploy_environment_sources/source_repositories/readme.md

