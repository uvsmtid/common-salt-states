## Getting Started

### Chicken and Egg problem


Salt is used to automate installation, but how do we install Salt itself in the first place?

Initial configuration can be a little complex and that's exactly the purpose of Salt to
automate complex configuration. Hence, chicken and egg problem.
So, is Salt still useful? Yes, of cource, if you don't confiugre installation of
Salt only, everything beyond this is potentially automate-able.

This question is only relatively diffult for old Linuxes and Windows because
no default YUM repository provides these packages.

### Common network problems


Simple step: configure youre proxy for YUM: `vi /etc/yum.conf`
```
...

# Proxy settings
proxy_username=YOUR_USERNAME
proxy_password=YOUR_PASSWORD

...

```

In order to resolve proxy hostname, you'll have to add DNS servers in `/etc/resolve.conf`:
```
nameserver 10.77.1.198
```

Sometimes "proxied" YUM does not like mirror list URLs, like this:
```
Loaded plugins: fastestmirror, security
Determining fastest mirrors
Could not retrieve mirrorlist http://mirrorlist.centos.org/?release=5&arch=x86_64&repo=os error was
[Errno 4] IOError: <urlopen error (-3, 'Temporary failure in name resolution')>
Error: Cannot find a valid baseurl for repo: base
```

The idea is to use `baseurl` instead of `miirrorlist` option in repository configuration files:
```
for FILE in /etc/yum.repos.d/*.repo ; do vim $FILE ; done
```

Sometimes YUM does not work with `https` URLs (because of our proxy).
Change them to simple `http`.


### RHEL5

The problem with RHEL5 is that it does not contain `salt-*` packages by default.

They are in a separate `EPEL` repository.

