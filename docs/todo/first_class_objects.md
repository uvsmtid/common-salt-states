
# Intro #

At the moment there is support for few first-class configuration objects:
*   `system_resources`
*   `system_hosts`
*   `system_host_roles`
*   `system_features`
*   `system_networks`

# TODO #

*   All items in `system_resources` are supposed to refer to one of
    the repository under `system_repositories`.

*   Add new first class objects:

    *   DONE:

        `system_platforms`

    *   DONE:

        `system_networks`

    *   TODO:

        `bootstrap` - separate pillar info only for environments configured
        to generate bootstrap packages.

    *   DONE:

        `system_secrets` - simple key-value pairs with secret information
        (keys, passwords, etc.) to be easy to populate from scratch.

    *   TODO:

        `system_repositories` - any type of repository:
        *   filesystem
        *   subversion
        *   git

    *   DONE:

        `system_accounts` - all possible user information (except secret
        info which is under `system_secrets`).

