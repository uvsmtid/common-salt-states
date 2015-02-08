
State `common.jenkins.slave` simply ensures that Java is provided to run Jenkins Slave.

All required software installation which is supposed to exists on Jenkins Slave
to successfully run certain jobs is handled by assigning different [system_host_roles](docs/projects/common/pillars/system_host_roles/readme.md)
to the same minions. It is a common sense because otherwise Jenkins Slaves
will potentially have too complex installation with too many pre-requisite
software to satisfy all possible types of jobs on all possible types of systems.

