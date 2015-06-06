
Field `current_task_branch` is used in pillars which set branch name
of various repositories. Without this parameter these pillar files
have to be changed every time current task branch is changed
(i.e. if testing is required).

Assuming that all repositories maintain the same current task branch name
(for possible changes related to the task in all of them)
all what has to be changed is `current_task_branch` field in
Salt configuration.

Note that repositories with pillars follow different default branch names -
they use [`profile_name`][1] instead.

[1]: /docs/configs/common/this_system_keys/profile_name/readme.md

