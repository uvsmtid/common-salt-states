
Key `master_minion_id` specifies name of the minion co-located with master.

This is primarily needed to quickly get working system of Salt master and
minion on the same host without updating pillar template (template uses
this value to get default).

It is oftent the case when `master_minion_id` is the same as [profile][1]
(in other words, profile is named after master it is managed by).

[1]: docs/configs/common/this_system_keys/profile/readme.md

