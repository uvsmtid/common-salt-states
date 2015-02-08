
Dictionary `system_hosts` provides information about hosts participating in the
system managed by this particular Salt master.

## Centralized host configuration ##

It is important to understand that the main purpose of this dictionary is to _centralize_ host configuration
and make it convenient to manage it from single place.

An alternative to this centralized approach is to use custom [grains](http://docs.saltstack.com/en/latest/topics/targeting/grains.html)
(either defined in `grains` key of `/etc/salt/minion` or in separate `/etc/salt/grains` configuration file).
However, this leads to inconvenience of distributed configuration - one should
change configuration of each minion separately and restart minion service one
by one. This also makes it impossible to acheive zero config for minions.

Each key in `system_hosts` is minion id.

