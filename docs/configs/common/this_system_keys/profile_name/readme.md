
Field `profile_name` identifies specific configuration for environment within
[selected `project_name`][1] which is to be be used for deployment
(on hosts managed within current system).

See also [`master_minion_id`][2] which specifies host with Salt master
managing current system.

The value of `profile_name` field is also used as default branch name
for repositories with pillars only.

[1]: /docs/configs/common/this_system_keys/project_name/readme.md
[2]: /docs/configs/common/this_system_keys/master_minion_id/readme.md

