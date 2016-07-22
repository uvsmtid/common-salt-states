
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

        See: https://github.com/uvsmtid/common-salt-states/issues/5

        `system_secrets` - simple key-value pairs with secret information
        (keys, passwords, etc.) to be easy to populate from scratch.

        DONE: The template is done, but it is not used at the momement.

        TODO: Design easy to use procedure to attach
              secrets via `properties.yaml` file.

        Rename `depository` into `repository`.

    *   TODO: Resources - see [comprehensive_resources_managment.md][1].

    *   DONE:

        `system_accounts` - all possible user information (except secret
        info which is under `system_secrets`).

---

[1]: /docs/todo/comprehensive_resources_managment.md

