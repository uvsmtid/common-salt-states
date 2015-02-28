
Key `bootstrap_target_envs` provides profile data for other (not currently
selected [project][1] and [profile][2]) managed system to generate
[bootstrap][5] packages.

The projects and profiles loaded under this key have to be listed in Salt
configuration file (minion or master) under [bootstrap_target_envs][3] - see
details there.

Each [key under][4] `bootstrap_target_envs` is accessible in Salt states as:
```
pillar['bootstrap_target_envs']['PROJECT_NAME.PROFILE_NAME']
```

[1]: docs/configs/common/this_system_keys/project/readme.md
[2]: docs/configs/common/this_system_keys/profile/readme.md
[3]: docs/configs/common/this_system_keys/bootstrap_target_envs/readme.md
[4]: docs/pillars/common/bootstrap_target_envs/_id/readme.md
[5]: docs/bootstrapping.md

