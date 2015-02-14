
Key `vagrant_instance_configuration` specifies Vagrant configuration per host.

In order for this configuration to take effect, value of key [instantiated_by][1]
should be the name of this key (`vagrant_instance_configuration`).

See also system-wide (or global) [vagrant_configuration][2].

## Network ##

State [common.vagrant][3] configures [Vagrant file][4] to create a
[public network][5] which basically means that it will be bridged with
existing host's network interface.

This network can potentially be accessed from anywhere (depending on
the interface which was used for the bridge) - see [host_bridge_interface][6]
configuration per host.
IP addresses for virtual hosts are managed within the system and, therefore,
picked from [internal_net][7] configuration.

## _footer_ ##

[1]: docs/pillars/common/system_hosts/_id/instantiated_by/readme.md
[2]: docs/pillars/common/system_features/vagrant_configuration/readme.md
[3]: docs/states/common/vagrant/init.sls.md
[4]: http://docs.vagrantup.com/v2/vagrantfile/
[5]: http://docs.vagrantup.com/v2/networking/public_network.html
[6]: docs/pillars/common/system_hosts/_id/vagrant_instance_configuration/host_bridge_interface/readme.md
[7]: docs/pillars/common/internal_net/readme.md

