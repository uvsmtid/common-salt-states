
TODO:
*   Update the document after release.
    This document was created for branch `release-v0.0.0`
    before release `v0.0.0` was made and it's also mixed
    with informatio which were only in `develop` branch at the time
    of writting.
*   Instead of specifying how particular configuration and pillar
    fields should be changed, use links to relevant document under
    `docs` directory.

# Introduction #

This document is only required to build bootstrap packages. Using bootstrap
package is much simpler exercise - see [deploy document][9].

Note that configuring Salt to build bootstrap packages involves many details.

It is already confusing because in addition to typical Salt configuration
with files for `states` and `pillars`, this framework multiplies
them by `project_name`-related files. Bootstrap in addition to this requires
distinguishing source and target environments which at least adds one more
pillars repository (or a branch within it):

*   Source pillar

    This is familiar pillar data which can be seen by running
    the following command:

    ```
    sudo salt-call pillar.items
    ```

*   Target pillar

    Target pillar is the same familiar pillar data for the target
    environment where bootstrap package is to be deployed.

    It is loaded under [`bootstrap_target_envs`][15] top-level field in
    the source pillar. Therefore, it can also be seen by running
    the same command - look for `bootstrap_target_envs` key:

    ```
    sudo salt-call pillar.items | grep 'bootstrap_target_envs'
    ```

To compliacate things more, it is theoretically possible that source
environment is configured to manage one project and target environment
manages another project. This document assumes that both environments
use single `project_name` and only `profile_name`s are different.

# Initial conditions #

Note that bootstrap package is always built on Salt master.
And, therefore, it is a Linux environment.

It is assumed that the Salt environment is already:
*   [installed][6]
*   [configuration][7]
*   [running][8]

The [checklist][0] is assumes the following initial conditions
in addition to those mentioned in [Salt configuration][7] document

*   `project_name="PROJECT_NAME"`

    Arbitrary meaningful name to consistent with repository names.

*   `default_username="$(whoami)"`

    It is recommended to use regular user (rather than `root`).

*   Bootstrap environments:

    *   Source profile name is `SRC_env_profile`.

        Arbitrary name for pillar profile which defines environment
        where bootstrap package is to be bulid.
        Conventionally, it can be named after
        Salt minion id of collocated with Salt master.

    *   Target profile name is `TRG_env_profile`.

        Similar to `SRC_env_profile` for target environment where bootstrap
        package is to be [deployed][9].

*   Repositories:

    *   [common-salt-states][1]
        - Salt states common for other projects.

        *   Repo is checked out in local path: `~/Works/common-salt-states.git`

    *   [common-salt-resources][2]
        - resources used by common salt states.

        *   Repo is checked out in local path: `~/Works/common-salt-resources.git`

    *   [project_name-salt-states][3]
        - Salt states specific to project_name project.

        *   Repo is checked out in local path: `~/Works/${project_name}-salt-states.git`

    *   [project_name-salt-resources][4]
        - resources used by project_name salt states.

        *   Repo is checked out in local path: `~/Works/${project_name}-salt-resources.git`

    *   [project_name-salt-pillars][5]
        - Salt pillars specific to deployment environment.

        *   Repo related to `SRC_env_profile` is clonned in local path: `~/Works/${project_name}-salt-pillars.git`

        *   Repo related to `TRG_env_profile` is clonned in local path: `~/Works/${project_name}-salt-pillars-target.git`

# Bootstrap configuration checklist #

## Primary symlinks: `states` and `pillars` ##

*   Make sure `/srv/states` symlink points to:

    ```
    ~/Works/common-salt-states.git
    ```

    Make repository is switched to correct branch name.

*   Make sure `/srv/pillars` symlink points to:

    ```
    ~/Works/${project_name}-salt-pillars.git
    ```
    TODO: Update after pillars are split into "defaults" and "overrides".

    Make repository is switched to correct branch name.

## Symlinks to source and target pillar profiles ##

*   Source pillar

    Source pillar is actually the primary pillar accessed through
    `/srv/pillars` symlink to:

    ```
    ~/Works/${project_name}-salt-pillars.git/pillars
    ```
    TODO: Update after pillars are split into "defaults" and "overrides".

    Make repository is switched to correct branch name.

*   Target pillar

    Make sure `/srv/pillars/bootstrap/profiles/${TRG_env_profile}`
    symlink points to:

    ```
    ~/Works/${project_name}-salt-pillars.git/pillars/profile
    ```
    TODO: Update after pillars are split into "defaults" and "overrides".

    Make repository is switched to correct branch name.

## `SRC_env_profile` - source pillars data ##

*   Make sure all repositories used in target environments are also
    defined under [`source_repositories`][10] for `SRC_env_profile`:

    ```
    ~/Works/${project_name}-salt-pillars.git
    ```

    See [`source_repositories`][11] example in template pillar.

    This is required so that Salt in source environment is able to
    include content for target environment.

    Obviously, these repositories should be accessible
    in the source environment.

    Make sure all these keys set correctly:

    *   `properties.yaml` => `load_bootstrap_target_envs`

        It should list at least target profile `TRG_env_profile`.

