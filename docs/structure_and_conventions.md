
This is a starting point for documentation about directory layout and
naming conventions.

Instead of consolidating all such information in single file, the approach
is to refer to additional more specific document with all details.

For example:
* Conventions for documenting states: [docs/states/readme.md][docs/states/readme.md]
* Conventions for documenting pillars: [docs/pillars/readme.md][docs/pillars/readme.md]

## `docs` ##

Documentation directory

## `pillars` ##

This directory contains pillars or "configuration data" consumed by Salt.

On Linux `/srv/states` should be a symlink to this directory, for example:
```
ls -l /srv/pillars
lrwxrwxrwx. 1 root root 50 Jan 27 21:53 /srv/pillars -> /home/username/Works/[project_name]-salt-states.git/pillars
```
NOTE: This is not default Salt setup.
See [here](inital_salt_setup.md) what is supposed to changed.

## `states` ##

This directory contains states or "configuration logic" executed by Salt.

On Linux `/srv/pillars` should be a symlink to this directory, for example:
```
ls -l /srv/states
lrwxrwxrwx. 1 root root 49 Jan 27 21:53 /srv/states -> /home/username/Works/common-salt-states.git/states
```

NOTE: This is not default Salt setup.
See [here](inital_salt_setup.md) what is supposed to changed.

There are several special sub-directories in `states`:
* `_grains` - custom grains (see [writing grains](http://docs.saltstack.com/en/latest/topics/targeting/grains.html#writing-grains))
* `common` - common states shared between projects
* `*` - everything else are sub-directories for project-specific states

## `scripts` ##

TODO

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
│   ├── {{ project_name }}
│   │   ├── orchestrate
│   │   ├── profile
│   │   └── testing
│   │   └── profile
│   └── workmachine
│       └── profile
└── states
    ├── common
    │   ├── *
    │   ├── {{ state_name }}
    │   └── orchestrate
    │       ├── stage_flag_files
    │       ├── *
    │       ├── {{ state_name }}
    │       └── wraps
    │           ├── *
    │           └── {{ role_name }}
    ├── _grains
    └── {{ project_name }}
        ├── *
        └── {{ state_name }}
```

