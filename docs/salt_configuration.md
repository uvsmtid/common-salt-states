
NOTE: The following document is outdated - it is complex and error-prone to
follow manually. There is already automatic `configure_salt.py` script
which configures Salt automatically.

TODO: Update document to run `configure_salt.py` script.

# Configure Salt #

The following staps configure [framework][2] for multiple projects.

## Set repository links ##

The following command examples may actually be executed
after setting these variables:

*   `project_name="PROJECT_NAME"`

*   `default_username="$(whoami)"`

    It is recommended to use regular user (rather than `root`).

Check out necessary repositories and create symlinks
so that Salt can access them.

*   states

    *   `common-salt-states`

        ```
        # /srv/states -> ~/Works/common-salt-states.git/states

        sudo ln -sfn /home/${default_username}/Works/common-salt-states.git/states /srv/states
        ```

    *   `${project_name}-salt-states`

        ```
        /srv/states/${project_name} -> /home/${default_username}/Works/${project_name}-salt-states.git/states/${project_name}

        sudo ln -sfn /home/${default_username}/Works/${project_name}-salt-states.git/states/${project_name} /srv/states/${project_name}
        ```

        Note that `project_name` link is created under `states` directory
        of `common-salt-states` repository.

    *   Additonal repository with Salt states can be set up similar to
        the symlink for `${project_name}-salt-states`.

*   pillars

    *   `${project_name}-salt-pillars`

        ```
        # /srv/pillars -> /home/${default_username}/Works/${project_name}-salt-pillars.git/pillars

        sudo ln -sfn /home/${default_username}/Works/${project_name}-salt-pillars.git/pillars /srv/pillars
        ```
        TODO: Update after pillars are split into "commons"/"defaults"/"overrides".

        There is only one active profile and it is defined by contents of
        `pillars` directory of `${project_name}-salt-pillars` repository.

        Additional profiles (with configuration for other deployments) are
        modelled either using different repositories or using branches
        within the same repository.

*   resources

    Symlinks for resource respositories are configured
    automatically using `common.resource_symlinks` state.

## Change Salt configuration ##

### `file_roots` ###

Option `file_roots` specifies location where Salt looks up file references
(including state files).

```
# ...
file_roots:
    base:
        # Conventionally, the following directory is a symlink pointing to
        # `/home/${default_username}/Works/common-salt-states.git/states`
        - /srv/states

        # The following directory is a common place for all additional
        # symlinks pointing to various source code repositories.
        # These symlinks are configured automatically by using
        # `common.source_symlinks` state - see below.
        - /srv/sources

        # A directory with symlinks to resources.
        - /srv/resources
# ...
```

### `pillar_roots` ###

Option `pillar_roots` specifies location where Salt loads pillars.

```
# ...
pillar_roots:
    base:
        # Conventionally, the following directory is a symlink pointing to
        # `/home/${default_username}/Works/${project_name}-salt-pillars.git/pillars`
        - /srv/pillars

        TODO: Update after pillars are split into "commons"/"defaults"/"overrides".

# ...
```

## Next steps ##

See [Salt runtime][14] document.

# [footer] #

[2]: /docs/framework.md
[14]: /docs/salt_runtime.md
