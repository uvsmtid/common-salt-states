
The `bootstra_target_envs` is the root key which lists enabled
bootstrap profiles. Its structure is the same with
[load_bootstra_target_envs][1] key value inside Salt configuration file.

In order for profile to be enabled, it should appear in both:
* [configuration file entries][1] under `load_bootstrap_target_envs` key
* pillar data entry under this `enable_bootstrap_target_envs` key

See also:
* Main [bootstrap][2] documentation.

[1]: docs/configs/bootstrap/this_system_keys/load_bootstrap_target_envs/readme.md
[2]: docs/bootstrap.md

