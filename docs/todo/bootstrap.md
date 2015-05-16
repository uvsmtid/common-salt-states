TODO

*   TODO: Document all steps of `deploy` action (i.e. `make_salt_resolvable`,
    or `init_dns_server`) for [bootstrap][1] and their configuration
    parameters in files under `conf`.

*   TODO: Split bootstrap pillars configuration into two files:
    source and target.
    It should be clear which configuration is used to run bootstrap
    states on source environment and which is to configure bootstrap
    package for target environment (configuration taken from branch for
    another profile_name).

*   TODO: Write doc for command line parameters to bootstrap script itself (how
    to run installer).

*   Note that location of the pillar is _assumed_.
    TODO: Make location of the pillar declared, otherwise if pillar is
        located in different place, rewrite will be merge with
        unpredictable results.

[1]: docs/bootstrap.md

