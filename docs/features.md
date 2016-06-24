
# Offline installation #

## Disable online checks ##

If there is a top level key `bootstrap_mode` set to `offline-minion-installer`,
some states (which depend on availability of other hosts being online)
will be disabled.

This is primarily applied to ignore hosts with
`consider_online_for_remote_connections` set to `True`
so that (when host are not yet accessible) the relevant states do not fail.

This is specifically designed to achieve maximum
possible configuration for offline case
(when hosts are not able to access each other).

See also:
*   [`bootstrap_mode`][4]
*   [`consider_online_for_remote_connections`][5]

# Automatic Jenkins reconfiguration #

Jenkins is automatically (re)configured to self-test `common-salt-states` with
its [template profile in pillars][3] to perform bootstrap of nodes
from clean OS.

Configuration of the jobs may specify:
*   Triggerring by [another upstream job][1].
*   Triggerring by [timer schedule][2].

# Bootstrap Package #

Bootstrap package combines all necessary information
(all required software + target site configuration) together with
bootstrap script which runs the deployment.

In order to generate bootstrap package, run (`state.sls`)
`bootstrap.generate_content` state directly because this state
is not (normally) triggered by `highstate`.

Remember that generated bootstrap package uses configuration from
`bootstrap-target` pillars - the necessary branch has to be checked out
and updated to the configuration required on the target system.

# Automatic host provisioning using Vagrant #

If minions are configured with Vagrant provisioning
(its `instantiated_by` key should be set to `vagrant_instance_configuration`),
`Vagrant` file is automatically generated on `highstate`.

The location of the `Vagrantfile` is specified by `vagrant_files_dir` key.

Note that `Vagrantfile` uses bootstrap package - see
how to generate bootstrap package.

# [footer] #

[1]: /docs/pillars/common/system_features/configure_jenkins/job_configs/_id/trigger_jobs/readme.md
[2]: /docs/pillars/common/system_features/configure_jenkins/job_configs/_id/timer_spec/readme.md
[3]: /pillars/profile
[4]: /docs/pillars/common/bootstrap_mode/readme.md
[5]: /docs/pillars/common/system_hosts/_id/consider_online_for_remote_connections/readme.md

