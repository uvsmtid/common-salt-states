# Framework #

## Concepts ##

The framework is designed to distinguish:

*   project

    *   A project describes how to deploy a system of multiple hosts.

    *   In terms of Salt, project is a set of _states_.

    *   All deployments of the same project share

*   profile

    *   A profile describes configuration of a project.

    *   In terms of Salt, profile is a set of _pillars_.

    *   Each deployment of the same project has its own profile.

*   host

    *   A host describes individual machine.

    *   In terms of Salt, host is a _minion_.

    *   Both project and profile specify
        what configuration is applied individual host.

These concepts are reflected in the way
how [deployment using bootstrap package][2] is done.

## Repositories ##

There are three types of repositories defined within this framework:

*   states

    These are Salt states - source code.

    There can be _many_ states repositories used within specific project:

    *   `common-salt-states` is required as part of the framework.

    *   `project_name-salt-states` is required as part of the project.

        In case of framework development, only `common-salt-states`
        repository is required ([`project_name`][1] variable is set
        to `common` then).

    *   Other additional repositories with Salt states are optional and
        part of `project_name`-specific requirements.

*   pillars

    These are Salt pillars - configuration data.

    There can be _only one_ repository with pillars for specific profile.

*   resources

    These are any other content required for deployment:

    *   COTS installers
    *   Database dumps
    *   license files
    *   etc.

    There can be as many repositories with resources as meaningful for
    specific project.

## Configuration ##

Update `/etc/salt/master` configuration after [initial setup][3]
which has to be done first.

### Update Salt configuration ###

```
# ...

# ...
this_system_keys:
    # ...
    project_name: project_name
    profile_name: profile_name
    master_minion_id: minion_id
    default_username: username
    # ...
```

See description for parameters:
*   [`project_name`][9]
*   [`profile_name`][10]
*   [`master_minion_id`][11]
*   [`default_username`][12]

### Update repository links ###

Check out necessary repositories and create symlinks
so that Salt can access them:

*   states

    *   `common-salt-states`

        ```
         /srv/states -> ~/Works/common-salt-states.git/states
        ```

    *   `project_name-salt-states`

        ```
        /srv/states/[project_name] -> /home/[username]/Works/[project_name]-salt-states.git/states/[project_name]
        ```

        Note that `project_name` link is created under `states` directory
        of `common-salt-states` repository.

    *   Additonal repository with Salt states can be set up similar to
        the symlink for `project_name-salt-states`.

*   pillars

    *   `project_name-salt-pillars`

        ```
        /srv/pillars -> /home/[username]/Works/[project_name]-salt-pillars.git/pillars
        ```

        There is only one active profile and it is defined by contents of
        `pillars` directory of `[project_name]-salt-pillars` repository.

        Additional profiles (with configuration for other deployments) are
        modelled either using different repositories or using branches
        within the same repository.

*   resources

    Symlinks for resource respositories are configured
    automatically using `common.resource_symlinks` state.

## Next steps ##

See [Salt runtime][13] document.

# [footer] #

[1]: docs/configs/common/this_system_keys/project_name/readme.md
[2]: docs/bootstrap/deploy.md
[3]: docs/getting_started.md
[4]: docs/orchestration.md
[9]: docs/configs/common/this_system_keys/project_name/readme.md
[10]: docs/configs/common/this_system_keys/profile_name/readme.md
[11]: docs/configs/common/this_system_keys/master_minion_id/readme.md
[12]: docs/configs/common/this_system_keys/default_username/readme.md
[13]: docs/salt_runtime.md

