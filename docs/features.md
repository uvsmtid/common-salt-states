
TODO: Populate draft with more details.

# Offline installation #

## Disable online checks ##

If there is a top level key `bootstrap_mode` set to `offline-minion-installer`,
some states which depend on availability of other hosts online
will be disabled.

This is primarily applied to ignore hosts with
`consider_online_for_remote_connections` set to `True`.

This is specifically designed to achieve maximum
possible configuration offline.

See also:
*   [`bootstrap_mode`][4]
*   [`consider_online_for_remote_connections`][5]

# Jenkins #

Jenkins is automatically configured to self-test `common-salt-states` with
its [template profile in pillars][3] to perform bootstrap of nodes
from clean OS.

Configuration of the jobs may specify:
*   Triggerring by [completion of another upstream job][1].
*   Triggerring by [timer schedule][2].

# [footer] #

[1]: /docs/pillars/common/system_features/configure_jenkins/job_configs/_id/trigger_after_jobs/readme.md
[2]: /docs/pillars/common/system_features/configure_jenkins/job_configs/_id/timer_spec/readme.md
[3]: /pillars/profile
[4]: /docs/pillars/common/bootstrap_mode/readme.md
[5]: /docs/pillars/common/system_hosts/_id/consider_online_for_remote_connections/readme.md

