
## Contents of the repository root ##

*   [`docs`](#docs)

    All documentation for this common framework.

*   [`states`](#states)

    Source code with Salt states to define require system configuration.

    See [conventions for documenting states][5]

*   [`pillars`](#pillars)

    Template for Salt pillars configuring system profile for
    individual deployments.

    See [conventions for documenting pillars][6]

*   [`scripts`](#scripts)

    Support scripts for various purposes.

    These scripts are those which are not supposed to be used by Salt states
    (under `states` directory) because files under `scripts` directory are not
    easily accessible through `salt://` URI scheme.

## `docs` ##

This is a documentation directory.

### `docs` layout ###

```
.
└── docs
    ├── *
    └── projects
        ├── *
        ├── common
        ├── bootstrap
        └── {{ project_name }} -> [project_name]-salt-states.git/docs/projects/[project_name]
```

## `states` ##

This directory contains _configuration code_ executed by Salt.
In Salt terms it is called _states_ and uses Salt pillars as source of
configuration data.

On Linux `/srv/states` should be a symlink to this directory, for example:

```
/srv/states -> /home/[username]/Works/[project_name]-salt-states.git/states
```

NOTE: This is not default Salt setup.
See [this document][1] for detailed installation instructions
to configure Salt.

There are several special sub-directories in `states`:
*   `_grains` - custom grains - see [writing grains][2]
*   `common` - common states shared between project_names
*   `[project_name]` - symlink to repository with project_name-specific states
*   `bootstrap` - special project_name shared together with common states to
    create packages for fully automated deployment - see [bootstrap][3]

### `states` layout ###

```
.
└── states
    ├── common
    │   ├── *
    │   └── {{ state_name }}*
    ├── _grains
    └── {{ project_name }} -> [project_name]-salt-states.git/states/[project_name]
        ├── orchestrate
        │   ├── stage_flag_files
        │   ├── *
        │   ├── {{ state_name }}*
        │   └── wraps
        │       ├── *
        │       └── {{ role_name }}*
        ├── *
        └── {{ state_name }}*
```

## `pillars` ##

This directory contains _template_ for
_configuration data_ consumed by Salt.
In Salt terms it is called _pillars_ which are used in Salt _states_ to
configure execution.

Again, directory `pillars` is just a template which should be copied
into another repository (it should not be used directly) because
configuration data is supposed to be specific for individual deployment.
However, pillars are documented here as requirement for pillar data
structure compartibility with the states code which uses it.

In order to create new instance with project_name-specific configuration data,
copy this directory in new repository and checked it in, for example:

```
mkdir /home/[username]/Works/[project_name]-salt-pillars.git
cd /home/[username]/Works/[project_name]-salt-pillars.git
git init
cp -r /home/[username]/Works/common-salt-states.git/pillars /home/[username]/Works/[project_name]-salt-pillars.git
git add pillars
git commit -m 'Instantiate pillar template'
```

On Linux `/srv/pillars` should be a symlink to a directory in this repository, for example:

```
/srv/pillars -> /home/[username]/Works/[project_name]-salt-pillars.git/pillars
```
TODO: Update when pillars are split to "defaults" and "overrides".

NOTE: This is not a default Salt setup.
See [this document][1] for detailed installation instructions
to configure Salt.

### `pillars` layout ###

```
└── pillars
    ├── bootstrap
    │   └── pillars
    │       └── {{ profile_name }}*
    │
    └── profile
        ├── common
        ├── bootstrap
        └── {{ project_name }}
```

*   `pillars/profile`

    Template profile configuration data for specific deployment.

*   `pillars/bootstrap`

    TODO:
    This shouldn't be in the pillar.
    It should be done via filesystem paths overlays in `file_roots`.

## `scripts` ##

This directory contains utility scripts to facilitate maintanance of
the source code itself.

# [footer] #

[1]: /docs/getting_started.md
[2]: http://docs.saltstack.com/en/latest/topics/targeting/grains.html#writing-grains
[3]: /docs/bootstrap/readme.md

[5]: /docs/states/readme.md
[6]: /docs/pillars/readme.md

