
## Conventions to locate pillar documentation ##

Each document under this directory provides documentation for corresponding
elements in pillar data strucutre used by `common` project, for example:
* [File][1] `system_hosts/readme.md` documents pillar data accessed as: `pillar['system_hosts']`.
* [File][2] `registered_content_config/URI_prefix.md` documents pillar data accessed as: `pillar['registered_content_config']['URI_prefix']`.
* [File][3] `system_host_roles/jenkins_master_role/readme.md` documents pillar data accessed as: `pillar['system_host_roles']['jenkins_master_role']`.
* [File][4] `system_hosts/_id/hostname.md` documents all similar pillar data accessed using any `_id` as: `pillar['system_hosts'][_id]`

NOTE:
* All `*.md` files document pillar keys matching their name without `.md` extension (except `readme.md`).
* File `readme.md` documents pillar key named after its _parent_ directory.
* Special directory `_id` is used to indicate a _variable_ key (id) for a collection of objects (i.e. definitions of system hosts, SCM repositories, etc.).

[1]: docs/pillars/common/system_hosts/readme.md
[2]: docs/pillars/common/registered_content_config/URI_prefix.md
[3]: docs/pillars/common/system_host_roles/jenkins_master_role/readme.md
[4]: docs/pillars/common/system_hosts/_id/hostname.md

