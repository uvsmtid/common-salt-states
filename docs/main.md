
## Multi-project organization

These sources (State, Pillars, etc.) provide automation for multiple projects.

These are links to project-specific documentation:
* [common](projects/common/main.md)

The exhaustive details how multiple porjects are used can be found
[here](approach_for_multiple_projects.md).

Resources are all other files which are not supposed to be under source
control. There are multiple ways to provide resources. The most flexible
approach is to use external file server (FTP or HTTP).
However, the simples solution is to use Salt itself. Salt can be used as
a file server (with `salt://` URL scheme to access files from states).
For this case there is a directory called `resources`. Just like any other
directory, there are project-specify sub-directory (i.e. `common`) which
contains `.gitignore` which is supposed to document all resources under
this specific directory, for example:
```
resources/common/.gitignore
```

## Highlights for Salt master setup

The following section highlights some important configuration Salt master
in its configuration file (`/etc/salt/master`) and beyond.

This should be reviewed when Salt is changed to use one project or another.

### Location of States and sources

```
file_roots:
    base:
        - /srv/states
        - /srv/sources
```

Note that sub-items (directories or files) from the `sources` are only
accessible if they are not hidden by items in `states`.
For example, `salt://whatever` is always looked up as `/srv/states/whatever`
first before it even has a chance to be looked up as `/srv/sources/whatever`.

### Location of Pillars

```
pillar_roots:
    base:
        - /srv/pillars
```

### Selected project

```
this_system_keys:
    # ...
    projects:
        # Leave only one project from this list:
        - project_name
```

This will rendeer templates using correct pillars and states.

### Selected environment

TODO: `environment` should be renamed into `profile` everywhere.

```
this_system_keys:
    # ...
    environment: blackbox # <-- selected environment
    # ...
```

### Selected Salt minions

Use `salt-key` to list registered minions ("Accepted Keys"):

```sh
salt-key
```

Delete keys of those minions which are not supposed to be controlled.
Accept keys of those minions which are     supposed to be controlled.

```sh
salt -d <key> # delete
salt -a <key> # accept
```

