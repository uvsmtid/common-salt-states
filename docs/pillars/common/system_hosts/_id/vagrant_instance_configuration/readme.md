
Key `vagrant_instance_configuration` specifies Vagrant configuration per host.

In order for this configuration to take effect, value of key [instantiated_by][1]
should be the name of this key (`vagrant_instance_configuration`).

See also system-wide (or global) [vagrant_configuration][2].

## Network ##

State [common.vagrant][3] configures [Vagrantfile][4] to create a
[public network][5] or [private network][8] depending on [network_type][9]
key.

* If `public_network` is used, it will be bridged with existing host's
  network interface.
  
  This network can potentially be accessed from anywhere (depending on
  the interface which was used for the bridge) -
  see [host_bridge_interface][6] configuration per host.
* If `private_network` is used, Vagrant is supposed to create network
  named according to what [resolved_in][10] specifies.
  
  Note that Vagrant does not restrict using IP addresses only from
  [private address space][11].

The only difference between `public_network` and `private_network`
at the moment is that `private_network` does not require physical device
(to bridge with).

Do not confuse `public_network` and `private_network` in Vagrant's sense
with [external_net][12] and [internal_net][7] in configuration's sense
(which is about admin authority over IP address ranges).

## _footer_ ##

[1]: docs/pillars/common/system_hosts/_id/instantiated_by/readme.md
[2]: docs/pillars/common/system_features/vagrant_configuration/readme.md
[3]: docs/states/common/vagrant/init.sls.md
[4]: http://docs.vagrantup.com/v2/vagrantfile/
[5]: http://docs.vagrantup.com/v2/networking/public_network.html
[6]: docs/pillars/common/system_hosts/_id/vagrant_instance_configuration/host_bridge_interface/readme.md
[7]: docs/pillars/common/system_networks/internal_net/readme.md
[8]: http://docs.vagrantup.com/v2/networking/private_network.html
[9]: docs/pillars/common/system_hosts/_id/vagrant_instance_configuration/network_type/readme.md
[10]: docs/pillars/common/system_hosts/_id/resolved_in/readme.md
[11]: https://en.wikipedia.org/wiki/Private_network
[12]: docs/pillars/common/system_networks/external_net/readme.md

