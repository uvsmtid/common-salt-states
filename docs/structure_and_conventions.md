
This is a starting point for documentation about
directory layout and naming conventions.

Refer to additional more specific documents for states and pillars:
* Conventions for documenting states: [docs/states/readme.md](docs/states/readme.md)
* Conventions for documenting pillars: [docs/pillars/readme.md](docs/pillars/readme.md)

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

NOTE: This is not a default Salt setup.
See [this document][1] for detailed installation instructions
to configure Salt.

### `pillars` layout ###

```
└── pillars
    ├── bootstrap
    │   └── profiles
    │       └── {{ profile_name }}*
    │
    └── {{ profile_name }}
        ├── common
        └── {{ project_name }}
```

*   `pillars`
    This directory in root is required to separate actuall pillars data
    from anything else repository may contain.
*   `pillars/bootstrap`
    This is a conventional location for special template files which
    load pillars data for other project_names/profile_names.
    The templates depend on [load_bootstrap_target_envs][4]
    Salt configuration.

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

## `scripts` ##

This directory contains utility scripts to facilitate maintanance of
source code itself.

# [footer] #

[1]: docs/getting_started.md
[2]: http://docs.saltstack.com/en/latest/topics/targeting/grains.html#writing-grains
[3]: docs/bootstrap/readme.md
[4]: docs/configs/bootstrap/this_system_keys/load_bootstrap_target_envs/readme.md

