
## What is bootstrapping? ##

Bootstrapping is a process of deploying system on a clean unconfigured OS.

Deployable resources can either be provided offline locally
on target Salt minion, or on (remote) Salt master, or be downloadable
from Internet, or accessible within isolated network - this can be made
a configuration option.

The main point is to provide a package which installs system
anywhere on clean OSes (virtual guests or bare metal hosts).

## Achieving total control ##

### Clean OS ###

Salt cannot istall itself as this process turns
into "chicken and egg" problem
(installing Salt is required for installing Salt).

Initial Salt installation and configuration should be done by other means.

### Clean OS + Salt ###

Once Salt is installed and configured on a clean OS, the task of
configuring the rest of the system can already be done by Salt itself.

In other words, the key to system bootstrap is actually installing Salt only.

### Hardware provisioning ###

Salt obviously cannot redefine parameters of hardware resources which are
in use by OS where it executes. However, there are also two cases:
physical machines and virtual machines.

When it comes to _virtual_ machine, hardware parameters, OS type, and image
can actually be programmatically defined before provisioning. This opens
a door to make Salt instruct _hypervisor_ or _host OS_ to instantiate all
other nodes required by the managed system with all parameters defined
_through_ Salt configuration.

In case of virtualization, bootstrapping can be used to deploy only Salt
minion and continue [orchestrated](orchestration.md) system installation
with all resources available on the network.

### Solution ###

Only the initial Salt environment has to be manually set up
so that the rest of Salt environments are set up automatically using
bootstrap packages created by other environments.

This case is not "chicken and egg" problem,
it is rather "chicken spawns chicken" solution.

This process is described in [document][3] about creating bootstrap package.

The main scenario for boostrapping is to deploy configured Salt minion using
automated script in a bootstrap package. Then pass control to Salt states to
deploy all software components required by the system.

# [footer] #

[1]: https://en.wikipedia.org/wiki/Template_method_pattern
[2]: https://en.wikipedia.org/wiki/Factory_method_pattern
[3]: docs/bootstrap/create_package.md

[13]: #offline-minion-installer
[14]: #initial-online-node

[20]: docs/pillars/common/registered_content_config/URI_prefix/readme.md

[30]: http://docs.saltstack.com/en/latest/ref/configuration/master.html#auto-accept

