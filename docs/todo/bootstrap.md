TODO

See also:
*   https://github.com/uvsmtid/common-salt-states/issues/8
*   https://github.com/uvsmtid/common-salt-states/issues/13


*   TODO: Document all steps of `deploy` action (i.e. `make_salt_resolvable`,
    or `init_dns_server`) for [bootstrap][1] and their configuration
    parameters in files under `conf`.

*   TODO

    Split bootstrap pillars configuration into two files:
    source and target.
    It should be clear which configuration is used to run bootstrap
    states on source environment and which is to configure bootstrap
    package for target environment (configuration taken from branch for
    another profile_name).

    DONE: There are the following files now:

    *   [`source_bootstrap_configuration.sls`][2]

        Configuration for bootstrap to be used in source environment
        (which generates bootstrap package for target environment).

    *   [`target_bootstrap_configuration.sls`][3]

        Configuration for bootstrap to be used in target environment.

    *   [`static_bootstrap_configuration.sls`][4]

        General bootstrap config applicable for both environments.

*   TODO: Write doc for command line parameters to bootstrap script itself (how
    to run installer).

*   Note that location of the pillar is _assumed_.
    TODO: Make location of the pillar declared, otherwise if pillar is
        located in different place, rewrite will be merge with
        unpredictable results.

*   TODO: Provide two more bootstrap modes:
    *   salt-master-only
    *   salt-minion-only
    These two modes will simply install Salt on specified platform.
    The platform will be given as `host_id` (which will require config
    file for this `host_id`) named after platform like `rhel5`, `rhel7`, etc.
    Therefore, building of bootstrap package will require generating config
    file for such host-like platform ids.

    They will avoid environment-specific settings (only platform-specific
    settings will be done):
    *   None of the source code repositories or their snapshots will be deployed.
    *   None of the states will be run (even setting source or resource links).
    *   None of the network settings will be fixed (routing, DNS, YUM, etc.).
    *   No pre-configured Salt minion or Salt master conf files.

    Actually, this is so simple functionality that it doesn't make sense to
    work on. If it is just to make it seamless to install Salt on RHEL5
    (where it is not part of EPEL anymore), then a wiki is enough.

[1]: /docs/bootstrap/readme.md

[2]: /pillars/profile/bootstrap/system_features/source_bootstrap_configuration.sls
[3]: /pillars/profile/bootstrap/system_features/target_bootstrap_configuration.sls
[4]: /pillars/profile/bootstrap/system_features/static_bootstrap_configuration.sls
