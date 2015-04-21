
This is a starting point for documentation about directory layout and
naming conventions.

Refer to additional more specific documents for states and pillars:
* Conventions for documenting states: [docs/states/readme.md][docs/states/readme.md]
* Conventions for documenting pillars: [docs/pillars/readme.md][docs/pillars/readme.md]

## `docs` ##

This is documentation directory.

## `pillars` ##

This directory contains _configuration data_ (pillars in Salt terms)
consumed by _configuration code_ (states in Salt terms.

Directory `pillars` does not exists in this repository. It is supposed
to be specific for individual deployment. However, it is documented here
as requirement for pillar data structure compartible with the states code
which uses it.

On Linux `/srv/states` should be a symlink to this directory, for example:
```
ls -l /srv/pillars
lrwxrwxrwx. 1 root root 50 Jan 27 21:53 /srv/pillars -> /home/username/Works/[project_name]-salt-pillars.git/pillars
```
NOTE: This is not a default Salt setup.
See [this document][1] to configure Salt for detailed
installation instructions.

## `states` ##

This directory contains states or "configuration logic" executed by Salt.

On Linux `/srv/pillars` should be a symlink to this directory, for example:
```
ls -l /srv/states
lrwxrwxrwx. 1 root root 49 Jan 27 21:53 /srv/states -> /home/username/Works/common-salt-states.git/states
```

NOTE: This is not default Salt setup.
See [this document][1] what is supposed to changed.

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

# [footer] #

[1]: docs/getting_started.md

