## Initial Salt setup ##

All steps are applicable to any OS, however, examples are given for
RedHat Linux 5 (RHEL5) only (and will lagerly work on RHEL6 and RHEL7 too).
To keep it specific, [this link][5] describes initial clean RHEL5-compartible
CentOS image as an example for Salt installation.

The steps below assume that both Salt master and Salt minion have to be
installed and configured on _the same single host_ for the first time.

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

If you are behind a proxy, configure proxy for YUM.

NOTE: On the latest Fedora (confirmed for F22),
file `/etc/dnf/dnf.conf` has to be used instead.

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
yum install salt-master salt-minion
```

### Simplest configuration ###

Minion is identified by its minion id.

Set `id` field in Salt minion configuration in `/etc/salt/minion` file:

```
id: master_minion_id
```

NOTE: Substitute `master_minion_id` by chosen master minion id.

In order to use all defaults and make sure that Salt minion
finds Salt master automatically, `salt` hostname should be
resolvable (by any means: DNS, hosts file, etc.).

In the simplest case to resolve `salt` hostname on Salt master minion
only just add `salt` into master minion's hosts file `/etc/hosts` pointing
to local IP address:

```
127.0.0.1 salt master_minion_id
```

NOTE: Substitute `master_minion_id` by chosen master minion id.

NOTE: In addition to `salt` hostname `master_minion_id` is also resolved
into localhost IP address. This is required for some Salt states where
master connects to itself using its hostname (which matches master minion
id by convention). This line is only applicable for master minion because
other minions will not be able to find Salt master via localhost.


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

# [footer] #

[1]: /docs/bootstrap/readme.md
[2]: /docs/framework.md
[3]: /docs/orchestration.md
[4]: http://docs.saltstack.com/
[5]: https://github.com/uvsmtid/vagrant-boxes/tree/master/centos-5.5-minimal
[6]: http://docs.saltstack.com/en/latest/topics/installation/rhel.html
[7]: https://copr.fedoraproject.org/coprs/saltstack/salt-el5/
[8]: https://copr.fedoraproject.org/coprs/saltstack/salt-el5/repo/epel-5/saltstack-salt-el5-epel-5.repo
[9]: /docs/configs/common/this_system_keys/project_name/readme.md
[10]: /docs/configs/common/this_system_keys/profile_name/readme.md
[11]: /docs/configs/common/this_system_keys/master_minion_id/readme.md
[12]: /docs/configs/common/this_system_keys/default_username/readme.md
[13]: /pillars
[14]: /docs/salt_runtime.md

