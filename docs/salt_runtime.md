
## Affected Minions ##

All registered minions are considered to be managed by
the same `project_name`.

In other words, all mininos in `Accepted Minions` list shown by the following
command will be configured as `project_name` requires:

``
salt-key
``

This is to allow selecting all minions by `*`:

```
salt `*` test.ping
```

If some minions have nothing to do with the `project_name` configuration,
their keys should be removed (see `salt-key -d`) to avoid any
state execution on them when `*` is used.

### Run state to setup sources and resources symlinks ###

At this point, there should be initially installed and running Salt master
and Salt minion services.

*   Restart them to update their runtime configuration accordingly:

    ```
    service salt-master restart
    service salt-minion restart
    ```

*   Test dummy state execution:

    ```
    salt-call --local state.sls common.dummy test=True
    ```

*   Test states (dry run):

    ```
    salt '*' state.sls common.source_symlinks test=True
    salt '*' state.sls common.resource_symlinks test=True
    ```

*   Apply states:

    ```
    salt '*' state.sls common.source_symlinks test=False
    salt '*' state.sls common.resource_symlinks test=False
    ```

## Next steps ##

In majority of cases, when all minions are already connected,
simply run `highstate` to setup everything:

*   Test highstate (dry run):

    ```
    salt '*' state.highstate test=True
    ```

*   Apply highstate:

    ```
    salt '*' state.highstate test=False
    ```

    This is supposed to bring all minions to the fully configured state.

    In a more complicated system, especially when some minions should be
    set up first to provide services for other minions (cross-host dependency
    on services), orchestration can be used - see [this page][1].

See also `project_name`-specific documentation which states
to run to complete setup.

# [footer] #

[1]: /docs/orchestration.md

