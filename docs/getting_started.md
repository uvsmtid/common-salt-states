# Getting Started #

This document is about getting started in framework set by
these `common` Salt states. For Salt introduction itself refer to
[the official documentation][4].

All steps are applicable to any OS, however, examples are given for
RedHat Linux 5 (RHEL5) only (and will lagerly work on RHEL6 and RHEL7 too).
To keep it specific, [this link][5] describes initial clean RHEL5-compartible
CentOS image as an example.

The steps below assume that both Salt master and Salt minion have to be
installed and configured on _the same single host_ for the first time.

## Initial Salt setup ##

### Complications ###

The installation itself is straightforward for new Linux distributions
(just install a package), but it may also get obstructed by network issues
(which _are_ discussed here because they are far too common
in secured network environments).

Old Linux distributions like RHEL5 also require few more steps because
there is no default repository (i.g. YUM) which provides Salt packages.

### Chicken and Egg problem ###

Salt is used to automate installation,
but how do we install Salt itself in the first place?

There are two ways:
*   Manual approach discussed in this document.
*   Automatic [bootstrap approach][1] -
    a way to bring up entire system including Salt using
    pre-build _bootstrap package_ which is specific to target system.

### Common network problems ###

If you are behind a proxy, configure proxy for YUM:

```
vi /etc/yum.conf
```

For example:

```
...
# Proxy settings
proxy=http://PROXY_HOSTNAME:PROXY_PORT/
proxy_username=PROXY_USERNAME
proxy_password=PROXY_PASSWORD
...
```

In order to resolve proxy hostname, you will also need to make sure that
DNS settings in `/etc/resolv.conf` file point to correct DNS server,
for example:

```
nameserver 10.20.30.40
```

If you don't have a DNS server on the network, use either IP address in
proxy configuration or specify hostname in the hosts file `/etc/hosts`:

```
50.60.70.80 PROXY_HOSTNAME
```

Sometimes "proxied" YUM does not like mirror list URLs and complains like this:

```
Loaded plugins: fastestmirror, security
Determining fastest mirrors
Could not retrieve mirrorlist http://mirrorlist.centos.org/?release=5&arch=x86_64&repo=os error was
[Errno 4] IOError: <urlopen error (-3, 'Temporary failure in name resolution')>
Error: Cannot find a valid baseurl for repo: base
```

The idea is to use `baseurl` instead of `mirrorlist` option
in repository configuration files (record shows they are more robust).
Use this command to modify all YUM repositories:

```
for FILE in /etc/yum.repos.d/*.repo ; do vim $FILE ; done
```

Sometimes YUM does not work with `https` URLs (because of proxy).
Change them to simple `http` in all YUM repository configuration files.
If required repository is not accessible via `http` and `https` does
not work either, there is no simple solution - good luck.

Try running this command:

```
yum info salt-master
```

If it is successful, YUM configuration is not requierd.
For RHEL5 follow the steps in subsections.

### RHEL5 ###

The problem with RHEL5 is that it does not have default repository which
contain `salt-*` packages by default.

#### EPEL YUM ####

They used to be in a separate `EPEL` repository,
but they were [removed later][6] because of discontinued maintenance of some
dependencies. Nevertheless, EPEL may still be required for other dependencies.

Normally, you can configure this repository yourself,
but there is an RPM package for this:

```
rpm -ihv epel-release-5-4.noarch.rpm
```

The package is available online at any EPEL mirror:

```
http://MIRROR_HOSTNAME/mirror/epel/5/x86_64/epel-release-5-4.noarch.rpm
```

It is better to use RPM because it also installs RPM sign keys
for all packages from EPEL.

#### Salt YUM ####

Official RHEL5 YUM repository for Salt is now [here][7].

In order to configure Salt YUM repository,
download [this file][8] into `/etc/yum.repos.d`
or create file `/etc/yum.repos.d/saltstack-salt-el5-epel-5.repo` manually (content may be outdated):

```
[saltstack-salt-el5]
name=Copr repo for salt-el5 owned by saltstack
baseurl=https://copr-be.cloud.fedoraproject.org/results/saltstack/salt-el5/epel-5-$basearch/
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/saltstack/salt-el5/pubkey.gpg
enabled=1
```

### Installation ###

If you run both Salt master and Salt minion on the same host
(as this document expects), install both:

```
yum install salt-master salt-mininon
```

### Simplest configuration ###

In order to use all defaults and make sure that Salt minion
finds Salt master automatically, `salt` hostname should be
resolvable (by any means: DNS, hosts file, etc.).

In the simplest case of single host with both Salt master and minion
just add `salt` into your hosts file `/etc/hosts` pointing to
local IP address:

```
salt 127.0.0.1
```

Minion is identified by its minion id.
Run this command (substitute `some_minion_id` with something meaningful):

```
echo some_minion_id > /etc/salt/minion_id
```

