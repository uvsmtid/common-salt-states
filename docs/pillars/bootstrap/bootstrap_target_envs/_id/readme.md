
TODO: This is outdated `this_system_keys` is not used anymore.

The id under `bootstrap_target_envs` is a string of
project_name and profile_name concatenated through `.` (dot), for example:
```
pillar['bootstrap_target_envs']['project_name.profile_name']
```

The value represents entire pillar data for specified
profile_name of specified project_name.

See details in:
* [bootstrap_target_envs][1] in pillar
* [load_bootstrap_target_envs][2] in configuration files

[1]: /docs/pillars/common/bootstrap_target_envs/readme.md
[2]: /docs/configs/bootstrap/this_system_keys/load_bootstrap_target_envs/readme.md

