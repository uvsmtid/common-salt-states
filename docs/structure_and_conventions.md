
This is a starting point for documentation about directory layout and
naming conventions.

Instead of consolidating all such information in single file, the approach
is to refer to additional more specific document with all details.

For example:
* Conventions for documenting states: [docs/states/readme.md][docs/states/readme.md]
* Conventions for documenting pillars: [docs/pillars/readme.md][docs/pillars/readme.md]

## General layout map ##

```
.
├── docs
│   ├── *
│   └── projects
│       ├── *
│       └── {{ project_name }}
├── pillars
│   ├── common
│   ├── customizer
│   │   ├── orchestrate
│   │   ├── profile
│   │   └── testing
│   │   └── profile
│   └── workmachine
│       └── profile
└── states
    ├── common
    │   ├── *
    │   └── {{ state_name }}
    ├── customizer
    │   ├── *
    │   └── {{ customizer_id }}
    ├── _grains
    ├── {{ project_name }}
    │   ├── *
    │   └── {{ state_name }}
    └── orchestrate
        ├── common
        │   ├── stage_flag_files
        │   ├── stage_flag_files
        │   └── {{ project_name }}
        ├── *
        └── {{ state_name }}
            ├── *
            └── wraps
                ├── *
                └── {{ role_name }}

```

## `docs`

Documentation directory

## `pillars`

This directory contains pillars or "configuration data" consumed by Salt.

On Linux `/srv/states` should be a symlink to this directory, for example:
```
ls -l /srv/pillars
```
NOTE: This is not default Salt setup.
See [here](inital_salt_setup.md) what is supposed to changed.

## `states`

This directory contains states or "configuration logic" executed by Salt.

On Linux `/srv/pillars` should be a symlink to this directory, for example:
```
ls -l /srv/states
```
NOTE: This is not default Salt setup.
See [here](inital_salt_setup.md) what is supposed to changed.

There are several special sub-directories in `states`:
* `_grains` - custom grains (see [writing grains](http://docs.saltstack.com/en/latest/topics/targeting/grains.html#writing-grains))
* `customizer` - TODO
* `orchestrate` - states to be used with `orchestrate` runner (see [orchestration](orchestration.md))
* `common` - common states shared between projects
* `*` - everything else are sub-directories for project-specific states

## `scripts`

TODO