### Run ###

*Enable* Salt minion and Salt master services:

```
chkconfig salt-master on
chkconfig salt-minion on
```

*Start* Salt minion and Salt master services:

```
service salt-master start
service salt-minion start
```

### Accept Salt minion keys ###

Next thing is Salt security.

All you need is to accept Salt minion key on Salt master side.

When Salt minion starts it sends its public key to the Salt master
(which it finds by resolving `salt` hostname).
Until you accept this public key, you cannot control this Salt minion.

Use `salt-key` to see status of all public keys on Salt master side:

```
salt-key
```

List `Accepted Keys` shows all registered minions.

*   Delete keys of those minions which are not supposed to be controlled.

    ```
    salt-key -d <key> # delete
    ```

*   Accept keys of those minions which are     supposed to be controlled.

    ```
    salt-key -a <key> # accept
    ```

Keys are named after minion ids.

### Test ###

The following command will test replies from all (`*`) accepted minions:

```
salt '*' test.ping
```

## Multi-project organization ##

These sources are the framework to provide automation for multiple
projects. The steps below assume there is a project named `project_name`.

The necessary details on how multiple porjects are used can be
found on [this page][2].

## Sources and Resources ##

_Sources_ are source code repositories.
This framework may be configured to access necessary sources.

_Resources_ are all other files which are not supposed to be under source
control (at least with source code).
These can be installers, executables, data files, etc.
This framework may also be configured to access such files.

There are multiple ways to provide access to resources. The most flexible
approach is to use external file server (FTP or HTTP).
However, the simplest solution is to use Salt itself. Salt can be used as
a file server (with `salt://` URL scheme to access files from states).

For ease of managing and distributing, it is assumed resources are also
available in their separate repositories.

## Salt master configuration ##

The following section highlights some important configuration for
Salt master configuration file (`/etc/salt/master`) to use automation
for specific `project_name` with necessary access to sources, resources, etc.

These steps should be reviewed when the framework is reconfigured to
use another `project_name`.

### Specify files and states location in Salt configuration ###

Specify location where Salt looks up file references (including state files)
under `file_roots` key in Salt configuration file:

```
file_roots:
    base:
        # Conventionally, the following directory is a symlink pointing to
        # `/home/[username]/Works/common-salt-states.git/states`
        - /srv/states

        # The following directory is a common place for all additional
        # symlinks pointing to various source code repositories.
        # These symlinks are configured automatically by using
        # `common.source_symlinks` state - see below.
        - /srv/sources

        # A directory with symlinks to resources.
        - /srv/resources
```

Note that sub-items (directories or files) under `resources` (listed
after `states` and `sources`) are only accessible if they are not hidden
by items in `states` and `sources`.

For example, `salt://whatever` is always looked up as:
*   `/srv/states/whatever` first
*   before it has a chance to be looked up as `/srv/sources/whatever`
*   before it has a chance to be looked up as `/srv/resources/whatever`

**NOTE**:
For the sake of quick try, `project_name`-specific repository is not required.

### Clone `common` Salt states ###

Checkout (these) `common` Salt states sources (if not done yet):

```
git clone git@[hostname]:[username]/common-salt-states.git ~/Works/common-salt-states.git
```

### Clone `project_name`-specific Salt states ###

**NOTE**:
For the sake of quick try, `project_name`-specific repository is not required.

The `project_name`-specific Salt states are supposed to be in separate repository.
Checkout `project_name`-specific Salt states sources (if not done yet):

```
git clone git@[hostname]:[username]/[project_name]-salt-states.git ~/Works/[project_name]-salt-states.git
```

### Link `common` Salt states ###

Set `/srv/states` symlink to the Salt `common` states sources, for example:

```
ln -sfn /home/[username]/Works/common-salt-states.git/states /srv/states
```

Result of this step should look like this:

```
/srv/states -> /home/[username]/Works/common-salt-states.git/states
```

### Link `project_name`-specific Salt states ###

**NOTE**:
For the sake of quick try, `project_name`-specific repository is not required.

Add symlink _within_ (under) Salt `common` states pointing to
repository with `project_name`-specific Salt states, for example:

```
ln -sfn /home/[username]/Works/[project_name]-salt-states.git/states/[project_name] /srv/states/[project_name]
```

Result of this step should look like this:

```
/srv/states/[project_name] -> /home/[username]/Works/[project_name]-salt-states.git/states/[project_name]
```

### Clone `common` Salt resources ###

Checkout (these) `common` Salt resources sources (if not done yet):

```
git clone git@[hostname]:[username]/common-salt-resources.git ~/Works/common-salt-resources.git
```

### Clone `project_name`-specific Salt resources ###

**NOTE**:
For the sake of quick try, `project_name`-specific repository is not required.

The `project_name`-specific Salt resources are supposed to be in separate repository.
Checkout `project_name`-specific Salt resources sources (if not done yet):

