
# Use Cases #

Ultimately, all Use Cases set up Salt minion. This is inevitable because
only Salt minion is the only software able to execute all configuration steps.

However, there some differences of the state the system should be after
running the bootstrap script. They are called bootstrap use cases:

*   [`initial-online-node`][14]

*   [`offline-minion-installer`][13]

Steps done automatically by bootstrap script:

*   Partially configure and test network environment to match the one
    defined in Salt pillar for target system.

*   Install Salt master or Salt minion (or both) packages with dependencies.

*   Configure new Salt master or Salt minion for
    specific `project_name` and `profile_name`.

*   Adjust filesystem symlinks to let Salt find all necessary resources.

*   (Optionally) Start both services Salt master and Salt minion
    (depending on use case and host role within system `profile_name`).

*   Run highstate (`offline-minion-installer` only).

## `initial-online-node` ##

This use case is primarily needed to set up Salt-managed environment and let
all other configuration be run by Salt at later time.
It leaves Salt services running.

This use case sets up Salt master or Salt minions as connected nodes
and does NOT run `highstate`.

Because all Salt minion are supposed to connect to Salt master in this
use case, configuration of Salt minion hosts are minimal.

NOTE:
*   In order for `initial-online-node` use case to work,
    Salt master has to be configured to accept minion keys automatically
    - see [`auto_accept` Salt configuration][30].

## `offline-minion-installer` ##

This use case is primarily needed for installation of hosts independently
(i.e. via USB drive) without connecting anywhere else.
It does not leave Salt services running.

This use case sets up Salt minion with additional master-side
configuration to make Salt minion autonomous
(without requiring connection to Salt master) and runs `highstate`.

Because all Salt minions are NOT supposed to connect to Salt master in this
use case, Salt minion is fully configured to be standalone and contains
all necessary resources to deploy required software on specific host.

## Requirements ##

*   The bootstrap package is a pre-built installer which is able to install
    any defined host of the system.

    The same package can be used to run bootstrap script on each individual
    host participatin in the system and, therefore,
    it has to be cross-platform.

*   The whole process of bootstrapping is split into:

    *   Action `build` to create bootstrap package.

    *   Action `deploy` to configure hosts using bootstrap package.

*   There are two possible environments:

    *   The _source environment_ is where the packages are built.

    *   The _target environment_ is where the packages are deployed.

    Packages created by any source environment must be the same as long as
    they are built for the same target environment.

*   The bootstrap package can be pre-built in any existing Salt-managed
    environment (source environment).

    In order to build such package, source environment should also know
    configuration (pillar) of target environment. Therefore, there should
    be a mechanism to load pillar data of target environment.

    Pillar data of target environment should be under specific key
    to avoid merging them at the top level with pillar data of source
    environment.

*   When packages are deployed, bootstrap framework shall not depend
    on information what was the source environment the packages were
    built in.

*   The bootstrap framework shall allow extending it to support variations
    of operating system and system software versions.

# [footer] #

[13]: #offline-minion-installer
[14]: #initial-online-node

[30]: http://docs.saltstack.com/en/latest/ref/configuration/master.html#auto-accept

