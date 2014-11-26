
### Chicken and Egg problem


Salt is used to automate installation, but how do we install Salt itself in the first place?

Initial configuration can be a little complex and that's exactly the purpose of Salt to
automate complex configuration. Hence, chicken and egg problem.
So, is Salt still useful? Yes, of cource, if you don't confiugre installation of
Salt only, everything beyond this is potentially automate-able.

This question is only relatively diffult for old Linuxes and Windows because
no default YUM repository provides these packages.

### Common network problems

Now it's even more diffuclt if you are behind a proxy.

Simple step: configure youre proxy for YUM: `vi /etc/yum.conf`
```
...

# Proxy settings
proxy=http://YOUR_PROXY_HOST_NAME:YOUR_PROXY_PORT_NUMBER/
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
for this:
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

Additional steps is to connect this `common-salt-states` sources to Salt and
run this command to setup selected system:
```
salt '*' state.highstate 
```

