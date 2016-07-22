
TODO:

# Problem #

At the moment sources, resources and whatever additional data required for
the states are managed differently. There are common set of features and
requirements which can be uniformily consolidated.

## Requirements ##

*   DONE:

    Use single configuration in Salt config file for all external resources
    (resources or sources) so that changes to data sets can be done dynamically
    without restarting Salt (without changing `file_roots` or `pillar_roots`
    configuration in config files - config files stay static).

*   DONE:

    Manage access to these resources through a set of symlinks which are
    seen by Salt from `file_roots` or `pillar_roots`.

*   DONE:

    List all possible resources under the same common pillar key.
    If they all use the same namespace (preferably), this will ensure there
    is no name clashes because it is impossible to have duplicate keys
    in the same dict.

*   Consider both (double indirection):
    *   physical location of resources on the filesystem
    *   logical location of resources exposed through specific URI_scheme

    It is architectually (conceptually) clear to have (e.g. webserver)
    configuratoin and layout the same for each repository server.
    However, physical storage requirements make it difficult (without
    logical redirection via mounting, symlinking, etc.) to place
    large content on fast (expensive) default filesystem location where
    webserver expects it to be.

    There should be settings for symlinks to make sure each server (serving
    specific URI_scheme) can access resources and expose them
    through this URI_scheme using flexible redirection to
    the actual underlying storage.
    In fact, resources should list type, location, and other stuff related
    to physical conent. And "artifact accessor service" should provide
    configuration for the service which will use this specific resource.

*   TODO:

    See: https://github.com/uvsmtid/common-salt-states/issues/2

    *   `system_repositories` - support any type of repository:
        *   filesystem
        *   svn
        *   git
        *   yum
        *   winrepo
        *   etc.

    *   It is not optimal to manage all types of repositories via
        single sub-key (e.g. differentiating them by `repo_type` field).

        A lot of them are drastically different (e.g. `yum` and `git`).

        Instead, it is better to have a sub-key per repository type
        (e.g. `pillar['system_repositories']['git'][repon_name]`).

        TODO: How to differentiate host roles in this case?
        Not all repositories reside on the same machine.
        Does it mean there will be one role for each type
        for repositories? For example:
        *   file_repository_role
        *   svn_repository_role
        *   git_repository_role
        *   yum_repository_role
        *   winrepo_repository_role
        *   etc.

---

