
Key `instantiated_by` specifies another key (which is supposed to exists
under [host_id][1]) to indicate configuration for automatic host instantiation.

At the moment, the following values are supported:
* `~` - none (host is instantiated manually)
* [vagrant_instance_configuration][2] - host is instantiated through Vagrant (see state [common.vagrant][3])

[1]: docs/pillars/common/system_hosts/_id/readme.md
[2]: docs/pillars/common/system_hosts/_id/vagrant_instance_configuration/readme.md
[3]: docs/states/common/vagrant/init.sls.md

