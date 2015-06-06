
Field `profile_name` identifies specific configuration for environment within
[selected `project_name`][1] which is to be be used for deployment
(on hosts managed within current system).

See also [`master_minion_id`][2] which specifies host with Salt master
managing current system.

The value of `profile_name` filed is also used as default branch name
for all repositories with pillars if [`is_generic_profile`][4] is not `True`.

See also [`current_task_branch`][3] which specifies default branch name
for all other repositories (those without pillars).

[1]: /docs/configs/common/this_system_keys/project_name/readme.md
[2]: /docs/configs/common/this_system_keys/master_minion_id/readme.md
[3]: /docs/configs/common/this_system_keys/current_task_branch/readme.md
[4]: /docs/configs/common/this_system_keys/is_generic_profile/readme.md

