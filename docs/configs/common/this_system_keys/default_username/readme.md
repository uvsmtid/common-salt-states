
Key `default_username` specifies username to be used for [username][1] field
of [primary_user][2] in all minions by default.

This is primarily needed to quickly get working system of Salt master and
minion on the same host without updating pillar template
(pillar template takes this value as default).

[1]: docs/pillars/common/system_hosts/_id/primary_user/username/readme.md
[2]: docs/pillars/common/system_hosts/_id/primary_user/readme.md

