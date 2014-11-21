
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

* Define environment, project, list of minions (`/etc/salt/minion`):
```
this_system_keys:

    # The most neutral project is `common`.
    projects:
        - common

    # In case of master-less setup, only this single minion is seen.
    assignments:
        common:
            - this_minion_id

    # Environment is normally named after hostname.
    environment: this_minion_id
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
^/pillars/[project]/environment/[some_minion_id].sls
```

