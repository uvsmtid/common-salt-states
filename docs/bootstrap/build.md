
TODO:   Update the document after release.
        This document was created for branch `release-v0.0.0`
        before release `v0.0.0`.

# Initial conditions #

Note that bootstrap package is always built on Salt master.
And, therefore, it is Linux environment.

The [bootstrap checklist][0] is written for `lemur` project assuming
the following initial conditions (if not, example command lines are supposed
to be fixed):

*   Bootstrap environments:
    *   Source profile name is `SRC-env`.
    *   Target profile name is `TRG-env`.

*   Repositories:
    *   [common-salt-states][1]
        - Salt states common for other projects.
        *   Repo is checked out in local path: `~/Works/common-salt-states.git`
    *   [common-salt-resources][2]
        - resources used by common salt states.
        *   Repo is checked out in local path: `~/Works/common-salt-resources.git`
    *   [lemur-salt-states][3]
        - Salt states specific to lemur project.
        *   Repo is checked out in local path: `~/Works/lemur-salt-states.git`
    *   [lemur-salt-resources][4]
        - resources used by lemur salt states.
        *   Repo is checked out in local path: `~/Works/lemur-salt-resources.git`
    *   [lemur-salt-pillars][5]
        - Salt pillars specific to deployment environment.
        *   Repo related to `SRC-env` is clonned in local path: `~/Works/lemur-salt-pillars.git`
        *   Repo related to `TRG-env` is clonned in local path: `~/Works/lemur-salt-pillars.target.git`

# Bootstrap checklist #

## Filesystem symlinks ##

0.  Make sure `/srv/states` symlink points to:

    ```
    ~/Works/common-salt-states.git
    ```

0.  Make sure `/srv/pillars` symlink points to:

    ```
    ~/Works/lemur-salt-pillars.git
    ```

0.  Make sure other symlinks (sources and resources) are set by running
    the following command:

    ```
    sudo salt-call state.sls common.source_symlinks,common.resource_symlinks test=False
    ```

0.  Make sure symlink for target environment pillars `/srv/pillars/bootstrap/pillars/TRG-env` points to:

    ```
    ~/Works/lemur-salt-pillars.target.git
    ```

## `SRC-env` - source repo state ##

0.  Mofify source bootstrap configuration in pillar.

    Open this file:

    ```
    ~/Works/lemur-salt-pillars.git/pillars/profile/bootstrap/system_features/source_bootstrap_configuration.sls
    ```

    ```
    source_bootstrap_configuration:

        enable_bootstrap_target_envs:
            TRG-env: ~

        bootstrap_package_use_cases:
            - 'initial-online-node'
            - 'offline-minion-installer'

        generate_packages: True
    ```

    Make sure all these keys set correctly:

    *   `system_features/source_bootstrap_configuration/enable_bootstrap_target_envs`

        It should list at least target profile `TRG-env`.

0.  These changes do NOT need to be committed.

    This is because repository for `SRC-env` is not cloned for bootstrap
    package (it only configures local environment to build bootstrap package
    and it is useless in target environment).

## `TRG-env` - target repo state ##

## Salt master configuration ##

0.  Make sure Salt master configuration has all these keys set correctly:

    *   `this_system_keys/project`

        It should specify current project `lemur`.

    *   `this_system_keys/profile`

        It should specify current profile `SRC-env`.

    *   `this_system_keys/load_bootstrap_target_envs`

        It should list at least target profile `TRG-env`.

    ```
    this_system_keys:
        project: lemur
        profile: SRC-env
        load_bootstrap_target_envs:
            TRG-env: ~
    ```

0.  Make sure both Salt master and Salt minion are restarted after all
    changes to the settings.

# [footer] #

[0]: #bootstrap-checklist
[1]: https://github.com/uvsmtid/common-salt-states
[2]: https://github.com/uvsmtid/common-salt-resources
[3]: http://example.com/git/lemur-salt-states
[4]: http://example.com/git/lemur-salt-resources
[5]: http://example.com/git/lemur-salt-pillars

