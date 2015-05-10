
At the moment there is support for few first-class configuration objects:
*   `registered_content_items`
*   `system_hosts`
*   `system_host_roles`
*   `system_features`
*   `system_networks`

TODO:

*   Rename `registered_content_items` into `system_artifacts`.
*   Move individual networks under `system_networks` key in pillar.
    At the moment, the individual networks are keys in the root of the pillar.
*   Add new first class objects:
    *   `system_platforms`
    *   `system_networks`
    *   `bootstrap`
    *   `system_credentials`
    *   `system_artifact_repositories`

