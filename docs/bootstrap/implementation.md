
## Implementation ##

Note that there is only `deploy` bootstrap action implemented
at the moment. Action `build` is fully implemented by Salt states.

*   [Template Method][1] pattern is used to implement bootstrap
    script actions:

    *   The base class implements the Template Method which calls
        all steps and provides coordination between them to
        achieve specific Use Case.

        The base class is `action_context` implemented in
        [context.py](states/bootstrap/bootstrap.dir/modules/context.py) file.

    *   The sub-classes implement steps for specific actions.

        The files with implementation are placed under
        [actions](states/bootstrap/bootstrap.dir/modules/actions) directory
        and named after action name.

        For example, see `deploy_template_method` sub-class for `deploy`
        action implemented in
        [deploy.py](states/bootstrap/bootstrap.dir/modules/actions/deploy.py).

*   Cross-platform behavior is achieved by using platform id from
    bootstrap script configuration file (specific for target host).

    Platform id allows loading required module from
    [platforms](states/bootstrap/bootstrap.dir/modules/platforms) directory
    which implements action for specific platform.

    The configuration file is generated during during `build` action at
    the time when everything is known about target system.
    Therefore, there  is no automatic detection of target platform.
    The `build` action is actually just
    a Salt state `common.bootstrap.generate_content`
    - see [this file](states/bootstrap/generate_content/init.sls).

*   The bootstrap action is implemented as a sequence of steps.

    Each step can be implemented differently depending on the target platform.

    Implementation of all steps for all actions for all platforms can be
    found under [steps](states/bootstrap/bootstrap.dir/modules/steps) directory.

    For example, implementation of `set_hostname` step for `deploy` action
    on `rhel7` platform can be found [here](states/bootstrap/bootstrap.dir/modules/steps/deploy/set_hostname/rhel7.py):
    ```
    states/bootstrap/bootstrap.dir/modules/steps/deploy/set_hostname/rhel7.py
    ```

*   To run `deploy` action bootstrap script requires one of the configuration
    files under `conf` directory.

    These configuration files are Python modules which primarily contain
    value assignments for data required at each step of action.

    Each configuration file is specific to combination of
    (project, profile, host) -  see [deploy][40] document for example.

*   All configuration files are generated through Salt.

    Bootstrap package build consolidates the following files under
    [bootstrap][41] directory:

    *   `conf` = configuration files for each defined (project, profile, host).

    *   `resources` = all resource files required for installation.

    *   `modules` and `bootstrap.py` = bootstrap script and modules.

    The `resources` directory also contains all checked out repositories
    necessary to run Salt states.

*   NOTE:

    TODO: Is it really how it works?

    In order to avoid rewritting pillar data,
    macros is used to compose URI. It relys on availability of
    special pillar flag `bootstrap_mode` to triger necessary substitution.
    During bootstrap, this pillar flag is passed using
    `pillar` parameter on command line:

    ```
    salt '*' state.sls sls_file pillar="{ 'bootstrap_mode': 'offline-minion-installer' }"
    ```

*   NOTE:

    Both Salt master and Salt minion configuration files can specify
    many identical configuration parameters. The idea is that:
    *   If it is a Salt minion connected to Salt master, most of required
        configuration is obtained online from Salt master configuration file.
    *   If it is a sandalone Salt minion, it requires all configuration,
        which normally belongs to Salt master, to be specified in Salt minion
        configuration file.

    The important note is about custom configuration keys - Salt minion
    custom configuration keys _always overwrite_ Salt master's ones.
    In other words, whether `salt`, or `salt-call`,
    or `salt-call` with `--local` option command is used, if Salt minion
    configuration file had the same custom configuraton key, the value
    used will come from this Salt minion configuration file.

# [footer] #

[1]: https://en.wikipedia.org/wiki/Template_method_pattern
[2]: https://en.wikipedia.org/wiki/Factory_method_pattern

[13]: #offline-minion-installer
[14]: #initial-online-node

[20]: docs/pillars/common/registered_content_config/URI_prefix/readme.md

[30]: http://docs.saltstack.com/en/latest/ref/configuration/master.html#auto-accept

[40]: docs/bootstrap/deploy.md
[41]: states/bootstrap/bootstrap.dir
