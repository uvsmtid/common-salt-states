
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
        # Conventionally, the following directory is a symlink pointing to
        # `/home/[username]/Works/common-salt-states.git/states`
        - /srv/states

        # The following directory is a common place for all additional
        # symlinks pointing to various source code repositories.
        # These symlinks are configured automatically by using
        # `common.source_links` state - see below.
        - /srv/sources
```
Set `/srv/states` symlink to the Salt configuration sources:
```
ln -sfn /home/[username]/Works/common-salt-states.git/states /srv/states
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
Set `/srv/pillars` symlink to the Salt configuration sources:
```
ln -sfn /home/[username]/Works/project-salt-states.git/pillars /srv/pillars
```

### Selected project

```
this_system_keys:
    # ...
    # Salt master orchestrates only one project:
    # ...
```

This will rendeer templates using correct pillars and states.

### Selected profile

```
this_system_keys:
    # ...
    profile: blackbox # <-- selected profile
    # ...
```

### Selected customizer

Customizer can be used for personal configuration.
```
this_system_keys:
    # ...
    customizer: some_personal_id # <-- selected customizer
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
salt-key -d <key> # delete
salt-key -a <key> # accept
```

### Run state to setup symlinks

* Test (dry run):
```
salt '*' state.sls common.source_links test=True
```
* Apply:
```
salt '*' state.sls common.source_links test=False
```

* Render state from minion perspective:
```
# show specific state
salt '*' state.show_sls common.source_links

# show top
salt '*' state.show_top
```

## Next steps

See project-specific documentation which states to run to complete setup.

In majority of cases, when all minions are already connected,
all what is required is to run:
```
salt '*' state.highstate test=False
```
This will bring all minions to the fully configured state.

In a more complicated system especially when some minions should be
set up first to provide services for other minions (cross-host dependency
on services), orchestration can be used.
* TODO: add link to generic orchestration documentation.


## Setting up single agent-less host 


This file demonstrates how to use master-less setup for single host
installation.
This normally requires providing the same information in `/etc/salt/minion`
which would normally go to `/etc/salt/master`.

* Checkout sources:
```
```

* Install Salt minion:
```
yum install salt-minion
```

* Point Salt to states and pillars (`/etc/salt/minion`):
```
file_roots:
    base:
        - /srv/states
...
pillar_roots:
    base:
        - /srv/pillars
```

* Make symlinks to the sources:
```
```

* Set minion id:
```
echo some_minion_id > /etc/salt/minion_id
```

* Test dummy state execution:
```
salt-call --local state.sls common.dummy test=True
```

* Define profile, project, list of minions (`/etc/salt/minion`):
```
this_system_keys:

    # The most neutral project is `common`.
    # If no project-related config is required, use any
    # unknown name (i.e. `none`).
    project: common

    # Profile is normally named after hostname.
    profile: this_minion_id

    # Customizer is supposed to be a personal id (account name,
    # nick name, etc.) which uniquely identifies person so
    # that individual customized states are kept separately
    # (under different sub-directories and files).
    customizer: some_personal_id
```

* Run highstate to test configuration:
```
salt-call --local state.highstate test=True
```

At this point the single minion is ready to be automatically
provided with any configuration by Salt. From now on, this is
a routine Salt usage which is all about listing required states
directly in `^/states/top.sls` (or indirectly) and updating pillar
data mostly provided through enfironment file:
```
^/pillars/[project]/profile/[some_minion_id].sls
```

