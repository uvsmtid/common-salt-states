
## Initial setup

### Location of States and sources

Ensure this in `/etc/salt/master`:

```
file_roots:
    base:
        - /srv/states
        - /srv/sources
```

Note that sub-items (directories or files) from the second element in the
list (`sources`) are only accessible if they are not hidden by items
in the first element (`sources`). For example, `salt://whatever` is
always looked up as `/srv/states/whatever` first before it even has a chance
to be looked up as `/srv/sources/whatever`.


### Location of Pillars

Ensure this in `/etc/salt/master`:

```
pillar_roots:
    base:
        - /srv/pillars
```

### Project selection

Select `project` in `/etc/salt/master`:

```
this_system_keys:
    projects:
        # Leave only one project from this list:
        - project_name
```

This will rendeer templates using correct pillars and states.

### Minion selection

Use `salt-key` to list registered minions ("Accepted Keys").

Delete keys of those minions which are not supposed to be controlled.
Accept keys of those minions which are     supposed to be controlled.
```bash
salt -d <key> # delete
salt -a <key> # accept
```