```
git clone git@[hostname]:[username]/[project_name]-salt-resources.git ~/Works/[project_name]-salt-resources.git
```

### Link Salt resources ###

The resources are linked automatically later by Salt itself
using `common.resource_symlink` state.

### Specify pillars location in Salt configuration ###

Specify location where Salt loads pillars under `pillar_roots` key in
Salt configuration file:

```
pillar_roots:
    base:
        - /srv/pillars
```

### Link Salt pillars ###

Pillars are always `project_name`-specific (they provide configuration data
for both `common` Salt states and `project_name`-specific Salt states).

**NOTE**:
It is possible to use pillars in `common-salt-states.git` repo
(i.g. as a demo with example configuration in its `pillars` directory).
The clone of `common-salt-states.git` repo named as `common-salt-pillars.git`
is still required to avoid modification of
example `pillars` in original repository.

Checkout `project_name`-specific Salt pillars sources (if not done yet):

```
git clone git@[hostname]:[username]/[project_name]-salt-pillars.git ~/Works/[project_name]-salt-pillars.git
```

### Link `project_name`-specific Salt pillars ###

**NOTE**:
For the sake of quick try, assume `project-name`=`common`.

Set `/srv/pillars` symlink to the Salt pillars sources:

```
ln -sfn /home/[username]/Works/[project_name]-salt-states.git/pillars /srv/pillars
```

Result of this step should look like this:

```
/srv/pillars/[project_name] -> /home/[username]/Works/[project_name]-salt-pillars.git/pillars
```

### Provide Salt configuration ###

The framework require several parameters
in Salt master configuration file:

```
this_system_keys:
    # ...
    # Salt master orchestrates only one `project_name`:
    project_name: project_name
    profile_name: profile_name
    master_minion_id: minion_id
    default_username: username
    # ...
```

**NOTE**:
For the sake of quick try, assume `project-name`=`common`.

See description for parameters:
*   [project_name][9]
*   [profile_name][10]
*   [master_minion_id][11]
*   [default_username][12]

### Run state to setup sources and resources symlinks ###

At this point, there should be initially installed and running Salt master
and Salt minion services.

*   Restart them to update their runtime configuration accordingly:

    ```
    service salt-master restart
    service salt-minion restart
    ```

*   Test dummy state execution:

    ```
    salt-call --local state.sls common.dummy test=True
    ```

*   Test states (dry run):

    ```
    salt '*' state.sls common.source_symlinks test=True
    salt '*' state.sls common.resource_symlinks test=True
    ```

*   Apply states:

    ```
    salt '*' state.sls common.source_symlinks test=False
    salt '*' state.sls common.resource_symlinks test=False
    ```

## Next steps ##

See `project_name`-specific documentation which states to run to complete setup.

In majority of cases, when all minions are already connected,
simply run `highstate` to setup everything:

*   Test highstate (dry run):

    ```
    salt '*' state.highstate test=True
    ```

*   Apply highstate:

    ```
    salt '*' state.highstate test=False
    ```

This will bring all minions to the fully configured state.

In a more complicated system, especially when some minions should be
set up first to provide services for other minions (cross-host dependency
on services), orchestration can be used - see [this page][3].

## Master-less Salt minion configuration ##

This section demonstrates how to use master-less Salt minion.

*   Follow (section on initial Salt setup above)[#initial-salt-setup].
    Install only `salt-minion` package.
    Enable and start only `salt-minion` service.

*   Follow (section on Salt master configuration above)[#salt-master-configuration].
    Provide the same information in `/etc/salt/minion`
    (Salt minion configuration file)
    which was meant for `/etc/salt/master`
    (Salt master configuration file).

*   Test dummy state execution:

    ```
    salt-call --local state.sls common.dummy test=True
    ```

*   Test highstate (dry run):

    ```
    salt-call --local state.highstate test=True
    ```

*   Apply highstate:

    ```
    salt-call --local state.highstate test=False
    ```

# [footer] #

[1]: docs/bootstrap/readme.md
[2]: docs/framework.md
[3]: docs/orchestration.md
[4]: http://docs.saltstack.com/
[5]: https://github.com/uvsmtid/vagrant-boxes/tree/master/centos-5.5-minimal
[6]: http://docs.saltstack.com/en/latest/topics/installation/rhel.html
[7]: https://copr.fedoraproject.org/coprs/saltstack/salt-el5/
[8]: https://copr.fedoraproject.org/coprs/saltstack/salt-el5/repo/epel-5/saltstack-salt-el5-epel-5.repo
[9]: docs/configs/common/this_system_keys/project_name/readme.md
[10]: docs/configs/common/this_system_keys/profile_name/readme.md
[11]: docs/configs/common/this_system_keys/master_minion_id/readme.md
[12]: docs/configs/common/this_system_keys/default_username/readme.md
