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

# [footer] #

[1]: docs/configs/common/this_system_keys/project_name/readme.md
[2]: docs/bootstrap/deploy.md

