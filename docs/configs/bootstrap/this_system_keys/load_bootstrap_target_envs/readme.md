
TODO: This is outdated - `this_system_keys` in configuration
      is not used anymore.

Key `load_bootstrap_target_envs` is the root key which lists available
`profile_name`s enabled for building [bootstrap packages][1].

Normally, sub-keys (profile_names) have the same meaning
and correspond to [profile_name][3].

The bootstrap target environments have to be specified explicitly in Salt
configuration because they must be allowed through the top pillar file under
[bootstrap_target_envs][5] keys. In other words, this cannot be done through
pillar data itself because pillar data is not available until it is loaded.

Once loaded, pillar data for corresponding pillar of corresponding project
is available at:
```
pillar['bootstrap_target_envs']['project_name.profile_name']
```

Note that there is [additional key][6] in pillar data
called `enable_bootstrap_target_envs`.
In order for environment to be enabled, it should appear in both:
* configuration file under this `load_bootstrap_target_envs` key
* [pillar data entry][6] under `enable_bootstrap_target_envs` key

## Example ##

```
this_system_keys:
    project_name: project_name_A
    profile_name: whatever
    # ...
    load_bootstrap_target_envs:
        profile_name_A1:
        profile_name_A2:
```

[1]: /docs/bootstrap/build.md
[2]: /docs/configs/common/this_system_keys/project_name/readme.md
[3]: /docs/configs/common/this_system_keys/profile_name/readme.md
[4]: #example
[5]: /docs/pillars/bootstrap/bootstrap_target_envs/readme.md
[6]: /docs/pillars/bootstrap/system_features/source_bootstrap_configuration/enable_bootstrap_target_envs/readme.md

