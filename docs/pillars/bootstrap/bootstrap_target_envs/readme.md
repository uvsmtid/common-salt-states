
Key `bootstrap_target_envs` provides profile data for other (not currently
selected [project_name][1] and [profile][2]) managed system to generate
[bootstrap][5] packages.

The profiles loaded under this key have to be listed in Salt
configuration file (minion or master) under [load_bootstrap_target_envs][3].

[Each key][4] under `bootstrap_target_envs` is accessible in Salt states as:
```
pillar['bootstrap_target_envs']['PROJECT_NAME.PROFILE_NAME']
```

[1]: docs/configs/common/this_system_keys/project_name/readme.md
[2]: docs/configs/common/this_system_keys/profile/readme.md
[3]: docs/configs/bootstrap/this_system_keys/load_bootstrap_target_envs/readme.md
[4]: docs/pillars/bootstrap/bootstrap_target_envs/_id/readme.md
[5]: docs/bootstrap.md

