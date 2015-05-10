
Key `load_bootstrap_target_envs` is the root key which lists available
profiles enabled for generating [bootstrap][1] packages.

Normally, sub-keys (profiles) have the same meaning
and correspond to [profile][3].

The bootstrap target environments have to be specified explicitly in Salt
configuration because they must be allowed through the top pillar file under
[bootstrap_target_envs][5] keys. In other words, this cannot be done through
pillar data itself because pillar data is not available until it is loaded.

Once loaded, pillar data for corresponding pillar of corresponding project
is available at:
```
pillar['bootstrap_target_envs']['PROJECT_NAME.PROFILE_NAME']
```

Note that there is [additional key][6] in pillar data
called `enable_bootstrap_target_envs`.
In order for environment to be enabled, it should appear in both:
* configuration file under this `load_bootstrap_target_envs` key
* [pillar data entry][6] under `enable_bootstrap_target_envs` key

## Example ##

```
this_system_keys:
    project: projectA
    profile: whatever
    # ...
    load_bootstrap_target_envs:
        profileA1:
        profileA2:
```

[1]: docs/bootstrap.md
[2]: docs/configs/common/this_system_keys/project/readme.md
[3]: docs/configs/common/this_system_keys/profile/readme.md
[4]: #example
[5]: docs/pillars/bootstrap/bootstrap_target_envs/readme.md
[6]: docs/pillars/bootstrap/system_features/bootstrap_configuration/enable_bootstrap_target_envs/readme.md

