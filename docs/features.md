
TODO: Populate draft with more details.

# Jenkins #

Jenkins is automatically configured to self-test `common-salt-states` with
its [template profile in pillars][3] to perform bootstrap of nodes
from clean OS.

Configuration of the jobs may specify:
*   Triggerring by [completion of another upstream job][1].
*   Triggerring by [timer schedule][2].

# [footer] #

[1]: docs/pillars/common/system_features/configure_jenkins/job_configs/_id/trigger_after_jobs/readme.md
[2]: docs/pillars/common/system_features/configure_jenkins/job_configs/_id/timer_spec/readme.md
[3]: pillars/profile


