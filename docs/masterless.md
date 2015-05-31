
## Master-less Salt minion configuration ##

This section demonstrates how to use master-less Salt minion.

*   Follow [section on initial Salt setup][1] but:

    *   Install only `salt-minion` package.
    *   Enable and start only `salt-minion` service.

*   Follow [section on Salt master configuration][1] but:

    *   Provide the same information in `/etc/salt/minion`
        (Salt minion configuration file)
        which was meant for `/etc/salt/master`
        (Salt master configuration file).

*   Test dummy state execution:

    ```
    salt-call --local state.sls common.dummy test=True
    ```

*   Test highstate (dry run):

    ```
    salt-call --local state.highstate test=True
    ```

*   Apply highstate:

    ```
    salt-call --local state.highstate test=False
    ```

# [footer] #

[1]: /docs/getting_started.md