Normally, you can configure this repository yourself, but there is an RPM package
for this (available online or in http://YUM_OFFLINE_REPO_IP/mirror/epel/5/x86_64/epel-release-5-4.noarch.rpm)
```
rpm -ihv epel-release-5-4.noarch.rpm
```
It is better to use RPM because it also installs RPM sign keys for all packages from EPEL.

### Installation

If you run both Salt master and Salt minion on the same host, install both:
```
yum install salt-master salt-mininon
```

### Simplest configuration

In order to use all defaults and make Salt minion find Salt master automatically,
`salt` hostname should be resolvable (by any means: DNS, hosts file, etc.).
In the simplest case of single host with both Salt master and minion just add `salt` into your hosts file `/etc/hosts`:
```
salt 127.0.0.1
```

### Run

```
service salt-master start
service salt-minion start
chkconfig salt-master on
chkconfig salt-minion on
```

### Security

Next thing is Salt security. It's almost as simple as SSH or even simpler - all you need
is to accept Salt minion key on Salt master side. When Salt minion starts it sends
its public key to the Salt master it finds. Until you accept this public key, you cannot
control this Salt minion.

Run this command to see status of all public keys on Salt master side:
```
salt-key
```

To accept key by its name run this:
```
salt-key -a minion_key
```

### Test

```
salt '*' test.ping
```

### TODO

run this command to setup selected system:
```
salt '*' state.highstate
```

## Multi-project organization

These sources (State, Pillars, etc.) provide automation for multiple projects.

These are links to project-specific documentation:
* [common](projects/common/main.md)

The exhaustive details how multiple porjects are used can be found
[here](approach_for_multiple_projects.md).

Resources are all other files which are not supposed to be under source
control. There are multiple ways to provide resources. The most flexible
approach is to use external file server (FTP or HTTP).
However, the simples solution is to use Salt itself. Salt can be used as
a file server (with `salt://` URL scheme to access files from states).

TODO: Add general document about source code tree layout, connection between
resources, Salt configuration, all required symlinks, etc. Explain convention,
guidelines, and tools to maintain set of resources required to deploy
system offline.

## Highlights for Salt master setup

The following section highlights some important configuration Salt master
in its configuration file (`/etc/salt/master`) and beyond.

This should be reviewed when Salt is changed to use one project or another.

### Location of States and sources

```
file_roots:
    base:
        # Conventionally, the following directory is a symlink pointing to
        # `/home/[username]/Works/common-salt-states.git/states`
        - /srv/states

        # The following directory is a common place for all additional
        # symlinks pointing to various source code repositories.
        # These symlinks are configured automatically by using
        # `common.source_links` state - see below.
        - /srv/sources
```
Set `/srv/states` symlink to the Salt configuration sources:
```
ln -sfn /home/[username]/Works/common-salt-states.git/states /srv/states
```

Note that sub-items (directories or files) from the `sources` are only
accessible if they are not hidden by items in `states`.
For example, `salt://whatever` is always looked up as `/srv/states/whatever`
first before it even has a chance to be looked up as `/srv/sources/whatever`.

### Location of Pillars

```
pillar_roots:
    base:
        - /srv/pillars
```
Set `/srv/pillars` symlink to the Salt configuration sources:
```
ln -sfn /home/[username]/Works/project-salt-states.git/pillars /srv/pillars
```

### Selected project

```
this_system_keys:
    # ...
    # Salt master orchestrates only one project:
    # ...
```

This will rendeer templates using correct pillars and states.

### Selected profile

```
this_system_keys:
    # ...
    profile: blackbox # <-- selected profile
    # ...
```

### Selected customizer

Customizer can be used for personal configuration.
```
this_system_keys:
    # ...
    customizer: some_personal_id # <-- selected customizer
    # ...
```

### Selected Salt minions

Use `salt-key` to list registered minions ("Accepted Keys"):

```sh
salt-key
```

Delete keys of those minions which are not supposed to be controlled.
Accept keys of those minions which are     supposed to be controlled.

```sh
salt-key -d <key> # delete
salt-key -a <key> # accept
```

### Run state to setup symlinks

* Test (dry run):
```
salt '*' state.sls common.source_links test=True
```
* Apply:
```
salt '*' state.sls common.source_links test=False
```

* Render state from minion perspective:
```
# show specific state
salt '*' state.show_sls common.source_links

# show top
salt '*' state.show_top
```

## Next steps

See project-specific documentation which states to run to complete setup.

In majority of cases, when all minions are already connected,
all what is required is to run:
```
salt '*' state.highstate test=False
```
This will bring all minions to the fully configured state.

In a more complicated system especially when some minions should be
set up first to provide services for other minions (cross-host dependency
on services), orchestration can be used.
* TODO: add link to generic orchestration documentation.


## Setting up single agent-less host


This file demonstrates how to use master-less setup for single host
installation.
This normally requires providing the same information in `/etc/salt/minion`
which would normally go to `/etc/salt/master`.

* Checkout sources:
```
```

* Install Salt minion:
```
yum install salt-minion
```

* Point Salt to states and pillars (`/etc/salt/minion`):
```
file_roots:
    base:
        - /srv/states
...
pillar_roots:
    base:
        - /srv/pillars
```

* Make symlinks to the sources:
```
```

* Set minion id:
```
echo some_minion_id > /etc/salt/minion_id
```

* Test dummy state execution:
```
salt-call --local state.sls common.dummy test=True
```

* Define profile, project, list of minions (`/etc/salt/minion`):
```
this_system_keys:

    # The most neutral project is `common`.
    # If no project-related config is required, use any
    # unknown name (i.e. `none`).
    project: common

    # Profile is normally named after hostname.
    profile: this_minion_id

    # Customizer is supposed to be a personal id (account name,
    # nick name, etc.) which uniquely identifies person so
    # that individual customized states are kept separately
    # (under different sub-directories and files).
    customizer: some_personal_id
```

* Run highstate to test configuration:
```
salt-call --local state.highstate test=True
```

At this point the single minion is ready to be automatically
provided with any configuration by Salt. From now on, this is
a routine Salt usage which is all about listing required states
directly in `^/states/top.sls` (or indirectly) and updating pillar
data mostly provided through enfironment file:
```
^/pillars/[project]/profile/[some_minion_id].sls
```

