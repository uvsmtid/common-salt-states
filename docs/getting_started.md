# Getting Started #

This document is about getting started in framework set by
these common Salt states. For Salt introduction itself refer to
[the official documentation][4].

All steps are applicable to any OS, however, examples are given for
RedHat Linux 5 (RHEL5).

The steps below assume that both Salt master and Salt minion are installed
on the same single host for the first time.

## Initial Salt setup ##

### Chicken and Egg problem ###

Salt is used to automate installation,
but how do we install Salt itself in the first place?

Initial configuration includes several steps.
And that's exactly the purpose of Salt -
to automate configuration with multiple steps.
Hence, chicken and egg problem.

There are two ways:
*   Manual approach discussed in this document.
*   (Bootstrap approach)[1] -
    automated way to bring up entire system including Salt.

Manual approach is only relatively difficult for old Linuxes and any Windowses
because no default repository (i.e. YUM) provides required software.

### Common network problems ###

If you are behind a proxy, configure youre proxy for YUM:
```
vi /etc/yum.conf
```

For example:
```
...

# Proxy settings
proxy=http://HOSTNAME:PORT/
proxy_username=USERNAME
proxy_password=PASSWORD

...

```

In order to resolve proxy hostname, you'll have to add DNS servers:
```
/etc/resolve.conf
```

For example:
```
nameserver 10.20.30.40
```

Sometimes "proxied" YUM does not like mirror list URLs:
```
yum install salt-minion
```

```
Loaded plugins: fastestmirror, security
Determining fastest mirrors
Could not retrieve mirrorlist http://mirrorlist.centos.org/?release=5&arch=x86_64&repo=os error was
[Errno 4] IOError: <urlopen error (-3, 'Temporary failure in name resolution')>
Error: Cannot find a valid baseurl for repo: base
```

The idea is to use `baseurl` instead of `miirrorlist` option
in repository configuration files:
```
for FILE in /etc/yum.repos.d/*.repo ; do vim $FILE ; done
```

Sometimes YUM does not work with `https` URLs (because of proxy).
Change them to simple `http` in all YUM repository configuration files.
If required repository is not accessible via `http` and `https` does
not work either, there is no simple solution.


### RHEL5 ###

The problem with RHEL5 is that it does not contain `salt-*` packages by default.

They are in a separate `EPEL` repository.

Normally, you can configure this repository yourself, but there is an RPM package
for this:
```
rpm -ihv epel-release-5-4.noarch.rpm
```
The package is available online at:
```
http://MIRROR_HOSTNAME/mirror/epel/5/x86_64/epel-release-5-4.noarch.rpm
```

It is better to use RPM because it also installs RPM sign keys
for all packages from EPEL.

### Installation ###

If you run both Salt master and Salt minion on the same host, install both:
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

### Security ###

Next thing is Salt security.

All you need is to accept Salt minion key on Salt master side.

When Salt minion starts it sends its public key to the Salt master it finds
by resolving `salt` hostname. Until you accept this public key, you cannot
control this Salt minion.

Use `salt-key` to see status of all public keys on Salt master side:
```
salt-key
```

List "Accepted Keys" shows all registered minions.

Delete keys of those minions which are not supposed to be controlled.
Accept keys of those minions which are     supposed to be controlled.

```
salt-key -d <key> # delete
salt-key -a <key> # accept
```

Keys are named after minion ids.

### Test ###

The following command will test replies from all (`*`) accepted minions:
```
salt '*' test.ping
```

## Multi-project organization ##

These sources are the framework to provide automation for multiple projects.

The necessary details on how multiple porjects are used can be
found on [this page][2].

## Sources and Resources ##

_Sources_ are source code repositories (managed by SCMs).
Salt may be configured to access sources necessary in some cases.

_Resources_ are all other files which are not supposed to be under source
control. These can be installers, executables, data files, etc.
Salt may also be configured to access such files.

There are multiple ways to provide access to resources. The most flexible
approach is to use external file server (FTP or HTTP).
However, the simples solution is to use Salt itself. Salt can be used as
a file server (with `salt://` URL scheme to access files from states).

## Salt master configuration ##

The following section highlights some important configuration for
Salt master configuration file (`/etc/salt/master`) to use automation
for specific project, provide access to sources, resources, etc.

These steps should be reviewed when Salt is reconfigured to
use another project.

### Configure Salt states, sources and resources in Salt configuration ###

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

For example, `salt://whatever` is always looked up
as `/srv/states/whatever` first
before it has a chance to be looked up as `/srv/sources/whatever`,
before it has a chance to be looked up as `/srv/resources/whatever`,

#### Common and Project-specific Salt states ####

Checkout (these) common Salt states sources (if not done yet):
```
git clone git@host:user/common-salt-states.git ~/Works/common-salt-states.git
```

Project-specific Salt states are supposed to be in separate repository.
Checkout project-specific Salt states sources (if not done yet):
```
git clone git@host:user/common-salt-states.git ~/Works/common-salt-states.git
```

Set `/srv/states` symlink to the Salt common states sources, for example:
```
ln -sfn /home/[username]/Works/common-salt-states.git/states /srv/states
```

Add symlink _within_ (under) Salt common states pointing to
repository with project-specific Salt states, for example:
```
ln -sfn /home/[username]/Works/[project_name]-salt-states.git/states/[project_name] /srv/states/[project_name]
```

Result of this step should look like this:
```
/srv/states                -> /home/[username]/Works/common-salt-states.git/states
/srv/states/[project_name] -> /home/[username]/Works/[project_name]-salt-states.git/states/[project_name]
```

### Location of Pillars ###

Pillars are always project-specific (they provide configuration data
for both common Salt states and project-specific Salt states).

Checkout project-specific Salt pillars sources (if not done yet):
```
git clone git@host:user/[project_name]-salt-pillars.git ~/Works/[project_name]-salt-pillars.git
```

Specify location where Salt loads pillars under `pillar_roots` key in
Salt configuration file:
```
pillar_roots:
    base:
        - /srv/pillars
```

Set `/srv/pillars` symlink to the Salt pillars sources:
```
ln -sfn /home/[username]/Works/[project_name]-salt-states.git/pillars /srv/pillars
```

Result of this step should look like this:
```
/srv/pillars               -> /home/[username]/Works/[project_name]-salt-pillars.git/pillars
```

### Selected project ###

This sources as a framework require specification of project id in Salt
master configuration file:
```
this_system_keys:
    # ...
    # Salt master orchestrates only one project:
    project: project_name
    # ...
```

This is used in some template files to access necessary states and pillars.

### Selected profile ###

This sources as a framework require specification of profile id in Salt
master configuration file:
```
this_system_keys:
    # ...
    profile: profile_name
    # ...
```

This is used in some template files to access necessary states and pillars.

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

See project-specific documentation which states to run to complete setup.

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

[1]: docs/bootstrap.md
[2]: docs/approach_for_multiple_projects.md
[3]: docs/orchestration.md
[4]: http://docs.saltstack.com/

