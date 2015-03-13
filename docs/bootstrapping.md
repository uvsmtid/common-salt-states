
## What is bootstrapping? ##

Bootstrapping is a process of deploying system on a clean unconfigured OS.

Deployable resources can iether be provided offline locally, or still be
downloadable from Internet, or accessible within isolated network -
this can be made a configuration option. The main point is to provide
support of installation on virtual guests or bare metal hosts with clean OSes.

## Achieving total control ##

### Clean OS configuration ###

Salt cannot istall itself because it is "chicken and egg" problem.
Initial Salt installation and configuration should be done by other means.

Note that it is still possible to install Salt using another Salt
pre-installed on external media (i.e. on a USB disk). This case is
not "chicken and egg" problem, it is rather "chicken spawns chicken" solution.

One of the possible scenarios for boostrapping here is to deploy Salt minion
and use Salt states to install all software components using offline locally
available resources.

### Hardware configuration ###

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

## General approach for bootstrapping ##

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

## Use Cases ##

Ultimately, all Use Cases set up Salt minion. This is inevitable because
only Salt minion is able to execute all configuration steps eventually
required to complete setup.
* [initial-master][11] case sets up Salt master and Salt minion on the same
  host where Salt minion receives configuration data from its Salt master.
* [online-minion][12] case obviously sets up Salt minion where Salt master
  is already assumed running somewhere on the network.
* [offline-minion-installer][13] sets up Salt minion with additional master-side
  configuration to make it autonomous (requiring no connection to Salt master
  to retrieve configuration data).

### `initial-master` ###

**Case:**
* Run bootstrap script to configure new Salt master for specific
  project/profile.
* Cloud deployment where master itself is virtualized and
  should be prepared automatically.
* Starts both services: Salt master and Salt minion.

**Input:**
* Salt master and minion software packages.
* Salt master and minion configuration files.
* At least project id and profile id, possibly Satl minion id (but this
  can be derived from pillar).
* Salt states sources to complete setup through Salt itself using
  profile configuration data.
* All additional artifacts used for Salt master and minion for
  specified project/profile.

**Simplifications:** none.

**Complications:**
* Collecting all resources and build such package should be done
  automatically (i.e. in Jenkins job).
* Moreover, to keep packages consistent, the build process must comply
  wiht one definition rule and rely on pillar data for specific
  project/profile. There is a problem to access pillar data for other
  project/profiles if it was not published through pillar top file.

**Solution:**
* Use Salt API in Python script to run build process based on
  configuration data in the pillar.
* In order to access pillar from specific project/profile,
  Salt master configuration file on the system which performs
  such builds should provide list of other projects/profiles.
  The top files shall use this list to include these pillar files
  under specific keys (pillars can be included under specific keys
  to avoid merging them at the top level).

### `online-minion` ###

**Case:**
* Run bootstrap script to connect new Salt minion to Salt master.
* Activate newly spawned VM or PXE-booted host participating in the system.
* Starts single service: Salt minion.

**Input:**
* Salt minion software packages.
* Salt minion configuration file.
* Salt minion id matched to one of those in system profile.
* Possibly Salt master's IP to avoid reliance on DNS.

**Simplifications:**
* It can be assumed that master is already configured and running.
  Therefore, everything can be pre-generated by the running master
  and provided to this minion as data (simplified logic for the script).
* All resources can be pushed to such minion from existing master.
  There is no need to built a package to be used offline.

**Complications:** none.

### `offline-minion-installer` ###

**Case:**
* This bootstrap is a "pre-built" installer which is run on individual
  hosts in Salt master-less environment to configure machine based on
  pillar profile configuration.
* Install all required software for specific host as `highstate` specifies.
* Starts _none_ of the services: _niether_ Salt master _nor_ Salt minion.

**Input:**
* All input is similar to `initial-master` case.
  The only difference is that all information which goes to Salt master
  configuration file should be defined completely in Salt minion
  configuration file.

**Simplifications:**
* It can be created as a special mode for `initial-master` case.

**Complications:**
* The inter-dependencies between required states should be well defined
  to let `highstate` complete successfully. However, these inter-dependencies
  were deliberately removed (reduced) for orchestration to "pull" less
  dependent states on each orchestration step which are run reduntantly.

## Design ##

* The bootstrap shall be a framework with single front-end Python script.
* The bootstrap framework shall allow extending it to support variations
  of operating system and system software versions.
