
Key `load_bootstrap_target_envs` is the root key which lists available
projects and their profiles enabled for generating
[bootstrap][1] packages:
* The 1st-level key has the same meaning for bootstrap as [project][2].
* The 2nd-level key has the same meaning for bootstrap as [profile][3].

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
    profile: profileA1
    # ...
    load_bootstrap_target_envs:
        projectA:
            profileA1:
            profileA2:
        projectB:
            profileB1:
            profileB2:
            profileB3:
```

## Pillar data for current project ##

Note that currently selected pillar (specified by [project][2] and
[profile][3] keys right under `this_system_keys`) is not loaded
under bootstrap target environment.

Using the [example above][4], this reference to pillar data will fail:
```
pillar['bootstrap_target_envs']['projectA.profileA1']
```

This is a special case and can be explained as (might be):
* some logical behaviour to avoid recursion;
* internal Salt behaviour which does not allow
  loading the same pillar file twice;
* a Salt bug;
* etc.
Regardless of the answer, make sure to use pillar root if currently selected
profile of currently selected project is required as a bootstrap target
environment.


[1]: docs/bootstrapping.md
[2]: docs/configs/common/this_system_keys/project/readme.md
[3]: docs/configs/common/this_system_keys/profile/readme.md
[4]: #example
[5]: docs/pillars/common/bootstrap_target_envs/readme.md

