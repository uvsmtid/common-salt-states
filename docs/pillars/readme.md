
## Conventions to locate pillar documentation ##

Documents under this directory provide documentation for corresponding
elements in pillar data strucutre used by a given project_name.

The pillar data structure corresponds one-to-one with this
directory structure.

For example, documentation for all pillar elements used by `common` project
are under `common` sub-directory and match the following way:
* [File][1] `system_hosts/readme.md` documents pillar data accessed as: `pillar['system_hosts']`.
* [File][2] `registered_content_config/URI_prefix/readme.md` documents pillar data accessed as: `pillar['registered_content_config']['URI_prefix']`.
  TODO: Use another example `pillar['registered_content_config']['URI_prefix']` is not used anymore.
* [File][3] `system_host_roles/jenkins_master_role/readme.md` documents pillar data accessed as: `pillar['system_host_roles']['jenkins_master_role']`.
* [File][4] `system_hosts/_id/hostname/readme.md` documents pillar data accessed using any `_id` as: `pillar['system_hosts'][_id]['hostname'].`

NOTE:
* All `readme.md` files document pillar keys matching pillar key named after its _parent_ directory.
* Special directory `_id` is used to indicate a _variable_ key (id) for a collection of objects (i.e. definitions of system hosts, SCM repositories, etc.).
* This is different convention compared to ["states" directory convention](docs/states/readme.md) where each document file one-to-one corresponds to a _file_ (not a pillar _data item_).

[1]: docs/pillars/common/system_hosts/readme.md
[2]: docs/pillars/common/registered_content_config/URI_prefix/readme.md
[3]: docs/pillars/common/system_host_roles/jenkins_master_role/readme.md
[4]: docs/pillars/common/system_hosts/_id/hostname/readme.md

## Conventions to locate documentation for files under `pillars` directory ##

The pillar namespace is [flattened](http://docs.saltstack.com/en/latest/topics/pillar/#pillar-namespace-flattened).
In other words, it does not matter which pillar file specific key comes from - all
referenced pillar files will be considered as a single whole.

So, how to document specific pillar _file_ (not pillar _data item_)?

Mixing
(1) documentation matching one-to-one pillar data structure with directory structure
_and_
(2) documentation of specific pillar file is avoided.
In other words, all files under `docs/pillars/common` _always_ resemble pillar
data structure used for `common` project_name and nothing else.

Instead, general layout conventions for all files are documented in [docs/structure_and_conventions.md](docs/structure_and_conventions.md) and clarified in related project_name documentation.
And because number of files under `pillars` is rather small,
there is no strong need for such convention.


