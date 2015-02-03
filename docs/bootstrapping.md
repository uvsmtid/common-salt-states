
## What is bootstrapping?

Bootstrapping is a process of deploying system on a clean unconfigured OS.

Deployable resources can iether be provided offline locally, or still be
downloadable from Internet, or accessible within isolated network -
this can be made a configuration option. The main point is to provide
support of installation on virtual guests or bare metal hosts with clean OSes.

## Achieving total control

### Clean OS configuration

Salt cannot istall itself because it is "chicken and egg" problem.
Initial Salt installation and configuration should be done by other means.

Note that it is still possible to install Salt using another Salt
pre-installed on external media (i.e. on a USB disk). This case is
not "chicken and egg" problem, it is rather "chicken spawns chicken" solution.

One of the possible scenarios for boostrapping here is to deploy Salt minion
and use Salt states to install all software components using offline locally
available resources.

### Hardware configuration

Salt obviously cannot redefine parameters of hardware resources which are
in use by OS where it executes. However, there are also two cased:
physical machines and virtual machines.

When it comes to _virtual_ machine, hardware parameters, OS type, and image
can actually be programmatically defined before provisioning. This opens
a door to make Salt instruct _hypervisor_ or _host OS_ to instantiate all
other nodes required by the managed system with all parameters defined
_through_ Salt configuration.

In case of virtualization bootstrapping can be used to deploy only Salt minion
and continue [orchestrated](orchestration.md) system installation with
all resources available on the network.

## General approach for bootstrapping

The common idea to all bootstrapping cases is to install Salt minion first.
On Linux it can be online or offline yum repositories with necessary packages.
On Windows installer supports [unnattended installation](https://github.com/saltstack/salt-windows-msi/blob/master/README.md).

Then, generage temporary configuration file using a set of minimal parameters:
* Node type: minion or master
* Project name
* Profile name

Additional parameters are used later to apply required state in offline mode
with temporary generated configuration file using command `salt-call --local`:
* Salt function (i.e. `state.sls`)
* Arguments to Salt function

Note that all salt functions are executed executed non-stop by Salt minion
without providing any chance to suspend execution. If external resources
(i.e. network file servers) are not available during some state execution,
it will simply fail. Therefore, bootstrapping should use Salt function
which is provided with everything it need to complete on target minion.
Otherwise, [orchestrated](orchestration.md) has to be used.

## Scripts

TODO

