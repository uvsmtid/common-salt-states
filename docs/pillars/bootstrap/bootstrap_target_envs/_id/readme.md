
The id under `bootstrap_target_envs` is a strings of project name and profile
name concatenated through `.` (dot), for example:
```
pillar['bootstrap_target_envs']['PROJECT_NAME.PROFILE_NAME']
```

The value represents entire pillar data for specified profile of specified
project.

See details in:
* [bootstrap_target_envs][1] in pillar
* [load_bootstrap_target_envs][2] in configuration files
* [enable_bootstrap_target_envs][3] in pillar

[1]: docs/pillars/common/bootstrap_target_envs/readme.md
[2]: docs/configs/bootstrap/this_system_keys/load_bootstrap_target_envs/readme.md
[3]: docs/pillars/bootstrap/system_features/bootstrap_configuration/enable_bootstrap_target_envs/readme.md