* There are two possible environments:
  * The _source environment_ is where the packages are built.
  * The _target environment_ is where the packages are deployed.
  Packages created by any source environment must be the same as long as
  they are built for the same target environment.
* The framework shall recognize and _support_ multiple _target environments_
  and be able to generate package for any of them.
* It is recoginized that there is also _source environment_ where the package
  was built, but there is no need to _support_ multiple _source environments_:
  * When packages are built, Salt is used. Salt is fully aware of
    all parameters of its own (source) enviromnent and bootstrap framework
    shall not be complicated to provide this redundant functionality.
  * When packages are deployed, bootstrap framework shall not depend
    on information what was the source environment the packages were
    built in.
* The bootstrap framework shall support both operations:
  * _Build_ package for target environment.
  * _Deploy_ package in target environment.
  NOTE: The `deploy` operation shall depend on much less external prerequisites
  compared to `build` operation. In fact, `deploy` should use minimum
  available on newly installed clean unconfigured OSes.
* [Template Method][1] pattern shall be used to implement actions:
  * The base class calls all steps and provides coordination between them to
    achieve specific [Use Case][10].
  * The sub-classes implement steps for specific operating system.
* It is expected that some implementations for specific steps will differ
  across operating systems and some not. For example, it may depend on:
  * Windows or Linux to select `cmd` or `bash` scripts;
  * Python version to use select Python imports;
  * PID 1 (`init` or `systemd`) to select service management commands;
  * etc.
  In order to reduce code duplication, there should be a library implementing
  all steps for generic or specific variations of the supported environments.
  The sub-classes shall implement their steps by simply calling necessary
  implementation from the library.
* [Factory method][2] pattern shall be used to match target
  environment to specific sub-classes implementing the case.

## Implementation ##

### General ###

* The front-end script is `bootstrap.py`.
* Script accepts the following parameters:
  * `$1` - bootstrap action, for example: `deploy`
  * `$2` - bootstrap use case, for example: `initial-master`
  * `$3` - bootstrap target environment, for example:
    ```
    examples/uvsmtid/centos-5.5-minimal
    ```
    or
    ```
    ```
* The action Template Methods are implemented in `actions.*` modules.
* Use case is a parameter for action template method coordinate
  setup steps differently depending on the use case.
* Bootstrap environment points to one of the configuration files under `conf`
  directory. These configuration files are Python modules containing
  primarily value assignments to data structures for each step.
* Among other things, configuration file specifies `target_platform` which
  points to specific implementation of Themplate Method in `platforms.*`
  modules.
* All configuration files are generated through Salt.
* Each implementation of Template Method requires multiple steps.
  Instead of implementing them directly, `platforms.*` modules simply call
  existing (outside of the class) implementation in `steps.[step name].*`
  module.

### Build ###

In addition to general approach, `build` action has some
pecularities to note:
* Pillar data has [URI_prefix][20] key which specifies where all resources
  are placed. In order to make sure this prefix points to local filesystem
  for bootstrap `deploy` action, the value of `URI_prefix` has to be
  rewritten to `salt://` URI scheme.

TODO: `pillar['registered_content_config']['URI_prefix']` is not used anymore.

TODO: What else `build` actually does? Downloads resources? Checks out
repositories? And, as above, rewrites pillar.

### Deploy ###

TODO: Is there something to mention for `deploy` action?

## Facts ##

* Both Salt master and Salt minion configuration files can specify exactly
  the same information:
  * If it is a Salt minion connected to Salt master, most of required
    configuration file.
  * If it is a sandalone Salt minion, it requires all configuration,
    which normally belongs to Salt master, to be specified in Salt minion
    configuration file.
* The important note is about is custum configuration keys - Salt minion
  custom configuration keys _always overwrite_ Salt master's ones.
  In other words, whether `salt`, or `salt-call`,
  or `salt-call` with `--local` option command is used, if Salt minion
  configuration file had the same custom configuraton key, the value
  used will come from this Salt minion configuration file.


# [footer] #

[1]: https://en.wikipedia.org/wiki/Template_method_pattern
[2]: https://en.wikipedia.org/wiki/Factory_method_pattern

[10]: #use-cases
[11]: #initial-master
[12]: #online-minion
[13]: #offline-minion-installer

[20]: docs/pillars/common/registered_content_config/URI_prefix/readme.md