*   Mofify source bootstrap configuration in pillar.

    Open this file (see [example in template pillar][18]):

    ```
    ~/Works/${project_name}-salt-pillars.git/pillars/profile/bootstrap/system_features/source_bootstrap_configuration.sls
    ```

    Make sure all these keys set correctly:

    *   `properties.yaml` => `load_bootstrap_target_envs`

        It should list at least target profile `TRG_env_profile`.

*   These changes do NOT need to be committed.

    This is because repository for `SRC_env_profile` is not cloned for bootstrap
    package (it only configures local environment to build bootstrap package
    and it is useless in target environment).

## `TRG_env_profile` - target pillars data ##

*   Make sure all repositories used in target environments are also
    defined under [`source_repositories`][10] for `TRG_env_profile`:

    ```
    ~/Works/${project_name}-salt-pillars-target.git
    ```

    Make repository is switched to correct branch name.

*   Mofify target bootstrap configuration in pillar.

    Open this file (see [example in template pillar][17]):

    ```
    ~/Works/${project_name}-salt-pillars-target.git/pillars/profile/bootstrap/system_features/target_bootstrap_configuration.sls
    ```

    Make sure all these keys set correctly:

    *   `system_features:target_bootstrap_configuration:bootstrap_sources:states`

        This should specify repository name for `states`.

        To be part of this framework, there is only one value `common-salt-states`.

    *   `system_features:target_bootstrap_configuration:bootstrap_sources:pillars`

        This should specify repository name for `pillars`.

        Conventionally, the value should be `${project_name}-salt-pillars`.

    *   `system_features:target_bootstrap_configuration:export_sources`

        List all repository names to be exported into target environment.

    *   Review other configuration
        under [`target_bootstrap_configuration`][19].

## Salt master configuration ##

*   Make sure Salt master configuration has all these keys set correctly:

    *   `this_system_keys:project`

        It should specify current project `project_name`.

    *   `this_system_keys:profile`

        It should specify current profile `SRC_env_profile`.

    *   `this_system_keys:load_bootstrap_target_envs`

        It should list at least one target profile `TRG_env_profile`.

    ```
    this_system_keys:
        project: project_name
        profile: SRC_env_profile
        load_bootstrap_target_envs:
            TRG_env_profile: ~
    ```

*   Make sure both Salt master and Salt minion are restarted after all
    changes to the settings.

    For example, on Linux with `systemd`:

    ```
    sudo systemctl restart salt-master salt-minion
    ```

## Symlinks for repositories ##

*   Make sure other symlinks (sources and resources) are set by running
    the following command:

    ```
    sudo salt-call state.sls common.source_symlinks,common.resource_symlinks test=False
    ```

# Build bootstrap package #

## Action ##

The package is build by running `bootstrap.generate_content` state
on Salt master:

```
sudo salt-call state.sls bootstrap.generate_content test=False
```

## Result ##

The bootstrap package is build inside directory indicated
by `bootstrap_files_dir` child field of [`static_bootstrap_configuration`][12]
inside pillars of the source environment.

See [`bootstrap_files_dir`][13] example in template pillars.

This directory is created under home directory of [`primary_user`][14] on
Salt minion collocated with Salt master.

There are two options for `generate_packages` field of
[`source_bootstrap_configuration`][16]:

*   `generate_packages: True`

    This will pack content into single file
    (relative to `bootstrap_files_dir`):

    ```
    targets/${project_name}/${TRG_env_profile}/salt-auto-install.*
    ```

*   `generate_packages: False`

    This will leave content unpacked in a directory
    (relative to `bootstrap_files_dir`):

    ```
    targets/${project_name}/${TRG_env_profile}/
    ```

# [footer] #

[0]: #bootstrap-configuration-checklist
[1]: https://github.com/uvsmtid/common-salt-states
[2]: https://gitlab.com/uvsmtid/common-salt-resources/tree/develop
[3]: http://example.com/git/project_name-salt-states
[4]: http://example.com/git/project_name-salt-resources
[5]: http://example.com/git/project_name-salt-pillars
[6]: /docs/salt_installation.md
[7]: /docs/salt_configuration.md
[8]: /docs/salt_runtime.md
[9]: /docs/bootstrap/deploy.md
[10]: /docs/pillars/common/system_features/deploy_environment_sources/source_repositories/_id/readme.md
[11]: /pillars/profile/common/system_features/deploy_environment_sources.sls
[12]: /docs/pillars/bootstrap/system_features/static_bootstrap_configuration/readme.md
[13]: /pillars/profile/bootstrap/system_features/static_bootstrap_configuration.sls
[14]: /docs/pillars/common/system_hosts/_id/primary_user/readme.md
[15]: /docs/pillars/bootstrap/bootstrap_target_envs/readme.md
[16]: /docs/pillars/bootstrap/system_features/source_bootstrap_configuration/readme.md
[17]: /pillars/profile/bootstrap/system_features/target_bootstrap_configuration.sls
[18]: /pillars/profile/bootstrap/system_features/source_bootstrap_configuration.sls
[19]: /docs/pillars/bootstrap/system_features/target_bootstrap_configuration/readme.md

