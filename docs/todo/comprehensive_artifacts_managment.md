
TODO:

*   Remove `branch_name` from repository definitions.
    Define only all fixed parts without branch.
    Specify branches specific to bootstrap,
    environment source code deployment, etc. (based on the purpose
    of specific states).


# Problem #

At the moment sources, resources and whatever additional data required for
the states are managed differently. There are common set of features and
requirements which can be uniformily consolidated.

## Requirements ##

*   Use single configuration in Salt config file for all external artifacts
    (resources or sources) so that changes to data sets can be done dynamically
    without restarting Salt (without changing `file_roots` or `pillar_roots`
    configuration in config files - config files stay static).

*   Manage access to these artifacts through a set of symlinks which are
    seen by Salt from `file_roots` or `pillar_roots`.

*   List all possible artifacts under the same common pillar key.
    If they all use the same namespace (preferably), this will ensure there
    is no name clashes because it is impossible to have duplicate keys
    in the same dict.

*   Consider both (double indirection):
    *   physical location of resources on the filesystem
    *   logical location of resources exposed through specific URI_scheme

    There should be settings for symlinks to make sure each server (serving
    specific URI_scheme) can access resources and expose them through this
    URI_scheme.
    In fact, artifacts should list type, location, and other stuff related
    to physical conent. And "artifact accessor service" should provide
    configuration for the service which will use this specific resource.

# Proposal #

See also [plugable project_names' proposal][1].

# [footer] #

[1]: /docs/todo/plugable_project_names.md#proposal

