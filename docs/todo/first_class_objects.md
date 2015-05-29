
At the moment there is support for few first-class configuration objects:
*   `system_resources`
*   `system_hosts`
*   `system_host_roles`
*   `system_features`
*   `system_networks`

TODO:

*   Rename `system_resources` into `system_artifacts`.
*   Move individual networks under `system_networks` key in pillar.
    At the moment, the individual networks are keys in the root of the pillar.
*   Add new first class objects:
    *   `system_platforms`
    *   `system_networks`
    *   `bootstrap` - separate pillar info only for environments configured
        to generate bootstrap packages.
    *   `system_secrets` - simple key-value pairs with secret information
        (keys, passwords, etc.) to be easy to populate from scratch.
    *   `system_repositories` - any type of repository (filesystem,
        subversion, git).
    *   `system_accounts` - all possible user information (except secret
        info which is under `system_secrets`).

