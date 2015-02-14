
State `common.vagrant` deploys `Vagrant` file in 

As soon as file is deployed, instantiating virtual machines is done by
the following command inside [vagrant_file_dir][1]:
```
sudo vagrant up --provider virtualbox
```
Note:
* Use `sudo` make sure Vagrant is able to re-create network interfaces.
* It is required to specify `--provider` otherwise Vagrant resorts to `libvirt` on Linux even if `config.vm.provider` is specified in Vagrant file.

It may be required to add IP address to the relevant host's (hypervisor's)
network interface, if it's not done by Valgrant:
```
sudo ip addr add dev em1 192.168.50.5/24
```

TODO:
* Add `libvirt` provider support. Currently, only `virtualbox` provider worked predictably without blocking issues.

[1]: docs/pillars/common/system_features/vagrant_configuration/vagrant_file_dir/readme.md

