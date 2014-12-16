
The following settings are normally done for Salt master.
This file demonstrates how to use master-less setup providing
the same information in `/etc/salt/minion` which would normally
go to `/etc/salt/master`.

* Checkout sources:
```
git clone git@host:user/common-salt-states.git ~/Works/common-salt-states.git
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
ln -sfn ~username/Works/common-salt-states.git/states  /srv/states
ln -sfn ~username/Works/project-salt-pillars.git/pillars /srv/pillars
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

