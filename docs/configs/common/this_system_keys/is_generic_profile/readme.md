
If field `is_generic_profile` is false, it will require a pillar file named
after profile under [`profile` directory][1].

This is made to enforce difference between different profiles.

It also affects default branch name used in pillar template.
See these fields for details:
*   [`current_task_branch`][2]
*   [`profile_name`][3]

[1]: /pillar/profile
[2]: /docs/configs/common/this_system_keys/current_task_branch/readme.md
[3]: /docs/configs/common/this_system_keys/profile_name/readme.md

