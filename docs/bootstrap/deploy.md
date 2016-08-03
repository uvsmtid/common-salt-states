
## Description ##

*   The front-end script is `bootstrap.py` (bootstrap script).

*   Script accepts the following parameters:

    *   `$1` = bootstrap action, for example: `deploy`.

        NOTE:

        *   In fact, at the moment `deploy` is only available action.

            The `build` action is fully implemented by Salt states executed
            in source environment.

            See [design document][1] for explanation what `deploy` and `build`
            action mean and [implementation document][2] for details.

    *   `$2` = bootstrap use case, for example:

        *   `initial-online-node` to configure Salt services.

        *   `offline-minion-installer` to install everything required on
            the host without enabling Salt services.

        See the [design document][1] for explanation.

    *   `$3` = bootstrap script configuration file.

        Bootstrap script configuration file is just a Python script
        which explains `.py` extensions.

        There can be many configuration files within bootstrap package
        (one file per host in the target system).

        The required one can be described as parameterized path
        relative to bootstrap package root directory:
        ```
        conf/${PROJECT_NAME}/${PROFILE_NAME}/${HOST_ID}.py
        ```

        *   `PROJECT_NAME` corresponds to [project_name][3] in Salt config file.
        *   `PROFILE_NAME` corresponds to [profile_name][4] in Salt config file.
        *   `HOST_ID` corresponds to one of the [system_hosts][5] in
            Salt pillar configuration data for target system.

## Example ##

In order to avoid specifying long command line, create a simple wrapper
script to run bootstrap script with exact parameters.

Note that the output of bootstrap script may be long and it does not
capture it automatically. Therefore, add stdout/stderr redirection.

### Linux ###

```
#!/bin/sh

PROJECT_NAME=lemur
PROFILE_NAME=prod-env
HOST_ID=sirius_42

python ./bootstrap.py \
    deploy \
    offline-minion-installer \
    conf/"${PROJECT_NAME}"/"${PROFILE_NAME}"/"${HOST_ID}.py" \
    2>&1 | tee bootstrap.log

```

### Windows ###

TODO

# [footer] #

[1]: /docs/bootstrap/design.md
[2]: /docs/bootstrap/implementation.md
[5]: /docs/pillars/common/system_hosts/readme.md

