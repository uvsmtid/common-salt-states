
## Description ##

*   Examples of command line to run bootstrap script:

    *   Linux (`bash`):

        ```
        python bootstrap.py deploy initial-online-node conf/${PROJECT_NAME}/${PROFILE_NAME}/${HOST_ID}.py
        ```

    *   Windows (`cmd`):

        ```
        powershell -file bootstrap.ps1 deploy initial-online-node conf\%PROJECT_NAME%\%PROFILE_NAME%\%HOST_ID%.py
        ```

*   The bootstrap scripts arguments are:

    *   `$1`|`%1` = bootstrap action, for example: `deploy`.

        NOTE:

        *   In fact, at the moment `deploy` is only available action.

            The `build` action is fully implemented by Salt states executed
            in source environment.

            See [design document][1] for explanation what `deploy` and `build`
            action mean and [implementation document][2] for details.

    *   `$2`|`%2` = bootstrap use case, for example:

        *   `initial-online-node` to configure Salt services.

        *   `offline-minion-installer` to install everything required on
            the host without enabling Salt services.

        See the [design document][1] for explanation.

    *   `$3`|`%3` = bootstrap script configuration file.

        Bootstrap script configuration file is just a Python script
        which explains `.py` extensions.

        There can be many configuration files within bootstrap package
        (one file per host in the target system).

        The required one can be described as parameterized path
        relative to bootstrap package root directory:

        *   Linux:

            ```
            conf/${PROJECT_NAME}/${PROFILE_NAME}/${HOST_ID}.py
            ```

        *   Windows:

            ```
            conf\%PROJECT_NAME%\%PROFILE_NAME%\%HOST_ID%.py
            ```
        The variables composing the path to configuration file have
        the following meaning:

        *   `PROJECT_NAME` corresponds to `project_name` in pillars.
        *   `PROFILE_NAME` corresponds to `profile_name` in pillars.
        *   `HOST_ID` corresponds to one of the [system_hosts][5] in
            pillars for the target system.

## Example ##

In order to avoid specifying long command line,
use one of the generated wrapper script which pre-set
the arguments for bootstrap script:

*   Linux: `run_bootstrap.sh`

*   Windows: `run_bootstrap.cmd`

NOTE:
In both cases, it is required to open the script in the editor and
uncomment one of the `HOST_ID` assignment to match the host where
bootstrap script is supposed to run.

NOTE:
It is possible to generate such wrapper for each `HOST_ID` pre-set,
but that approach would remove the conscious step of selecting
which `HOST_ID` this machine is supposed to match. In other words,
it may lead to erroneous execution simply by running wrongly selected script.

# [footer] #

[1]: /docs/bootstrap/design.md
[2]: /docs/bootstrap/implementation.md
[5]: /docs/pillars/common/system_hosts/readme.md

