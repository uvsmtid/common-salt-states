
Dictionary `system_hosts` provides information about hosts participating in the
system managed by this particular Salt master.

## Minion id for non-minions ##

The id for each host configuration object is a minion id (see [Keys](#keys)
section below). But it does not mean the host is actually managed or such
minion exists. It only means that if such minion _exists and connected_ to
Salt master using `salt-key` command then it will be configured according
to the pillar data. In other words, there could be any other hosts outside
of Salt master control (i.e. example.com) which are still considered
(external) part of the system even though there is no way to configure them.

## Centralized host configuration ##

It is important to understand that the main purpose of this dictionary is to _centralize_ host configuration
and make it convenient to manage from this single place (pillar file).

An alternative to this centralized approach is to use custom [grains](http://docs.saltstack.com/en/latest/topics/targeting/grains.html)
(either defined in `grains` key of `/etc/salt/minion` or in separate `/etc/salt/grains` configuration file).
However, this leads to inconvenience of distributed configuration - one should
change configuration of each minion separately and restart minion service one
by one. Using grains makes it _impossible_ to acheive zero config for minions.

## Keys ##

Keys are [ids of the minions](http://docs.saltstack.com/en/latest/ref/configuration/minion.html) participating in the system managed by this Salt master.

A particular minion is only managed by Salt master if it is in the list
of `Accepted Keys` provided by the following command:
```
salt-key
```
It is important to understant that. In other words, if `system_hosts`
lists many different minion ids with corresponding configuration, it does not
mean they are managed. For example, the following command will only contact
minions from `Accepted Keys`:
```
salt '*' test.ping
```

## Values ##

The value is provides various minion configuration:
* [primary_user](docs/pillars/common/system_hosts/_id/primary_user/readme.md)
* [hostname](docs/pillars/common/system_hosts/_id/hostname/readme.md)

